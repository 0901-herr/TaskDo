//
//  DefaultSettings.swift
//  TaskDo
//
//  Created by Philippe Yong on 26/01/2021.
//

import SwiftUI

class DefaultSettings: ObservableObject {
    @Environment(\.colorScheme) var colorScheme
    var frameWidth = UIScreen.main.bounds.width * 0.9
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    var weekDays = ["M", "T", "W", "T", "F", "S", "S"]
    @Published var defaultValues: UserDefaults = UserDefaults.standard
    
    @Published var tone = Color.themeOrange
    
    init() {
        self.tone = Color.taskColors[defaultValues.integer(forKey: "intervalValue")]
        if defaultValues.integer(forKey: "selectedTimerValueIndex") == 0 {
            self.defaultValues.set(60, forKey: "selectedTimerValueIndex")
            self.defaultValues.set(1, forKey: "intervalValue")
        }
    }
    
    public func getFormattedDateI(_ date: Date) -> String {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = "dd.MM"
        
        return formattedDate.string(from: date)
    }

    public func getFormattedDateII(_ date: Date) -> String {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = "dd.MM yyyy"
        
        return formattedDate.string(from: date)
    }

    public func getFormattedDateIII(_ date: Date) -> String {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = "h:mm a"
        
        return formattedDate.string(from: date)
    }
    
    public func getFormattedDateIV(_ date: Date) -> String {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = "MMMM"
        
        return formattedDate.string(from: date)
    }
    
    public func getFormattedDateV(_ date: Date) -> String {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = "yyyy"
        
        return formattedDate.string(from: date)
    }
}
