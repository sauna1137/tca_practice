import ComposableArchitecture
import SwiftUI

struct PokemonListView: View {
  let store: StoreOf<PokemonList>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      NavigationStack {
        Group {
          if viewStore.isLoading {
            ProgressView()
          } else if let error = viewStore.error {
            Text(error)
              .foregroundColor(.red)
          } else {
            ScrollView {
              LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 150))
              ], spacing: 20) {
                ForEach(viewStore.pokemons) { pokemon in
                  VStack {
                    AsyncImage(url: URL(string: pokemon.imageUrl)) { image in
                      image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    } placeholder: {
                      ProgressView()
                    }
                    .frame(width: 100, height: 100)
                    
                    Text(pokemon.name.capitalized)
                      .font(.caption)
                  }
                  .padding()
                  .background(Color.gray.opacity(0.1))
                  .cornerRadius(10)
                }
              }
              .padding()
            }
          }
        }
        .navigationTitle("Pokemon List")
      }
      .onAppear { viewStore.send(.onAppear) }
    }
  }
} 