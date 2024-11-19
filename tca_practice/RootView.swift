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
