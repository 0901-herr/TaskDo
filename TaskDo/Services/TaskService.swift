//
//  ChallengeService.swift
//  TaskDo
//
//  Created by Philippe Yong on 25/01/2021.
//

import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol TaskServiceProtocol {
    func create(_ challenge: Task, _ taskId: String) -> AnyPublisher<Void, TaskDoError>
    func observeChallenges(userId: UserId) -> AnyPublisher<[Task], TaskDoError>
    func delete(_ challengeId: String) -> AnyPublisher<Void, TaskDoError>
    func updateChallenge(_ challengeId: String, activities: [Activity]) -> AnyPublisher<Void, TaskDoError>
}

final class TaskService: TaskServiceProtocol {
    private let db = Firestore.firestore()
    
    func create(_ task: Task, _ taskId: String) -> AnyPublisher<Void, TaskDoError> {
        print(taskId)
        return Future<Void, TaskDoError> { promise in
            do {
                _ = try self.db.collection("tasks").document(taskId).setData(from: task) { error in
                    if let error = error {
                        promise(.failure(.default(description: error.localizedDescription)))
                    }
                    else {
                        promise(.success(()))
                    }
                }
                promise(.success(()))
            }
            catch {
                promise(.failure(.default()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func observeChallenges(userId: UserId) -> AnyPublisher<[Task], TaskDoError> {
        let query = db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: false)
        //                    .order(by: "isComplete", descending: true)
        
        return Publishers.QuerySnapshotPublisher(query: query)
            .flatMap { snapshot -> AnyPublisher<[Task], TaskDoError> in
                do {
                    let task = try snapshot.documents.compactMap {
                        try $0.data(as: Task.self)
                    }
                    return Just(task)
                        .setFailureType(to: TaskDoError.self)
                        .eraseToAnyPublisher()
                }
                catch {
                    return Fail(error: .default(description: "Parsing error"))
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func delete(_ taskId: String) -> AnyPublisher<Void, TaskDoError> {
        print("TASK ID: \(taskId)")
        return Future<Void, TaskDoError> { promise in
            self.db.collection("tasks").document(taskId).delete() { error in
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
    
    func updateChallenge(_ taskId: String, activities: [Activity]) -> AnyPublisher<Void, TaskDoError> {
        return Future<Void, TaskDoError> { promise in
            self.db.collection("tasks").document(taskId).updateData(
                ["activities": activities.map {
                    return ["date": $0.date, "isComplete": $0.isComplete]
                }]
            ) { error in
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






protocol TaskOrderServiceProtocol {
    func create(_ task: TaskOrder, _ taskId: String) -> AnyPublisher<Void, TaskDoError>
    func observeChallenges(userId: UserId) -> AnyPublisher<[TaskOrder], TaskDoError>
    func delete(_ taskId: String) -> AnyPublisher<Void, TaskDoError>
    func updateChallenge(_ taskId: String, order: [TaskInfo]) -> AnyPublisher<Void, TaskDoError>
}

final class TaskOrderService: TaskOrderServiceProtocol {
    private let db = Firestore.firestore()
    
    func create(_ task: TaskOrder, _ taskId: String) -> AnyPublisher<Void, TaskDoError> {
        return Future<Void, TaskDoError> { promise in
            do {
                _ = try self.db.collection("tasksOrder").document(taskId).setData(from: task) { error in
                    if let error = error {
                        promise(.failure(.default(description: error.localizedDescription)))
                    }
                    else {
                        promise(.success(()))
                    }
                }
                promise(.success(()))
            }
            catch {
                promise(.failure(.default()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func observeChallenges(userId: UserId) -> AnyPublisher<[TaskOrder], TaskDoError> {
        let query = db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
        
        return Publishers.QuerySnapshotPublisher(query: query)
            .flatMap { snapshot -> AnyPublisher<[TaskOrder], TaskDoError> in
                do {
                    let task = try snapshot.documents.compactMap {
                        try $0.data(as: TaskOrder.self)
                    }
                    return Just(task)
                        .setFailureType(to: TaskDoError.self)
                        .eraseToAnyPublisher()
                }
                catch {
                    return Fail(error: .default(description: "Parsing error"))
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func delete(_ taskId: String) -> AnyPublisher<Void, TaskDoError> {
        return Future<Void, TaskDoError> { promise in
            self.db.collection("tasksOrder").document(taskId).delete() { error in
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
    
    func updateChallenge(_ taskId: String, order: [TaskInfo]) -> AnyPublisher<Void, TaskDoError> {
        return Future<Void, TaskDoError> { promise in
            self.db.collection("tasksOrder").document(taskId).updateData(
                ["order": order.map {
                    return ["taskId": $0.taskId, "position": $0.position]
                }]
            ) { error in
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
