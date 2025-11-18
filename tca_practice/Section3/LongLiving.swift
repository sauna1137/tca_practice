//
//  LongLiving.swift
//  tca_practice
//
//  Created by KS on 2025/11/17.
//

@Reducer
struct LongLivingEffects {
  @ObservableState
  struct State: Equatable {
    var screenshotCount = 0
  }

  enum Action {
    case task
    case userDidTaskScreenshotNotification
  }

  @Dependency(\.screenshots) var screenshots

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .task:
        return .run { send in
          for await _ in await self.screenshots() {
            await send(.userDidTaskScreenshotNotification)
          }
        }

      case .userDidTaskScreenshotNotification:
        state.screenshotCount += 1
        return .none
      }
    }
  }
}

extension DependencyValues {
  var screenshots: @Sendable () async -> any AsyncSequence<Void, Never> {
    get { self[ScreenshotsKey.self] }
    set { self[ScreenshotsKey.self] = newValue }
  }
}

private enum ScreenshotsKey: DependencyKey {
  static let liveValue: @Sendable () async -> any AsyncSequence<Void, Never> = {
    NotificationCenter.default
      .notifications(named: UIApplication.userDidTakeScreenshotNotification)
      .map { _ in }
  }
}

struct LongLivingEffectsView: View {
  let store: StoreOf<LongLivingEffects>

  var body: some View {
    Form {
      Section {
        AboutView(readMe: readMe)
      }

      Text("A screenshot of this screen has been taken \(store.screenshotCount) times.")
        .font(.headline)

      Section {
        NavigationLink {
          detailView
        } label: {
          Text("See detail view")
        }
      }
    }
    .navigationTitle("Long-living effects")
    .task { await store.send(.task).finish() }
  }

  var detailView some View {
    Text(
      """
      take a screenshots of this screen a few times.
      """
    )
    .padding(.horizontal, 64)
    .navigationBarTitleDisplayMode(.inline)
  }

}


#Preview {
  NavigationStack {
    LongLivingEffectsView(
      store: Store(initialState: LongLivingEffects.State()) {
        LongLivingEffects()
      }
    )
  }
}
