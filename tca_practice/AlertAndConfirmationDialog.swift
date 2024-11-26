//
//  AlertAndConfirmationDialog.swift
//  tca_practice
//
//  Created by KS on 2024/11/26.
//


//これは、Composable Architectureにおけるアラートや確認ダイアログの最適な扱い方を示しています。
//ライブラリには、アラートやダイアログの状態とアクションをデータとして記述するための AlertState と ConfirmationDialogState の2つの型が用意されています。
//これらの型はリデューサー内で構築され、アラートや確認ダイアログが表示されるかどうかを制御できます。また、対応するビュー修飾子 alert(_:) および confirmationDialog(_:) に、アラートやダイアログのドメインにフォーカスしたストアへのバインディングを渡すことで、ビュー内でアラートやダイアログを表示できます。
//これらの型を使用するメリットは、アプリケーション内でユーザーがアラートやダイアログとどのようにやり取りするかを完全にテストカバーできる点にあります。

import ComposableArchitecture
import SwiftUI

@Reducer
struct AlertAndConfirmationDialog {
  @ObservableState
  struct State: Equatable {
    @Presents var alert: AlertState<Action.Alert>?
    @Presents var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
    var count = 0
  }

  enum Action {
    case alert(PresentationAction<Alert>)
    case alertButtonTapped
    case confirmationDialog(PresentationAction<ConfirmationDialog>)
    case confirmationDialogButtonTapped

    @CasePathable
    enum Alert {
      case incrementButtonTapped
    }

    @CasePathable
    enum ConfirmationDialog {
      case incrementButtonTapped
      case decrementButtonTapped
    }
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .alert(.presented(.incrementButtonTapped)),
           .confirmationDialog(.presented(.incrementButtonTapped)):
        state.alert = AlertState { TextState("Incremented!")}
        state.count += 1
        return .none
      case .alertButtonTapped:
        state.alert = AlertState {
          TextState("Alert!")
        } actions: {
          ButtonState(role: .cancel) {
            TextState("Cancel")
          }
          ButtonState(action: .incrementButtonTapped) {
            TextState("Increment")
          }
        } message: {
          TextState("This is an alert")
        }
        return .none
      case .confirmationDialog(.presented(.decrementButtonTapped)):
        state.alert = AlertState { TextState("Decremented!") }
        state.count -= 1
        return .none

      case .confirmationDialog:
        return .none

      case .confirmationDialogButtonTapped:
        state.confirmationDialog = ConfirmationDialogState {
          TextState("Confirmation dialog")
        } actions: {
          ButtonState(role: .cancel) {
            TextState("Cancel")
          }
          ButtonState(action: .incrementButtonTapped) {
            TextState("Increment")
          }
          ButtonState(action: .decrementButtonTapped) {
            TextState("Decrement")
          }
        } message: {
          TextState("This is a confirmation dialog.")
        }
        return .none
      case .alert:
        return .none
      }
    }
    .ifLet(\.$alert, action: \.alert)
    .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
  }
}
struct AlertAndConfirmationDialogView: View {
  @Bindable var store: StoreOf<AlertAndConfirmationDialog>

  var body: some View {
    Form {
      Text("Count: \(store.count)")
      Button("Alert") { store.send(.alertButtonTapped) }
      Button("Confirmation Dialog") { store.send(.confirmationDialogButtonTapped) }
    }
    .navigationTitle("Alerts & Dialogs")
    .alert($store.scope(state: \.alert, action: \.alert))
    .confirmationDialog($store.scope(state: \.confirmationDialog, action: \.confirmationDialog))
  }
}
