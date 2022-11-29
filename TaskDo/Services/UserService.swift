//
//  UserService.swift
//  TaskDo
//
//  Created by Philippe Yong on 25/01/2021.
//

import Combine
import FirebaseAuth

protocol UserServiceProtocol {
    var currentUser: User? { get }
    func currentUserPublisher() -> AnyPublisher<User?, Never>
    func signInAnonymously() -> AnyPublisher<User, TaskDoError>
    func observeAuthChanges() -> AnyPublisher<User?, Never>
    func linkAccount(email: String, password: String) -> AnyPublisher<Void, TaskDoError>
    func logout() -> AnyPublisher<Void, TaskDoError>
    func login(email: String, password: String) -> AnyPublisher<Void, TaskDoError>
}

final class UserService: UserServiceProtocol {
    
    let currentUser = Auth.auth().currentUser
    
    func currentUserPublisher() -> AnyPublisher<User?, Never> {
        Just(Auth.auth().currentUser).eraseToAnyPublisher()
    }
    
    func signInAnonymously() -> AnyPublisher<User, TaskDoError> {
        return Future<User, TaskDoError> { promise in
            Auth.auth().signInAnonymously { result, error in
                if let error = error {
                    return promise(.failure(.auth(description: error.localizedDescription)))
                }
                else if let user = result?.user {
                    return promise(.success(user))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func observeAuthChanges() -> AnyPublisher<User?, Never> {
        Publishers.Authpublisher().eraseToAnyPublisher()
    }
    
    func linkAccount(email: String, password: String) -> AnyPublisher<Void, TaskDoError> {
        let emailCredential = EmailAuthProvider.credential(withEmail: email, password: password)
        return Future<Void, TaskDoError> { promise in
            Auth.auth().currentUser?.link(with: emailCredential) { result, error in
                if let error = error {
                    return promise(.failure(.default(description: error.localizedDescription)))
                }
                else if let user = result?.user {
                    Auth.auth().updateCurrentUser(user) { error in
                        if let error = error {
                            return promise(.failure(.default(description: error.localizedDescription)))
                        }
                        else {
                            return promise(.success(()))
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, TaskDoError> {
        return Future<Void, TaskDoError> { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            }
            catch {
                promise(.failure(.default(description: error.localizedDescription)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func login(email: String, password: String) -> AnyPublisher<Void, TaskDoError> {
        return Future<Void, TaskDoError> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(.default(description: error.localizedDescription)))
                }
                else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
