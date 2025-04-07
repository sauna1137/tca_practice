import ComposableArchitecture
import Foundation

struct PokemonClient {
  var fetchPokemons: @Sendable () async throws -> [Pokemon]
}

extension PokemonClient: DependencyKey {
  static let liveValue = PokemonClient(
    fetchPokemons: {
      let pokemons = try await withThrowingTaskGroup(of: Pokemon.self) { group in
        for id in 1...151 {
          group.addTask {
            let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PokemonResponse.self, from: data)
            return Pokemon(
              id: id,
              name: response.name,
              imageUrl: response.sprites.frontDefault
            )
          }
        }
        
        var results: [Pokemon] = []
        for try await pokemon in group {
          results.append(pokemon)
        }
        return results.sorted { $0.id < $1.id }
      }
      return pokemons
    }
  )
}

extension DependencyValues {
  var pokemonClient: PokemonClient {
    get { self[PokemonClient.self] }
    set { self[PokemonClient.self] = newValue }
  }
}

private struct PokemonResponse: Codable {
  let name: String
  let sprites: Sprites
  
  struct Sprites: Codable {
    let frontDefault: String
    
    enum CodingKeys: String, CodingKey {
      case frontDefault = "front_default"
    }
  }
} 