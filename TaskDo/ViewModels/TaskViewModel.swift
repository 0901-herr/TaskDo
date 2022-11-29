//
//  TaskViewModel.swift
//  TaskDo
//
//  Created by Philippe Yong on 25/01/2021.
//

import Foundation

struct TaskViewModel: Identifiable, Equatable {
    static func ==(lhs: TaskViewModel, rhs: TaskViewModel) -> Bool {
        return lhs.id == rhs.id && lhs.id == rhs.id
    }

    private let task: Task
        
    var id: String {
        task.id!
    }
    
    private let onDelete: (String) -> Void
    private let onToggleComplete: (String, [Activity]) -> Void
    
    init(_ task: Task,
         onDelete: @escaping (String) -> Void,
         onToggleComplete: @escaping (String, [Activity]) -> Void
    ) {
        self.task = task
        self.onDelete = onDelete
        self.onToggleComplete = onToggleComplete
    }
    
    var workDays: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun", "Everyday"]
    
    var taskTitle: String {
        task.taskTitle
    }
    
    var taskColorIndex: Int {
        task.taskColorIndex
    }
    
    var taskWorkDays: [Int] {
        task.taskWorkDays
    }
    
    var taskWorkDate: Date? {
        task.taskWorkDate ?? nil
    }
    
    var taskWorkDaysReminderId: [UUID]? {
        task.taskWorkDaysReminderId ?? nil
    }
    
    var taskWorkDaysReminderStrDate: String {
        if task.taskWorkDaysReminderDate != nil {
            let formattedDate = DateFormatter()
            formattedDate.dateFormat = "h:mm a"
            
            return formattedDate.string(from: task.taskWorkDaysReminderDate!)
        }
        else {
            return ""
        }
    }
    
    var taskWorkDaysReminderDate: Date? {
        task.taskWorkDaysReminderDate ?? nil
    }
        
//    var taskDueDayReminderDate: Date? {
//        return task.taskDueDayReminderDate ?? nil
//    }
    
    var isTaskComplete: Bool {
        return task.activities[0].isComplete == true
    }
    
    var activities: [Activity] {
        task.activities
    }
    
    var createdAt: Date {
        task.createdAt
    }
    
    var userId: String {
        task.userId
    }
    
//    var position: Int {
//        task.position
//    }
    
    func send(action: Action) {
        guard let id = task.id else { return }
        switch action {
        case .delete:
            onDelete(id)
        case .toggleComplete:
            let activities = task.activities.map { activity -> Activity in
                return .init(date: Date(), isComplete: !activity.isComplete)
            }
            onToggleComplete(id, activities)
        }
    }
}

extension TaskViewModel {
    enum Action {
        case delete
        case toggleComplete
    }
}

