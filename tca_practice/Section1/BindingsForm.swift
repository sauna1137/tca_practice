//
//  BindingsForm.swift
//  tca_practice
//
//  Created by KS on 2024/11/14.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct BindingForm {
  @ObservableState
  struct State: Equatable  {
    var sliderValue = 5.0
    var stepCount = 10
    var text = ""
    var toggleIsOn = false
  }

  // BindableAction:
  // Action がビューの双方向バインディングに対応するためのプロトコル
  enum Action: BindableAction {
    // State の特定のプロパティに関する双方向バインディングを表すアクション型
    case binding(BindingAction<State>)
    case resetButtonTapped
  }

  var body: some Reducer<State, Action> {
    // @BindableStateとBindableActionの連携を自動的に処理
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .binding(\.stepCount):
        state.sliderValue = .minimum(state.sliderValue, Double(state.stepCount))
        return .none

      case .binding:
        return .none

      case .resetButtonTapped:
        state = State()
        return .none
      }
    }
  }
}

struct BindingsForm: View {
  @Bindable var store: StoreOf<BindingForm>

  var body: some View {
    Form {
      HStack {
        TextField("Type here", text: $store.text)
          .disableAutocorrection(true)
          .foregroundStyle(store.toggleIsOn ? .secondary : .primary)
        Text(alternate(store.text))
      }
      .disabled(store.toggleIsOn)

      Toggle("Disable Othres", isOn: $store.toggleIsOn)

      Stepper(
        "Max Slider Value: \(store.stepCount)",
        value: $store.stepCount,
        in: 0...100)
      .disabled(store.toggleIsOn)

      HStack {
        Text("Slider value: \(Int(store.sliderValue))")

        Slider(value: $store.sliderValue, in: 0...Double(store.stepCount))
          .tint(.accentColor)
      }
      .disabled(store.toggleIsOn)

      Button("Reset") {
        store.send(.resetButtonTapped)
      }
      .tint(.red)
    }
    .monospacedDigit()
    .navigationTitle("Bindings form")
  }
}

private func alternate(_ string: String) -> String {
  string
    .enumerated()
    .map { idx, char in
      idx.isMultiple(of: 2)
      ? char.uppercased()
      : char.lowercased()
    }
    .joined()
}

#Preview {
  BindingsForm(store: Store(initialState: BindingForm.State(), reducer: {
    BindingForm()
  }))
}
