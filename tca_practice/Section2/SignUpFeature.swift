////
////  SignUpFeature.swift
////  tca_practice
////
////  Created by KS on 2024/12/29.
////
//
//import ComposableArchitecture
//import SwiftUI
//
//struct SignUpData: Equatable {
//  var email = ""
//  var firstName = ""
//  var lastName = ""
//  var password = ""
//  var passwordConfirmation = ""
//  var phoneNumber = ""
//  var topics: Set<Topic> = []
//
//  enum Topic: String, Identifiable, CaseIterable {
//    case composableArchitecture = "Composable Architecture"
//    case concurrency = "Concurrency"
//    case modernSwiftUI = "Modern SwiftUI"
//    case swiftUI = "SwiftUI"
//    case testing = "Testing"
//    var id: Self { self }
//  }
//}
//
//@Reducer
//private struct SignUpFeature {
//  @Reducer
//  enum Path {
//    case basics(BasicsFeature)
//    case personalInfo(PersonalInfoFeature)
//    case summary(SummaryFeature)
//    case topics(TopicsFeature)
//  }
//  @ObservableState
//  struct State {
//    var path = StackState<Path.State>()
//    @Shared var signUpData: SignUpData
//  }
//
//  enum Action {
//    case path(StackActionOf<Path>)
//  }
//  var body: some ReducerOf<Self> {
//    Reduce { state, action in
//      switch action {
//      case .path(.element(id: _, action: .topics(.delegate(.stepFinished)))):
//        state.path.append(.summary(SummaryFeature.State(signUpData: state.$signUpData)))
//        return .none
//
//      case .path:
//        return .none
//      }
//    }
//    .forEach(\.path, action: \.path)
//  }
//}
//
//struct SignUpFlow: View {
//  @Bindable private var store = Store(
//    initialState: SignUpFeature.State(signUpData: Shared(SignUpData()))
//  ) {
//    SignUpFeature()
//  }
//
//  var body: some View {
//    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
//      Form {
//        Section {
//          NavigationLink(
//            "Sign up",
//            state: SignUpFeature.Path.State.basics(
//              BasicsFeature.State(signUpData: store.$signUpData)
//            )
//          )
//        }
//      }
//      .navigationTitle("Sign up")
//    } destination: { store in
//      switch store.case {
//      case let .basics(store):
//        BasicsStep(store: store)
//      case let .personalInfo(store):
//        PersonalInfoStep(store: store)
//      case let .summary(store):
//        SummaryStep(store: store)
//      case let .topics(store):
//        TopicsStep(store: store)
//      }
//    }
//  }
//}
//
//@Reducer
//private struct BasicsFeature {
//  @ObservableState
//  struct State {
//    var isEditingFromSummary = false
//    @Shared var signUpData: SignUpData
//  }
//  enum Action: BindableAction {
//    case binding(BindingAction<State>)
//  }
//  var body: some ReducerOf<Self> {
//    BindingReducer()
//  }
//}
//
//private struct BasicsStep: View {
//  @Environment(\.dismiss) private var dismiss
//  @Bindable var store: StoreOf<BasicsFeature>
//
//  var body: some View {
//    Form {
//
//      Section {
//        SecureField("Password", text: $store.signUpData.password)
//        SecureField("Password confirmation", text: $store.signUpData.passwordConfirmation)
//      }
//    }
//    .navigationTitle("Basics")
//    .toolbar {
//      if store.isEditingFromSummary {
//        Button("Done") {
//          dismiss()
//        }
//      } else {
//        NavigationLink(
//          state: SignUpFeature.Path.State.personalInfo(
//            PersonalInfoFeature.State(signUpData: store.$signUpData)
//          )) {
//            Text("Next")
//          }
//      }
//    }
//  }
//}
//
//@Reducer
//private struct PersonalInfoFeature {
//  @ObservableState
//  struct State {
//    var isEditingFromSummary = false
//    @Shared var signUpData: SignUpData
//  }
//  enum Action: BindableAction {
//    case binding(BindingAction<State>)
//  }
//  @Dependency(\.dismiss) var dismiss
//  var body: some ReducerOf<Self> {
//    BindingReducer()
//  }
//}
//
//private struct PersonalInfoStep: View {
//  @Environment(\.dismiss) private var dismiss
//  @Bindable var store: StoreOf<PersonalInfoFeature>
//
//  var body: some View {
//    Form {
//      Section {
//        TextField("First name", text: $store.signUpData.firstName)
//        TextField("Last name", text: $store.signUpData.lastName)
//        TextField("Phone number", text: $store.signUpData.phoneNumber)
//      }
//    }
//    .navigationTitle("Personal Info")
//    .toolbar {
//      ToolbarItem {
//        if store.isEditingFromSummary {
//          Button("Done") {
//            dismiss
//          }
//        } else {
//          NavigationLink(
//            "Next",
//            state: SignUpFeature.Path.State.topics(
//              TopicsFeature.State(topics: store.$signUpData.topics)
//            )
//          )
//        }
//      }
//    }
//  }
//}
//
//@Reducer
//private struct TopicsFeature {
//  @ObservableState
//  struct State {
//    @Presents var alert: AlertState<Never>?
//    var isEditingFromSummary = false
//    @Shared var topics: Set<SignUpData.Topic>
//  }
//  enum Action: BindableAction {
//    case alert(PresentationAction<Never>)
//    case binding(BindingAction<State>)
//    case delegate(Delegate)
//    case doneButtonTapped
//    case nextButtonTapped
//    enum Delegate {
//      case stepFinished
//    }
//  }
//  @Dependency(\.dismiss) var dismiss
//  var body: some ReducerOf<Self> {
//    BindingReducer()
//    Reduce { state, action in
//      switch action {
//      case .alert:
//        return .none
//      case .binding:
//        return .none
//      case .delegate:
//        return .none
//      case .doneButtonTapped:
//        if state.topics.isEmpty {
//          state.alert = AlertState {
//            TextState("Please choose at least one topic.")
//          }
//          return .none
//        } else {
//          return .run { _ in await dismiss() }
//        }
//      case .nextButtonTapped:
//        if state.topics.isEmpty {
//          state.alert = AlertState {
//            TextState("Please choose at least one topic.")
//          }
//          return .none
//        } else {
//          return .send(.delegate(.stepFinished))
//        }
//      }
//    }
//    .ifLet(\.alert, action: \.alert)
//  }
//}
//
//private struct TopicsStep: View {
//  @Bindable var store: StoreOf<TopicsFeature>
//
//  var body: some View {
//    Form {
//      Section {
//        ForEach(SignUpData.Topic.allCases) { topic in
//          Toggle(isOn: $store.topics[contains: topic]) {
//            Text(topic.rawValue)
//          }
//        }
//      }
//    }
//    .navigationTitle("Topics")
//    .alert($store.scope(state: \.alert, action: \.alert))
//    .toolbar {
//      ToolbarItem {
//        if store.isEditingFromSummary {
//          Button("Done") {
//            store.send(.doneButtonTapped)
//          }
//        } else {
//          Button("Next") {
//            store.send(.nextButtonTapped)
//          }
//        }
//      }
//    }
//    .interactiveDismissDisabled()
//  }
//}
//
//@Reducer
//private struct SummaryFeature {
//  @Reducer
//  enum Destination {
//    case alert(AlertState<Never>)
//    case basics(BasicsFeature)
//    case personalInfo(PersonalInfoFeature)
//    case topics(TopicsFeature)
//  }
//  @ObservableState
//  struct State {
//    @Presents var destination: Destination.State?
//    @Shared var signUpData: SignUpData
//  }
//  enum Action {
//    case destination(PresentationAction<Destination.Action>)
//    case editFavoriteTopicsButtonTapped
//    case editPersonalInfoButtonTapped
//    case editRequiredInfoButtonTapped
//    case submitButtonTapped
//  }
//  var body: some ReducerOf<Self> {
//    Reduce { state, action in
//      switch action {
//      case .destination(_):
//        return .none
//      case .editFavoriteTopicsButtonTapped:
//        state.destination = .topics(
//          TopicsFeature.State(
//            isEditingFromSummary: true,
//            topics: state.$signUpData.topics
//          )
//        )
//      case .editPersonalInfoButtonTapped:
//        state.destination = .personalInfo(
//          PersonalInfoFeature.State(
//            isEditingFromSummary: true,
//            signUpData: state.$signUpData
//          )
//        )
//      case .editRequiredInfoButtonTapped:
//        state.destination = .basics(
//          BasicsFeature.State(
//            isEditingFromSummary: true,
//            signUpData: state.$signUpData
//          )
//        )
//      case .submitButtonTapped:
//        state.destination = .alert(
//          AlertState {
//            TextState("Thank you for signing up!")
//          }
//        )
//        return .none
//      }
//    }
//    .ifLet(\.$destination, action: \.destination)
//  }
//}
//
//private struct SummaryStep: View {
//  @Bindable var store: StoreOf<SummaryFeature>
//
//  var body: some View {
//    Form {
//      Section {
//        Text(store.signUpData.email)
//        Text(String(repeating: "•", count: store.signUpData.password.count))
//      } header: {
//        HStack {
//          Text("Required info")
//          Spacer()
//          Button("Edit") {
//            store.send(.editRequiredInfoButtonTapped)
//          }
//          .font(.caption)
//        }
//      }
//
//      Section {
//        Text(store.signUpData.firstName)
//        Text(store.signUpData.lastName)
//        Text(store.signUpData.phoneNumber)
//      } header: {
//        HStack {
//          Text("Personal info")
//          Spacer()
//          Button("Edit") {
//            store.send(.editPersonalInfoButtonTapped)
//          }
//          .font(.caption)
//        }
//      }
//
//      Section {
//        ForEach(store.signUpData.topics.sorted(by: { $0.rawValue < $1.rawValue })) { topic in
//          Text(topic.rawValue)
//        }
//      } header: {
//        HStack {
//          Text("Favorite topics")
//          Spacer()
//          Button("Edit") {
//            store.send(.editFavoriteTopicsButtonTapped)
//          }
//          .font(.caption)
//        }
//      }
//
//      Section {
//        Button {
//          store.send(.submitButtonTapped)
//        } label: {
//          Text("Submit")
//        }
//      }
//    }
//    .navigationTitle("Summary")
//    .sheet(
//      item: $store.scope(state: \.destination?.basics, action: \.destination.basics)
//    ) { basicsStore in
//      NavigationStack {
//        BasicsStep(store: basicsStore)
//      }
//      .presentationDetents([.medium])
//    }
//    .sheet(
//      item: $store.scope(state: \.destination?.personalInfo, action: \.destination.personalInfo)
//    ) { personalStore in
//      NavigationStack {
//        PersonalInfoStep(store: personalStore)
//      }
//      .presentationDetents([.medium])
//    }
//    .sheet(
//      item: $store.scope(state: \.destination?.topics, action: \.destination.topics)
//    ) { topicsStore in
//      NavigationStack {
//        TopicsStep(store: topicsStore)
//      }
//      .presentationDetents([.medium])
//    }
//    .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
//  }
//}
//
//extension Set {
//  fileprivate subscript(contains element: Element) -> Bool {
//    get { contains(element) }
//    set {
//      if newValue {
//        insert(element)
//      } else {
//        remove(element)
//      }
//    }
//  }
//}
