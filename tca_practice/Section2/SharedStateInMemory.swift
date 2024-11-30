//
//  SharedStateInMemory.swift
//  tca_practice
//
//  Created by KS on 2024/11/30.
//

import ComposableArchitecture
import SwiftUI

// このスクリーンは、複数の独立した画面が、メモリ内参照を通じてComposable Architectureで状態を共有する方法を示しています。各タブはそれぞれ独自のステートを管理しており、別々のモジュールに存在することもありますが、一方のタブでの変更は他方のタブに即座に反映されます。

// このタブには、インクリメントとデクリメント可能なカウント値と、現在のカウントが素数かどうかを尋ねたときに設定されるアラート値からなる独自のステートがあります。内部的には、最小カウント、最大カウント、発生したカウントイベントの総数などのさまざまな統計情報を追跡しています。これらの状態は他のタブから見ることができ、統計情報は他のタブからリセットすることができます。

@Reducer
struct SharedStateInMemory {
  enum Tab { case counter, profile }

  @ObservableState
  struct State: Equatable {
    var currentTab = Tab.counter
    var counter = CounterTab.State()
    var profile = ProfileTab.State()
  }

  enum Action {
    case counter(CounterTab.Action)
    case profile(ProfileTab.Action)
    case selectTab(Tab)
  }

  var body: some Reducer<State, Action> {
    Scope(state: \.counter, action: \.counter) {
      CounterTab()
    }

    Scope(state: \.profile, action: \.profile) {
      ProfileTab()
    }

    Reduce { state, action in
      switch action {
      case .counter, .profile:
        return .none
      case let .selectTab(tab):
        state.currentTab = tab
        return .none
      }
    }
  }
}

#Preview {
    SharedStateInMemory()
}
