//
//  MultipleDestinations.swift
//  tca_practice
//
//  Created by KS on 2025/12/01.
//
import ComposableArchitecture
import SwiftUI

private let readMe = """

この画面は、1つの enum 型の状態から、3種類のナビゲーション（ドリルダウン、シート、ポップオーバー）を駆動する方法をデモします。

ポイント
• 「どの種類の遷移か」を Destination という1つの enum 状態に集約して管理するのが肝です。
• SwiftUI の各プレゼンテーション API と TCA の @Presents を組み合わせることで、宣言的かつ型安全に複数の遷移先を扱えます。
• 子画面の状態・アクションは ifLet と scope を通じて親から安全に委譲されます。

処理の概要
• 本機能は The Composable Architecture (TCA) を使い、1つの enum 状態（Destination）で3つの遷移先を表現します。
   • Destination は次の3ケースを持ち、それぞれに Counter の状態を内包します:
      • drillDown(Counter)
      • popover(Counter)
      • sheet(Counter)
• 画面側の状態 MultipleDestinations.State は、@Presents var destination: Destination.State? を持ち、現在表示すべき遷移先をオプショナルで保持します。
   • @Presents により、SwiftUI の .navigationDestination(item:) / .sheet(item:) / .popover(item:) と自然に連携できる形で状態を管理します。
"""

@Reducer
struct MultipleDestinations {
  @Reducer
  enum Destination {
    case drillDown(Counter)
    case popover(Counter)
    case sheet(Counter)
  }

  @ObservableState
  struct State: Equatable {
    @Presents var destination: Destination.State?
  }

  enum Action {
    case destination(PresentationAction<Destination.Action>)
    case showDrillDown
    case showPopover
    case showSheet
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .showDrillDown:
        state.destination = .drillDown(Counter.State())
        return .none

      case .showPopover:
        state.destination = .popover(Counter.State())
        return .none

      case .showSheet:
        state.destination = .sheet(Counter.State())
        return .none

      case destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
}

extension MultipleDestinations.Destination.State: Equatable {}

struct MultipleDestinationsView: View {
  @Bindable var store: StoreOf<MultipleDestinations>

  var body: some View {
    Form {
      Section {
        AboutView(readMe: readMe)
      }
      Button("Show Drill Down") {
        store.send(.showDrillDown)
      }
      Button("Show Popover") {
        store.send(.showPopover)
      }
      Button("Show Sheet") {
        store.send(.showSheet)
      }
    }
    .navigationDestination(
      item: $store.scope(state: \.destination?.drillDown, action: \.destination.drillDown)
    ) { store in
      CounterView(store: store)
    }
    .popover(
      item: $store.scope(state: \.destination?.popover, action: \.destination.popover)
    ) { store in
        CounterView(store: store)
      }
    .sheet(
      item: $store.scope(state: \.destination?.sheet, action: \.destination.sheet)
    ) { store in
      CounterView(store: store)
    }
  }
}
