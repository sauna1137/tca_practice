//
//  Bindings-Basic.swift
//  tca_practice
//
//  Created by KS on 2024/11/11.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct BindingBasics {
  @ObservableState
  struct State: Equatable {
    var sliderValue = 5.0
    var stepCount = 10
    var text = ""
    var toggleIsOn = false
  }

  enum Action {
    case sliderValueChanged(Double)
    case stepCountChanged(Int)
    case textChanged(String)
    case toggleChanged(isOn: Bool)
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case let .sliderValueChanged(value):
        state.sliderValue = value
        return .none

      case let .stepCountChanged(count):
        state.sliderValue = .minimum(state.sliderValue, Double(count))
        state.stepCount = count
        return .none

      case let .textChanged(text):
        state.text = text
        return .none

      case let .toggleChanged(isOn):
        state.toggleIsOn = isOn
        return .none
      }
    }
  }
}

struct BindingBasicsView: View {
  @Bindable var store: StoreOf<BindingBasics>

  var body: some View {
    Form {
      HStack {
        TextField("Type here", text: $store.text.sending(\.textChanged))
          .disableAutocorrection(true)
          .foregroundStyle(store.toggleIsOn ? .secondary : .primary)
        Text(alternate(store.text))
      }
      .disabled(store.toggleIsOn)

      Toggle(
        "Disable other controls",
        isOn: $store.toggleIsOn.sending(\.toggleChanged)
      )

      Stepper(
        "Max slider value: \(store.stepCount)",
        value: $store.stepCount.sending(\.stepCountChanged),
        in: 0...100
        )
      .disabled(store.toggleIsOn)

      HStack {
        Text("slider value: \(Int(store.sliderValue))")
        Slider(
          value: $store.sliderValue.sending(\.sliderValueChanged),
          in: 0...Double(store.stepCount)
          )
        .tint(.accentColor)
      }
      .disabled(store.toggleIsOn)
    }
    .monospacedDigit()
    .navigationTitle("bindings basics")
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
  BindingBasicsView(store: Store(initialState: BindingBasics.State(), reducer: {
    BindingBasics()
  }))
}
