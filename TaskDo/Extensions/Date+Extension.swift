//
//  Date+Extension.swift
//  TaskDo
//
//  Created by Philippe Yong on 26/01/2021.
//

import SwiftUI

extension Date {
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
    
    var last7days: [Int] {
        return (1...7).map {
            adding(days: -$0).day
        }
    }
    
    func near(days: Int) -> [Int] {
        return days == 0 ? [day] : (1...abs(days)).map {
            adding(days: $0 * (days < 0 ? -1 : 1) ).day
        }
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func endOfDay(_ date: Date) -> Date {
        var components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    func getFutureWeekDates() -> [Date] {
        var thisWeekDate: [Date] = []
        
        let calendar = Calendar.current
        let today = Date()
        let midnight = calendar.startOfDay(for: today)
        var dayAfter = calendar.date(byAdding: .day, value: 1, to: midnight)!
        thisWeekDate.append(today)
        thisWeekDate.append(dayAfter)
        
        for _ in 0..<5 {
            dayAfter = calendar.date(byAdding: .day, value: 1, to: dayAfter)!
            thisWeekDate.append(dayAfter)
        }
        
        return thisWeekDate
    }
    
    func getThisWeekDates() -> [Date] {
        var thisWeekDate: [Date] = []
        
        let calendar = Calendar.current
        let today = Date()
        
        var todayInDay = Calendar.current.component(.weekday, from: today)
        
        if todayInDay == 1 {
            todayInDay = 6
        }
        else {
            todayInDay -= 2
        }
        
        var dayBefore = today
        for _ in 0..<todayInDay {
            dayBefore = calendar.date(byAdding: .day, value: -1, to: dayBefore)!
            thisWeekDate.append(dayBefore)
        }
        
        thisWeekDate.reverse()
        thisWeekDate.append(today)
        
        var dayAfter = today
        for _ in todayInDay+1..<7 {
            dayAfter = calendar.date(byAdding: .day, value: 1, to: dayAfter)!
            thisWeekDate.append(dayAfter)
        }
        
        return thisWeekDate
    }
    
    func getSelectedWeekDates(date: Date) -> [Date] {
        var thisWeekDate: [Date] = []
        
        let calendar = Calendar.current
        let selectedDate = date
        
        let selectedDateInDay = getWeekDay(date: selectedDate)
    
        var dayBefore = selectedDate
        
        for _ in 0..<selectedDateInDay {
            dayBefore = calendar.date(byAdding: .day, value: -1, to: dayBefore)!
            thisWeekDate.append(dayBefore)
        }
        
        thisWeekDate.reverse()
        thisWeekDate.append(selectedDate)
        
        var dayAfter = selectedDate
        for _ in selectedDateInDay+1..<7 {
            dayAfter = calendar.date(byAdding: .day, value: 1, to: dayAfter)!
            thisWeekDate.append(dayAfter)
        }
        
        return thisWeekDate

    }
    
    func getSelectedWeekDates(n: Int) -> [Date] {
        var weekDates: [Date] = []
        let calendar = Calendar.current
        let today = Date()
        var todayInDay = Calendar.current.component(.weekday, from: today)
        
        if todayInDay == 1 {
            todayInDay = 6
        }
        else {
            todayInDay -= 2
        }
        
        let startOfWeek = calendar.date(byAdding: .day, value: -(todayInDay+1), to: today)!
        let value = 7*n
        let startOfPickWeek = calendar.date(byAdding: .day, value: value, to: startOfWeek)!
        var day = startOfPickWeek
        
        for _ in 0..<7 {
            day = calendar.date(byAdding: .day, value: 1, to: day)!
            weekDates.append(day)
        }
        print("SELECTED WEEK DATES: \(weekDates)")
        return weekDates
    }
    
    func getSelectedWeekDays(n: Int) -> [WeekDay] {
        print("GET SELECTED WEEK DAYS IS CALLED")
        let selectedWeekDates = getSelectedWeekDates(n: n)
        var selectedWeekDays: [WeekDay] = []
        
        for dayIndex in 0..<7 {
            let format = DateFormatter()
            format.dateFormat = "d"
            let formattedDate = format.string(from: selectedWeekDates[dayIndex])

            selectedWeekDays.append(WeekDay(dayIndex: dayIndex, dayStrDate: formattedDate, dayDate: selectedWeekDates[dayIndex]))
        }
        
        return selectedWeekDays
    }
    
    func getFutureWeekDays() -> [WeekDay] {
        var thisWeekDays: [WeekDay] = []
        let futureWeekDates = getFutureWeekDates()
        
        for day in futureWeekDates {
            var weekday = Calendar.current.component(.weekday, from: day)
            weekday = getWeekDateIndex(weekday)
            
            let format = DateFormatter()
            format.dateFormat = "d"
            let date = day
            let formattedDate = format.string(from: date)
            
            thisWeekDays.append(WeekDay(dayIndex: weekday, dayStrDate: formattedDate, dayDate: date))
        }
        let sortedWeekDays = thisWeekDays.sorted { $0.dayIndex < $1.dayIndex }
        return sortedWeekDays
    }
    
    func getWeekDateIndex(_ weekDay: Int) -> Int{
        var index = weekDay
        if index == 1 {
            index = 6
        }
        else {
            index -= 2
        }
        return index
    }
    
    func getThisWeekDays() -> [WeekDay] {
        var thisWeekDays: [WeekDay] = []
        let thisWeekDates = getThisWeekDates()
        
        for day in thisWeekDates {
            let weekday = Calendar.current.component(.weekday, from: day)
            let dayIndex = getWeekDateIndex(weekday)
            let format = DateFormatter()
            format.dateFormat = "d"
            let date = day
            let formattedDate = format.string(from: date)
            
            thisWeekDays.append(WeekDay(dayIndex: dayIndex, dayStrDate: formattedDate, dayDate: date))
        }
        
        let sortedWeekDays = thisWeekDays.sorted { $0.dayIndex < $1.dayIndex }
        print("WEEK DAYS: \(sortedWeekDays)")
        return sortedWeekDays
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func getThisMonthDates() -> [Date] {
        let startOfMonth = self.startOfMonth()
        var thisMonthDate: [Date] = []
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: startOfMonth)
        
        let interval = calendar.dateInterval(of: .month, for: Date())!
        let numOfDays = calendar.dateComponents([.day], from: interval.start, to: interval.end).day!
        
        thisMonthDate.append(startOfMonth)
        var dayAfter = calendar.date(byAdding: .day, value: 1, to: midnight)!
        thisMonthDate.append(dayAfter)
        
        for _ in 0..<numOfDays-2 {
            dayAfter = calendar.date(byAdding: .day, value: 1, to: dayAfter)!
            thisMonthDate.append(dayAfter)
        }
        
        return thisMonthDate
    }
    
    func isLeapYear(_ year: Int) -> Bool {
        var flag = false
        if year % 4 == 0 {
            flag = true
        }
        else if (year % 100 == 0) {
            flag = true
        }
        else if (year % 400 == 0) {
            flag = true
        }
        else {
            flag = false
        }
        return flag
    }
    
    func getSelectedMonthDates(_ month: Int, _ year: Int) -> Int {
        var dayCount = 0
        if month == 2 {
            if isLeapYear(year){
                dayCount = 29
            }
            else {
                dayCount = 28
            }
        }
        else if month == 8 {
            dayCount = 31
        }
        else if month % 2 == 0 {
            dayCount = 30
        }
        else {
            dayCount = 31
        }
        return dayCount
    }
    
    func getNextDay(date: Date, _ action: Int) -> Date {
        var dayComponent = DateComponents()
        dayComponent.day = action // For removing one day (yesterday): -1
        let theCalendar = Calendar.current
        let nextDate = theCalendar.date(byAdding: dayComponent, to: date)
        return nextDate ?? Date()
    }
    
    
    func getWeekDates(_ date: Date) -> [Date] {
        var thisWeekDate: [Date] = []
        
        let calendar = Calendar.current
        let day = date
        
        var todayInDay = Calendar.current.component(.weekday, from: day)
        
        if todayInDay == 1 {
            todayInDay = 6
        }
        else {
            todayInDay -= 2
        }
        
        var dayBefore = day
        for _ in 0..<todayInDay {
            dayBefore = calendar.date(byAdding: .day, value: -1, to: dayBefore)!
            thisWeekDate.append(dayBefore)
        }
        
        thisWeekDate.reverse()
        thisWeekDate.append(day)
        
        var dayAfter = day
        for _ in todayInDay+1..<7 {
            dayAfter = calendar.date(byAdding: .day, value: 1, to: dayAfter)!
            thisWeekDate.append(dayAfter)
        }
        
//        print("FROM HERE")
        print("WEEK DATE: \(thisWeekDate)")
        return thisWeekDate
    }
    
    func startOfWeek(using calendar: Calendar = .gregorian) -> Date {
        calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
    
    static let weekdays = [
        "Mon",
        "Tue",
        "Wed",
        "Thu",
        "Fri",
        "Sat",
        "Sun"
    ]
    
    func getWeekDay(date: Date) -> Int {
        let weekday = Calendar.current.component(.weekday, from: date)
        return getWeekDateIndex(weekday)
    }
}

extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
}

struct WeekDay: Hashable {
    var dayIndex: Int
    var dayStrDate: String
    var dayDate: Date
}

