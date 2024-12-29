//
//  SharedStateNotification.swift
//  tca_practice
//
//  Created by KS on 2024/12/18.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct SharedStateNotifications {
  @ObservableState
  struct State: Equatable {
    var fact: String?
    @SharedReader(.screenshotCount) var screenshotCount = 0
  }
  enum Action {
    case factResponse(Result<String, any Error>)
    case onAppear
  }
  @Dependency(\.factClient) var factClient
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .factResponse(.success(fact)):
        state.fact = fact
        return .none

      case .factResponse(.failure):
        return .none

      case .onAppear:
        return .run { [screenshotCount = state.$screenshotCount] send in
          for await count in screenshotCount.publisher.values {
            await send(.factResponse(Result { try await factClient.fetch(count) }))
          }
        }
      }
    }
  }
}

struct SharedStateNotificationsView: View {
  let store: StoreOf<SharedStateNotifications>

  var body: some View {
    Form {
      Text("A screenshot of this screen has been taken \(store.screenshotCount) times.")
        .font(.headline)

      if let fact = store.fact {
        Text("\(fact)")
      }
    }
    .navigationTitle("Long-living effects")
    .task { await store.send(.onAppear).finish() }
  }
}

extension PersistenceReaderKey where Self == NotificationReaderKey<Int> {
  static var screenshotCount: Self {
    NotificationReaderKey(
      initialValue: 0,
      name: MainActor.assumeIsolated {
        UIApplication.userDidTakeScreenshotNotification
      }
    ) { value, _ in
      value += 1
    }
  }
}

struct NotificationReaderKey<Value: Sendable>: PersistenceReaderKey {
  let name: Notification.Name
  private let transform: @Sendable (Notification) -> Value

  init(
    initialValue: Value,
    name: Notification.Name,
    transform: @Sendable @escaping (inout Value, Notification) -> Void
  ) {
    self.name = name
    let value = LockIsolated(initialValue)
    self.transform = { notification in
      value.withValue { [notification = UncheckedSendable(notification)] in
        transform(&$0, notification.wrappedValue)
      }
      return value.value
    }
  }

  var id: some Hashable { self.name }

  func load(initialValue: Value?) -> Value? { nil }

  func subscribe(
    initialValue: Value?,
    didSet: @Sendable @escaping (Value?) -> Void
  ) -> Shared<Value>.Subscription {
    let token = NotificationCenter.default.addObserver(
      forName: name,
      object: nil,
      queue: nil,
      using: { notification in
        didSet(transform(notification))
      }
    )
    return Shared.Subscription {
      NotificationCenter.default.removeObserver(token)
    }
  }

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.name == rhs.name
  }
  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }
}
