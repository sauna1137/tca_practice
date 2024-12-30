//
//  RootView.swift
//  
//
//  Created by KS on 2024/11/05.
//

import ComposableArchitecture
import SwiftUI

struct RootView: View {
  var body: some View {
    NavigationStack {
      Form {
        Section {
          NavigationLink("Counter") {
            Demo(store: Store(initialState: Counter.State()) { Counter() }) { store in
              CounterDemoView(store: store)
            }
          }

          NavigationLink("Two Counters") {
            Demo(store: Store(initialState: TwoCounters.State()) { TwoCounters() }) { store in
              TwoCountersView(store: store)
            }
          }

          NavigationLink("Bindings") {
            Demo(store: Store(initialState: BindingBasics.State()) { BindingBasics() }) { store in
              BindingBasicsView(store: store)
            }
          }

          NavigationLink("Bindings Form") {
            Demo(store: Store(initialState: BindingForm.State()) { BindingForm() }) { store in
              BindingsForm(store: store)
            }
          }

          NavigationLink("Optional state") {
            Demo(store: Store(initialState: OptionalBasics.State()) { OptionalBasics() }) { store in
              OptionalBasicsView(store: store)
            }
          }

          NavigationLink("Multiple destinations") {
            Demo(
              store: Store(initialState: MultipleDestinations.State()) { MultipleDestinations() }
            ) { store in
              MultipleDestinationsView(store: store)
            }
          }

          NavigationLink("Alerts and Confirmation Dialogs") {
            Demo(
              store: Store(initialState: AlertAndConfirmationDialog.State()) {
                AlertAndConfirmationDialog()
              }
            ) { store in
              AlertAndConfirmationDialogView(store: store)
            }
          }

          NavigationLink("Focus State") {
            Demo(store: Store(initialState: FocusStateDemo.State()) { FocusStateDemo() }) { store in
              FocusStateView(store: store)
            }
          }

          NavigationLink("Animations") {
            Demo(store: Store(initialState: Animations.State()) { Animations() }) { store in
              AnimationsView(store: store)
            }
          }
        }

        Section {

          NavigationLink("In memory") {
            Demo(
              store: Store(initialState: SharedStateInMemory.State()) { SharedStateInMemory() }
            ) { store in
              SharedStateInMemoryView(store: store)
            }
          }

          NavigationLink("User defaults") {
            Demo(
              store: Store(initialState: SharedStateUserDefaults.State()) {
                SharedStateUserDefaults()
              }
            ) { store in
              SharedStateUserDefaultsView(store: store)
            }
          }

          NavigationLink("Notification") {
            Demo(
              store: Store(initialState: SharedStateNotifications.State()) {
                SharedStateNotifications()
              }
            ) { store in
              SharedStateNotificationsView(store: store)
            }
          }

          NavigationLink("File storage") {
            Demo(
              store: Store(initialState: SharedStateFileStorage.State()) {
                SharedStateFileStorage()
              }
            ) { store in
              SharedStateFileStorageView(store: store)
            }
          }


        }

      }
    }
  }
}

struct Demo<State, Action, Content: View>: View {
  @SwiftUI.State var store: Store<State, Action>
  let content: (Store<State, Action>) -> Content

  init(
    store: Store<State, Action>,
    @ViewBuilder content: @escaping (Store<State, Action>) -> Content
  ) {
    self.store = store
    self.content = content
  }

  var body: some View {
    content(store)
  }
}

#Preview {
  RootView()
}
