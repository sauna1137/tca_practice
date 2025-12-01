//
//  ListsNavitate.swift
//  tca_practice
//
//  Created by KS on 2025/11/27.
//

import Foundation
import CombosableArchitecture
import SwiftUI


private let readMe = """
この画面は、リスト要素からオプショナルな状態を読み込み、それに依存するナビゲーションをデモします。

行をタップすると、その行に紐づくカウンター状態に依存する画面へ同時に遷移し、1 秒後にこの状態を読み込むエフェクトが起動します。


全体像
• NavigateAndLoadList リデューサと NavigateAndLoadListView により、リストからの選択に応じて詳細画面へナビゲーションし、オプショナルな状態を遅延ロードする流れを実装しています。
• 選択直後は詳細の状態がまだ nil なのでプレースホルダ（ProgressView）を表示し、1 秒後に Counter.State を注入して実画面（CounterView）を表示します。
• 戻ると、詳細で変更されたカウント値をリスト側に反映します。

⸻
"""

@Reducer
struct NavigateAndLoadList {
  @ObservableState
  struct State: Equatable {
    var rows: IdentifiedArrayOf<Row> = [
      Row(count: 1, id: UUID()),
      Row(count: 42, id: UUID()),
      Row(count: 100, id: UUID())
    ]
    var selection: Identified<Row.ID, Counter.State?>?

    struct Row: Equatable, Identifiable {
      var count: Int
      let id: UUID
    }
  }

  enum Action {
    case counter(Counter.Action)
    case setNavigation(selection: UUID?)
    case setNavigationSElectionDelayCompleted
  }

  @Dependency(\.continuousClock) var clock
  private enum CancelID { case load }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .counter:
        return .none
      case let .setNavigation(selection: .some(id)):
        state.selection = Identified(nil, id: id)
        return .run { send in
          try await self.clock.sleep(for: .seconds(1))
          await send(.setNavigationSElectionDelayCompleted)
        }
        .cancellable(id: CancelID.load, cancelInFlight: true)

      case .setNavigation(selection: .none):
        if let selection = state.selection, let count = selection.value?.count {
          state.rows[id: selection.id]?.count = count
        }
        state.selection = nil
        return .cancel(id: CancelID.load)

      case .setNavigationSelectionDelayCompleted:
        guard let id = state.selection?.id else { return .none }
        let count = state.rows[id: id]?.count ?? 0
        state.selection?.value = Counter.State(count: count)
        return .none
      }
    }
    .ifLet(\.selection, action: /Action.counter) {
      EmptyReducer()
        .ifLet(\.value, action: \.self) {
          Counter()
        }
    }
  }
}

struct NavigateAndLoadListView: View {
  @Bindable var store: StoreOf<NavigateAndLoadList>

  var body: some View {
    Form {
      Section {
        AboutView(readMe: readMe)
      }
      ForEach(store.rows) { row in
        NavigationLink(
          "Load optional counter that starts from \(row.count)",
          tag: row.id,
          selection: .init(
            get: { store.selection?.id },
            set: { store.send(.setNavigation(selection: $0)) }
          )
        ) {
          if let store = store.scope(state: \.selection?.value, action: \.counter) {
            CounterView(store: store)
          } else {
            ProgressView()
          }
        }
      }
    }
    .navigationTitle("Navigate and Load List")
  }
}
