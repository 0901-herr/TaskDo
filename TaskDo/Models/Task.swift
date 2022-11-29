//
//  Task.swift
//  TaskDo
//
//  Created by Philippe Yong on 25/01/2021.
//

import Foundation
import FirebaseFirestoreSwift

struct Task: Codable {
    @DocumentID var id: String? // Firebase
    let taskTitle: String
    let taskColorIndex: Int
    
    let taskWorkDays: [Int]
    let taskWorkDate: Date?
    let taskWorkDaysReminderId: [UUID]?
    let taskWorkDaysReminderDate: Date?
//    let taskDueDayReminderDate: Date?
    
    let activities: [Activity]
    let createdAt: Date
//    let position: Int
    let userId: String
}

struct Activity: Codable {
    let date: Date
    let isComplete: Bool
}

struct TaskOrder: Codable {
    @DocumentID var id: String?
    let order: [TaskInfo]
}

struct TaskInfo: Codable {
    let taskId: String
    let position: Int
}


