import ComposableArchitecture
import SwiftUI

@Reducer
struct EffectsBasics {

  @ObservableState
  struct State: Equatable {
    var count = 0
    var isNumberFactRequestInFlight = false
    var numberFact: String?
  }

  enum Action {
    case decrementButtonTapped
    case decrementDelayResponse
    case incrementButtonTapped
    case numberFactButtonTapped
    case numberFactResponse(Result<String, any Error>)
  }

  @Dependency(\.continuousClock) var clock
  @Dependency(\.factClient) var factClient
  private enum CancelID { case delay }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .decrementButtonTapped:
        state.count -= 1
        state.numberFact = nil
        return state.count >= 0
        ? .none
        : .run { send in
          try await self.clock.sleep(for: .seconds(1))
          await send(.decrementDelayResponse)
        }
        .cancellable(id: CancelID.delay)

      case .decrementDelayResponse:
        if state.count < 0 {
          state.count += 1
        }
        return .none

      case .incrementButtonTapped:
        state.count += 1
        state.numberFact = nil
        return state.count >= 0 ? .cancel(id: CancelID.delay) : .none

      case .numberFactButtonTapped:
        state.isNumberFactRequestInFlight = true
        state.numberFact = nil
        return .run { [count = state.count] send in
          await send(.numberFactResponse(Result { try await self.factClient.fetch(count) }))
        }

      case let .numberFactResponse(.success(response)):
        state.isNumberFactRequestInFlight = false
        state.numberFact = response
        return .none

      case .numberFactResponse(.failure(let error)):
        state.isNumberFactRequestInFlight = false
        return .none
      }
    }
  }
}

struct EffectsBasicsView: View {
  let store: StoreOf<EffectsBasics>
  @Environment(\.openURL) var openURL

  var body: some View {
    Form {
      Section {
        HStack {
          Button {
            store.send(.decrementButtonTapped)
          } label: {
            Image(systemName: "minus")
          }

          Text("\(store.count)")
            .monospacedDigit()

          Button {
            store.send(.incrementButtonTapped)
          } label: {
            Image(systemName: "plus")
          }
        }
        .frame(maxWidth: .infinity)

        Button("Number fact") { store.send(.numberFactButtonTapped) }
          .frame(maxWidth: .infinity)

        if store.isNumberFactRequestInFlight {
          ProgressView()
            .frame(maxWidth: .infinity)
          // NB: There seems to be a bug in SwiftUI where the progress view does not show
          // a second time unless it is given a new identity.
            .id(UUID())
        }

        if let numberFact = store.numberFact {
          Text(numberFact)
        }
      }

      Section {
        Button("Number facts provided by numbersapi.com") {
          openURL(URL(string: "http://numbersapi.com")!)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
      }
    }
    .buttonStyle(.borderless)
    .navigationTitle("Effects")
  }
}

