import ComposableArchitecture
import Foundation

@Reducer
struct PokemonList {
  @ObservableState
  struct State: Equatable {
    var pokemons: [Pokemon] = []
    var isLoading = false
    var error: String?
  }
  
  enum Action {
    case onAppear
    case pokemonsResponse(TaskResult<[Pokemon]>)
  }
  
  @Dependency(\.pokemonClient) var pokemonClient
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.isLoading = true
        return .run { send in
          await send(
            .pokemonsResponse(
              await TaskResult {
                try await pokemonClient.fetchPokemons()
              }
            )
          )
        }
        
      case let .pokemonsResponse(.success(pokemons)):
        state.isLoading = false
        state.pokemons = pokemons
        return .none
        
      case let .pokemonsResponse(.failure(error)):
        state.isLoading = false
        state.error = error.localizedDescription
        return .none
      }
    }
  }
}

struct Pokemon: Equatable, Identifiable {
  let id: Int
  let name: String
  let imageUrl: String
}