//
//  Cancellation.swift
//  tca_practice
//
//  Created by KS on 2025/01/28.
//

import ComposableArchitecture
import SwiftUI

/// ステッパーを使って数字を選び、「Number fact」ボタンをタップすると、その数字に関するランダムな事実をAPIから取得します。
///APIリクエストが実行中の間に「Cancel」ボタンをタップすると、エフェクトをキャンセルし、アプリへのデータの流入を防ぐことができます。
/// また、リクエストの途中でステッパーを操作すると、リクエストが自動的にキャンセルされます。

@Reducer
struct EffectsCancellation {
  @ObservableState
  struct State: Equatable {
    var count = 0
    var currentFact: String?
    var isFactRequestInFlight = false
  }

  enum Action {
    case cancelButtonTapped
    case stepperChanged(Int)
    case factButtonTapped
    case factResponse(Result<String, any Error>)
  }

  @Dependency(\.factClient) var factClient
  private enum CancelID { case factRequest }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .cancelButtonTapped:
        state.isFactRequestInFlight = false
        return .cancel(id: CancelID.factRequest)

      case .stepperChanged(let value):
        state.count = value
        state.currentFact = nil
        state.isFactRequestInFlight = false
        return .cancel(id: CancelID.factRequest)

      case .factButtonTapped:
        state.currentFact = nil
        state.isFactRequestInFlight = true
        return .run { [count = state.count] send in
          await send(.factResponse(Result { try await self.factClient.fetch(count) }))
        }
        .cancellable(id: CancelID.factRequest)

      case let .factResponse(.success(response)):
        state.isFactRequestInFlight = false
        state.currentFact = response
        return .none

      case .factResponse(.failure):
        state.isFactRequestInFlight = false
        return .none
      }
    }
  }
}

struct Cancellation: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    Cancellation()
}
