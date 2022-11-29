//
//  Stats.swift
//  TaskDo
//
//  Created by Philippe Yong on 29/01/2021.
//

import Foundation
import FirebaseFirestoreSwift

struct Stats: Codable {
    let id: String? // Firebase
    let taskTitle: String
    let taskColorIndex: Int
    let record: [Record]
    let userId: String
}


struct Record: Codable {
    let focusRecord: [FocusRecord]
    let selectedTagIndex: Int
}

struct FocusRecord: Codable {
    let date: Date
    let focusTime: Int // in seconds
}

