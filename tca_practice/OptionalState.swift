//
//  Untitled.swift
//  tca_practice
//
//  Created by KS on 2024/11/21.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct OptionalBasics {
  @ObservableState
  struct State: Equatable {
    var optionalCounter: Counter.State?
  }

  enum Action {
    case optionalCounter(Counter.Action)
    case toggleCounterButtonTapped
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .toggleCounterButtonTapped:
        state.optionalCounter = state.optionalCounter == nil ? Counter.State() : nil
        return .none
      case .optionalCounter:
        return .none
      }
    }
    .ifLet(\.optionalCounter, action: \.optionalCounter) {
      Counter()
    }
  }
}

struct OptionalBasicsView: View {
  let store: StoreOf<OptionalBasics>

  var body: some View {
    Form {
      Button("toggle counter state") {
        store.send(.toggleCounterButtonTapped)
      }

      if let store = store.scope(state: \.optionalCounter, action: \.optionalCounter) {
        Text("`Counter.State` is non-`nil`")
        CounterView(store: store)
          .buttonStyle(.borderless)
          .frame(maxWidth: .infinity)
      } else {
        Text("counter is nil")
      }
    }
  }
}

#Preview {
  NavigationStack {
    OptionalBasicsView(
      store: Store(initialState: OptionalBasics.State()) {
        OptionalBasics()
      }
    )
  }
}
