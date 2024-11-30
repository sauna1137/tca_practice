//
//  Bindings-Basic.swift
//  tca_practice
//
//  Created by KS on 2024/11/11.
//


//このファイルは、Composable Architectureにおける双方向バインディングの扱い方を示しています。
//SwiftUIにおける双方向バインディングは非常に強力ですが、Composable Architectureの「単方向データフロー」の原則に反するものでもあります。これは、どの箇所からでも値を自由に変更できてしまうためです。
//一方で、Composable Architectureでは、状態の変更は必ずアクションをストアに送信することでのみ行われるべきであり、その結果、機能の状態がどのように進化するかを確認できる唯一の場所がリデューサーになります。
//バインディングが必要な任意のSwiftUIコンポーネントは、Composable Architecture内で使用可能です。バインディングをストアから派生させるには、バインダブルストアを使用して、コンポーネントをレンダリングする状態のプロパティにチェーンし、
//その状態が変更された際に送信するアクションへのキー・パスを指定してsendingメソッドを呼び出します。これにより、機能の単方向スタイルを保ちながら利用することができます。

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
