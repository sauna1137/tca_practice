//
//  Refreshable.swift
//  tca_practice
//
//  Created by KS on 2025/11/17.
//

import Foundation

@Reducer
struct Refreshable {
  @ObservableState
  struct State: Equatable {
    var count = 0
    var fact: String?
  }

  enum Action {
    case cancelButtonTapped
    case decrementButtonTapped
    case factResponse(Result<String, any Error>)
    case incrementButtonTapped
    case refresh
  }

  @Dependency(\.factClient) var factClient
  private enum CancelID { case factRequest }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .cancelButtonTapped:
        return .cancel(id: CancelID.factRequest)

      case .decrementButtonTapped:
        state.count -= 1
        return .none

      case .factResponse(.success(fact)):
        state.fact = fact
        return .none

      case .factResponse(.failure):
        // NB: This is where you could do some error handling.
        return .none

      case .incrementButtonTapped:
        state.count += 1
        return .none

      case .refresh:
        state.fact = nil
        return .run { [Count = state.count] send in
          await send(.factResponse(Result { try await self.factClient.fetch(Count)})
          )
        }
        .cancellable(id: CancelID.factRequest)
      }
    }
  }
}

struct RefreshableView: View {
  let store: StoreOf<Refreshable>
  @State var isLoading = false

  var body: some View {
    List {
      Section {
        AboutView(store: store)
      }

      HStack {
        Button {
          store.send(.decrementButtonTapped)
        } label: {
          Image(systemName: "minus.circle")
        }

        Text("\(store.count)")
          .monospacedDigit()

        Button {
          store.send(.incrementButtonTapped)
        } label: {
          Image(systemName: "plus.circle")
        }
      }
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderless)

      if let fact = store.fact {
        Text(fact)
          .bold()
      }
      if self.isLoading {
        Button("Cancel") {
          store.send(.cancelButtonTapped)
        }
      }
    }
    .refreshable {
      isLoading = true
      defer { isLoading = false }
      await store.send(.refresh).finish()
    }
  }
}


#Preview {
  RefreshableView(
    store: Store(initialState: Refreshable.State()) {
      Refreshable()
    }
  )
}
