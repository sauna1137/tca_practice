//
//  FocusState.swift
//  tca_practice
//
//  Created by KS on 2024/11/27.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct FocusStateDemo {
  @ObservableState
  struct State: Equatable {
    var focusField: Field?
    var password: String = ""
    var userName: String = ""

    enum Field: String, Hashable {
      case userName, password
    }
  }

  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case signInButtonTapped
  }

  var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none
      case .signInButtonTapped:
        if state.userName.isEmpty {
          state.focusField = .userName
        } else if state.password.isEmpty {
          state.focusField = .password
        }
        return .none
      }
    }
  }
}

struct FocusStateView: View {
  @Bindable var store: StoreOf<FocusStateDemo>
  @FocusState var focusedField: FocusStateDemo.State.Field?

  var body: some View {
    Form {
      VStack {
        TextField("UserName", text: $store.userName)
          .focused($focusedField, equals: .userName)

        SecureField("Password", text: $store.password)
          .focused($focusedField, equals: .password)

        Button("sing in") {
          store.send(.signInButtonTapped)
        }
        .buttonStyle(.borderedProminent)
      }
      .textFieldStyle(.roundedBorder)
    }
    .bind($store.focusField, to: $focusedField)
    .navigationTitle("Focus")
  }
}

