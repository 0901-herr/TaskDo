//
//  TaskItemProtocol.swift
//  TaskDo
//
//  Created by Philippe Yong on 25/01/2021.
//

import Foundation

protocol TaskItemProtocol {
    var selectedOptions: TaskOption { get set }
}

struct TaskOption {
    enum TaskOptionType {
        case text(String)
        case number(Int)
        case id(UUID)
    }
    
    let type: TaskOptionType
    let formatted: String
}
