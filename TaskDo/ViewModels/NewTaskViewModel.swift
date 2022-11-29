//
//  NewTaskViewModel.swift
//  TaskDo
//
//  Created by Philippe Yong on 24/01/2021.
//

import SwiftUI
import Combine
import UserNotifications

final class NewTaskViewModel: ObservableObject {
    @Published var taskId: String
    @Published var taskTitle: String
    @Published var taskColorIndex: Int
    
    @Published var taskWorkDays: [Int]
    @Published var taskWorkDate: Date
    @Published var taskWorkDaysReminderDate: Date
    @Published var taskWorkDaysReminderId: [UUID]
//    @Published var taskDueDayReminderDate: Date
    
    @Published var error: TaskDoError?
    
    @Published var workDaysReminderOn: Bool = false
    @Published var workDateIsSet: Bool = true
    @Published var dueDayIsSet: Bool = false
    @Published var editWorkDaysReminderOn: Bool = false
    @Published var createdAt = Date()
    @Published var editIsTapped = false

    private let userService: UserServiceProtocol
    private let taskService: TaskServiceProtocol
    private var cancellables: [AnyCancellable] = []
    
    let workDayslist: [String] = ["M", "T", "W", "T", "F", "S", "S", "Everyday"]
    let dueDaylist: [String] = ["M", "T", "W", "T", "F", "S", "S", "NONE"]

    init(
        taskId: String = "\(UUID())",
        taskTitle: String = "",
        taskColorIndex: Int = 0,
        taskWorkDays: [Int] = [],

        userService: UserServiceProtocol = UserService(),
        taskService: TaskServiceProtocol = TaskService()
    ) {
        print("NEW TASK VIEW IS INIT")
        self.taskId = taskId
        self.taskTitle = taskTitle
        self.taskColorIndex = taskColorIndex
        
        self.taskWorkDays = taskWorkDays
        self.taskWorkDate = Date()
        self.taskWorkDaysReminderId = []
        self.taskWorkDaysReminderDate = Date()
        
//        var components = DateComponents()
//        components.hour = 8
//        components.minute = 0
//        let date = Calendar.current.date(from: components) ?? Date()
//        self.taskDueDayReminderDate = date

        self.userService = userService
        self.taskService = taskService
    }
    
    
    enum Action {
        case createNewTask
    }
    
    func send(action: Action) {
        switch action {
        case .createNewTask:
            // set up reminder notifications
            setReminder()
            currentUserId().flatMap { userId -> AnyPublisher<Void, TaskDoError> in
                return self.createChallenge(userId: userId)
            }
            .sink { completion in
                switch completion {
                case let .failure(error):
                    self.error = error
                case .finished:
                    print("finished")
                    break
                }
            } receiveValue: { _ in
                print("success")
            }
            .store(in: &cancellables)

            self.workDaysReminderOn.toggle()
        }
    }
    
    private func currentUserId() -> AnyPublisher<UserId, TaskDoError> {
        print("getting user id")
        return userService.currentUserPublisher().flatMap { user -> AnyPublisher<UserId, TaskDoError> in
            if let userId = user?.uid {
                print("user is logged in...")
                return Just(userId)
                    .setFailureType(to: TaskDoError.self)
                    .eraseToAnyPublisher()
            }
            else {
                print("user is being logged in anonymously...")
                return self.userService
                    .signInAnonymously()
                    .map { $0.uid }
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func createChallenge(userId: UserId) -> AnyPublisher<Void, TaskDoError> {
        let taskTitle = self.taskTitle
        let taskColorIndex = self.taskColorIndex
        
        let taskWorkDays = self.taskWorkDays
        let taskWorkDate = self.workDateIsSet ? self.taskWorkDate : nil
        let taskWorkDaysReminderId = self.taskWorkDaysReminderId
        let taskWorkDaysReminderDate = self.workDaysReminderOn ? self.taskWorkDaysReminderDate : nil
//        let taskDueDayReminderDate = self.dueDayIsSet ? self.taskDueDayReminderDate : nil
        
        if !editIsTapped {
            taskId = "\(UUID())"
            createdAt = Date()
        }
        
        let challenge = Task(
            taskTitle: taskTitle,
            taskColorIndex: taskColorIndex,
            
            taskWorkDays: taskWorkDays.sorted(),
            taskWorkDate: taskWorkDate,
            taskWorkDaysReminderId: taskWorkDaysReminderId,
            taskWorkDaysReminderDate: taskWorkDaysReminderDate ?? nil,
//            taskDueDayReminderDate: taskDueDayReminderDate ?? nil,

            activities: [Activity(date: Date(), isComplete: false)],
            createdAt: createdAt,
//            position: 0,
            userId: userId
        )
                
        return taskService.create(challenge, taskId).eraseToAnyPublisher()
    }
}

extension NewTaskViewModel {
    
    // work days    
    func workDayIsChosen(_ index: Int) -> Bool {
        if taskWorkDays.contains(index){
            return true
        }
        return false
    }
    
    func addWorkDay(_ index: Int) {
        if index != 7 && taskWorkDays.contains(index) && taskWorkDays.count == 1 {
            taskWorkDays = [index]
        }
        else if index != 7 && taskWorkDays.contains(index) {
            if let i = taskWorkDays.firstIndex(of: index) {
                taskWorkDays.remove(at: i)
            }
        }
        else if index == 7 || taskWorkDays.count == 6 {
            taskWorkDays = [7]
        }
        else if index != 7 && taskWorkDays.contains(7) && !taskWorkDays.contains(index) {
            if let i = taskWorkDays.firstIndex(of: 7) {
                taskWorkDays.remove(at: i)
            }
            taskWorkDays.append(index)
        }
        else if index != 7 && !taskWorkDays.contains(7) && !taskWorkDays.contains(index){
            taskWorkDays.append(index)
        }
    }
    
    // work day reminder
    func onWorkDayReminder() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            }
            else if let error = error {
                print(error.localizedDescription)
            }
        }
        self.workDaysReminderOn.toggle()
    }
    
    func setReminder() {
        let content = UNMutableNotificationContent()
        content.title = taskTitle
        content.body = "Start now"
        content.sound = UNNotificationSound.default
        var reminderDate = DateComponents()

        if workDaysReminderOn {
            if taskWorkDays.contains(7) {
                // Everyday reminder
                print("REMINDER FOR EVERYDAY")

                let workDaysDateComponents = Calendar.current.dateComponents([.hour, .minute], from: taskWorkDaysReminderDate)
                reminderDate.hour = workDaysDateComponents.hour
                reminderDate.minute = workDaysDateComponents.minute
                let everyDayTrigger = UNCalendarNotificationTrigger(dateMatching: reminderDate, repeats: true)
                self.taskWorkDaysReminderId = [UUID()]
                let everyDayRequest = UNNotificationRequest(identifier: "\(self.taskWorkDaysReminderId.last!)", content: content, trigger: everyDayTrigger)
                UNUserNotificationCenter.current().add(everyDayRequest)
            }
            
            else if workDateIsSet {
                print("REMINDER FOR SPECIFIC DATE")
                // Reminder for specific date
                
                var nowDate = DateComponents()
                let components = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
                nowDate.hour = components.hour
                nowDate.minute = components.minute
                nowDate.second = components.second
                
                let taskWorkDateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: taskWorkDaysReminderDate)
                
                let hour = (taskWorkDateComponents.hour! - nowDate.hour!)*3600
                let min = (taskWorkDateComponents.minute! - nowDate.minute!)*60
                let sec = taskWorkDateComponents.second! - nowDate.second!
                let totalTimeInterval = hour + min + sec
                print("REMINDER LAUNCHES IN: \(totalTimeInterval) secs")
                print("REMINDER LAUNCHES IN: \(hour) : \(min) : \(sec)")
                
                if totalTimeInterval > 0 {
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(totalTimeInterval), repeats: false)
                    self.taskWorkDaysReminderId = [UUID()]
                    let request = UNNotificationRequest(identifier: "\(self.taskWorkDaysReminderId.last!)", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request)
                }
                else {
                    print("NOTIFICATION SETTING FAILED: TIME INTERVAl LESS THAN 1 sec")
                }
            }
            
            else {
                // For chosen work days
                print("REMINDER FOR CHOSEN WORK DAYS")
                
                for day in taskWorkDays {
                    var weekdayIdx = day
                    if day == 6 {
                        weekdayIdx = 1
                    }
                    else {
                        weekdayIdx += 2
                    }
                    var workDaysDateComponents = Calendar.current.dateComponents([.weekday, .hour, .minute], from: taskWorkDaysReminderDate)
                    workDaysDateComponents.weekday = weekdayIdx
                    reminderDate.weekday = workDaysDateComponents.weekday
                    reminderDate.hour = workDaysDateComponents.hour
                    reminderDate.minute = workDaysDateComponents.minute
                    let trigger = UNCalendarNotificationTrigger(dateMatching: reminderDate, repeats: true)
                    print("CHOSEN WORK DAY: \(day)")
                    
                    let reminderId = UUID()
                    taskWorkDaysReminderId.append(reminderId)
                    let request = UNNotificationRequest(identifier: "\(self.taskWorkDaysReminderId.last!)", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request)
                }
                print("TASK REMINDER ID: \(taskWorkDaysReminderId)")
            }
        }
    }
    
    func deleteReminder() {
        print("TASK WORK DAYS REMINDER IDS: \(taskWorkDaysReminderId)")
        let center = UNUserNotificationCenter.current() // Delete previous complete notification
        for index in taskWorkDaysReminderId.indices {
            center.removePendingNotificationRequests(withIdentifiers: ["\(taskWorkDaysReminderId[index])"])
            center.removeDeliveredNotifications(withIdentifiers:  ["\(taskWorkDaysReminderId[index])"])
        }
        taskWorkDaysReminderId = []
        print("TASK WORK DAYS REMINDER IDS: \(taskWorkDaysReminderId)")
        print("REMINDERS DELETE SUCCESSFUL")
    }
        
    func reset() {
        self.taskTitle = ""
        self.taskColorIndex = 0
        self.taskWorkDays = []
        self.taskWorkDaysReminderId = []
        self.taskWorkDaysReminderDate = Date()
//        self.taskDueDayReminderDate = Date()
        self.workDateIsSet = true
        self.dueDayIsSet = false
        self.workDaysReminderOn = false
        self.editIsTapped = false
    }
}

