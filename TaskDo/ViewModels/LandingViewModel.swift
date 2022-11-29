//
//  LandingViewModel.swift
//  TaskDo
//
//  Created by Philippe Yong on 23/01/2021.
//

import SwiftUI
import Combine

final class LandingViewModel: ObservableObject {
    @Published var startPushed = false
    @Published var loginSignUpPushed = false
//    @Published var loginDefault: UserDefaults = UserDefaults.standard
    
    let title = "Welcome To TaskDo"
    var startButtonTitle = "Start"
    
    private let userService: UserServiceProtocol
    private var cancellables: [AnyCancellable] = []
    
    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }
    
    enum Action {
        case enterTaskListView
    }
    
    func send(action: Action) {
        switch action {
        case .enterTaskListView:
            currentUserId().sink { completion in
                switch completion {
                case let .failure(error):
                    print(error.localizedDescription)
                case .finished:
                    print("completed")
                }
            } receiveValue: { userId in
                print("retrieved userId = \(userId)")
            }
            .store(in: &cancellables)
            startPushed = true
//            self.loginDefault.set(self.startPushed, forKey: "startPushed")
        }
    }
    
    private func currentUserId() -> AnyPublisher<UserId, TaskDoError> {
        print("getting user id")
        return userService.currentUserPublisher().flatMap { user -> AnyPublisher<UserId, TaskDoError> in
//            return Fail(error: .auth(description: "Some firebase auth errr")).eraseToAnyPublisher()
            if let userId = user?.uid {
                print("user is logged in...")
                return Just(userId)
                    .setFailureType(to: TaskDoError.self)
                    .eraseToAnyPublisher()
            }
            else {
                print("user is being logged in anonymously...")
                return self.userService
                    .signInAnonymously()
                    .map { $0.uid }
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
    
//    func state() -> Bool {
//        self.startPushed = self.loginDefault.bool(forKey: "startPushed")
//        return self.startPushed
//    }
}
