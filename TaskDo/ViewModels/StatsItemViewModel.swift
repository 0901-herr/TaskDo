//
//  StatsItemViewModel.swift
//  TaskDo
//
//  Created by Philippe Yong on 30/01/2021.
//

import Foundation

struct StatsItemViewModel: Identifiable {
    private let stats: Stats
        
    var id: String {
        stats.id!
    }
    
//    private let onDelete: (String) -> Void
//    private let onToggleComplete: (String, [Record]) -> Void
    
    init(_ stats: Stats//,
//         onDelete: @escaping (String) -> Void,
//         onToggleComplete: @escaping (String, [Record]) -> Void
    ) {
        self.stats = stats
//        self.onDelete = onDelete
//        self.onToggleComplete = onToggleComplete
    }
    
    var taskTitle: String {
        stats.taskTitle
    }
    
    var taskColorIndex: Int {
        stats.taskColorIndex
    }
    
    var userId: String {
        stats.userId
    }
    
    var record: [Record] {
        stats.record
    }
    
//    func send(action: TimerSaveValueAction) {
//        guard let id = stats.id else { return }
//        switch action {
//        case .delete:
//            onDelete(id)
//        case .toggleComplete:
//            let activities = stats.record.map { record -> Record in
//                return .init(date: Date(), focusTime: record.focusTime)
//            }
//            onToggleComplete(id, activities)
//        }
//    }
}

enum TimerSaveValueAction {
//    case delete
//    case toggleComplete
}
