//
//  StatsService.swift
//  TaskDo
//
//  Created by Philippe Yong on 29/01/2021.
//
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift


protocol StatsServiceProtocol {
    func create(_ stats: Stats, record: Record) -> AnyPublisher<Void, TaskDoError>
    func observeChallenges(userId: UserId) -> AnyPublisher<[Stats], TaskDoError>
}

final class StatsService: StatsServiceProtocol {
    
    private let db = Firestore.firestore()
    
    func create(_ stats: Stats, record: Record) -> AnyPublisher<Void, TaskDoError> {
        let docRef = self.db.collection("stats").document(stats.id!)
        var recordList: [Record] = []
        
        return Future<Void, TaskDoError> { promise in
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    print("document exist in stats database")
                    if let records = document.get("record") as? [[String: Any]] {
                        for record in records {
                            let focusRecord = record["focusRecord"] as? [[String: Any]]
                            var recList: [FocusRecord] = []
                            
                            for rec in focusRecord! {
                                if let timeStamp = rec["date"] as? Timestamp {
                                    let date = timeStamp.dateValue()
                                    recList.append(FocusRecord(date: date, focusTime: rec["focusTime"] as? Int ?? 0))
                                }
                            }
                            
                            print("FOCUS RECORD: \(recList))")
                            
                            recordList.append(Record(focusRecord: recList, selectedTagIndex: record["selectedTagIndex"] as? Int ?? 5))
                        }
                    }
                    
                    recordList.append(record)
                    print("RECORD LIST: \(recordList)")
                    
                    let stats = Stats(id: stats.id, taskTitle: stats.taskTitle, taskColorIndex: stats.taskColorIndex, record: recordList, userId: stats.userId)
                    
                    do {
                        _ = try self.db.collection("stats").document(stats.id!).setData(from: stats) { error in
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
                else {
                    do {
                        _ = try self.db.collection("stats").document(stats.id!).setData(from: stats) { error in
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
            }
        }
        .eraseToAnyPublisher()
    }
    
    func observeChallenges(userId: UserId) -> AnyPublisher<[Stats], TaskDoError> {
        let query = db.collection("stats")
            .whereField("userId", isEqualTo: userId)
        
        return Publishers.QuerySnapshotPublisher(query: query)
            .flatMap { snapshot -> AnyPublisher<[Stats], TaskDoError> in
                do {
                    let stats = try snapshot.documents.compactMap {
                        try $0.data(as: Stats.self)
                    }
                    return Just(stats)
                        
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
}

final class StatsDataViewModel: ObservableObject {
    @Published var statsList: [Stats] = []
    private let db = Firestore.firestore()

    func getStats(userId: UserId) {
        db.collection("stats").whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snap, err in
            guard let docs = snap else {return}
            
            docs.documentChanges.forEach { doc in
                let stats = try! doc.document.data(as: Stats.self)
                self.statsList.append(stats!)
            }
            print("STATS LIST: \(self.statsList)")
        }
    }
}

