//
//  Error.swift
//  TaskDo
//
//  Created by Philippe Yong on 25/01/2021.
//

import Foundation

enum TaskDoError: LocalizedError {
    case auth(description: String)
    case `default`(description: String? = nil)
    
    var errorDescription: String? {
        switch self {
        case let .auth(description):
            return description
        case let .default(description):
            return description ?? "Something went wrong"
        }
    }
}

