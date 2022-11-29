//
//  QuerySnapshotPublisher.swift
//  TaskDo
//
//  Created by Philippe Yong on 25/01/2021.
//

import Combine
import Firebase

extension Publishers {
    struct QuerySnapshotPublisher: Publisher {
        typealias Output = QuerySnapshot
        typealias Failure = TaskDoError
        
        private let query: Query
        
        init(query: Query) {
            self.query = query
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let querySnapshotSubscription = QuerySnapshotSubscription(subscriber: subscriber, query: query)
            subscriber.receive(subscription: querySnapshotSubscription)
        }
    }
    
    class QuerySnapshotSubscription<S: Subscriber>: Subscription where S.Input == QuerySnapshot, S.Failure == TaskDoError {
        private var subsriber: S?
        private var listner: ListenerRegistration?
        
        init(subscriber: S, query: Query) {
            listner = query.addSnapshotListener { querySnapshot, error in
                if let error = error {
                    subscriber.receive(completion: .failure(.default(description: error.localizedDescription)))
                }
                else if let querySnapshot = querySnapshot {
                    _ = subscriber.receive(querySnapshot)
                }
                else {
                    subscriber.receive(completion: .failure(.default()))
                }
            }
        }
        
        func request(_ demand: Subscribers.Demand) {}
        func cancel() {
            subsriber = nil
            listner = nil
        }
    }
}
