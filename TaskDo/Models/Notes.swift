//
//  Notes.swift
//  TaskDo
//
//  Created by Philippe Yong on 02/02/2021.
//

import Foundation
import FirebaseFirestoreSwift

struct Notes: Codable {
    let id: String? // Firebase
    let notes: [NotesItem]
    let userId: String
}

struct NotesItem: Codable, Hashable {
    let date: Date
    let text: String
}

