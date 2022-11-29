//
//  NotesService.swift
//  TaskDo
//
//  Created by Philippe Yong on 02/02/2021.
//

import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol NotesServiceProtocol {
    func create(_ notes: Notes) -> AnyPublisher<Void, TaskDoError>
    func observeChallenges(userId: UserId) -> AnyPublisher<[Notes], TaskDoError>
    func delete(_ challengeId: String) -> AnyPublisher<Void, TaskDoError>
}

final class NotesService: NotesServiceProtocol {
    
    private let db = Firestore.firestore()
    
    func create(_ notes: Notes) -> AnyPublisher<Void, TaskDoError> {
        return Future<Void, TaskDoError> { promise in
            do {
                _ = try self.db.collection("notes").document(notes.id!).setData(from: notes)  { error in
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
        
        
//         let docData: [String: Any] = [
//             "notes": [
//                 ["date": notes.notes.date,
//                  "notes": notes.notes.text]
//             ],
//            "userId": notes.userId
//         ]
//
//         let docRef = self.db.collection("notes").document(notes.id!)
//
//         return Future<Void, TaskDoError> { promise in
//             docRef.getDocument { (document, error) in
//                 docRef.setData(docData, merge: true) { error in
//                     if let error = error {
//                         promise(.failure(.default(description: error.localizedDescription)))
//                     }
//                     else {
//                         promise(.success(()))
//                     }
//                 }
//             }
//         }
//         .eraseToAnyPublisher()
    }
    
    func observeChallenges(userId: UserId) -> AnyPublisher<[Notes], TaskDoError> {
        let query = db.collection("notes")
            .whereField("userId", isEqualTo: userId)
        
        return Publishers.QuerySnapshotPublisher(query: query)
            .flatMap { snapshot -> AnyPublisher<[Notes], TaskDoError> in
                do {
                    let notes = try snapshot.documents.compactMap {
                        try $0.data(as: Notes.self)
                    }
                    return Just(notes)
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
            self.db.collection("notes").document(taskId).delete() { error in
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
