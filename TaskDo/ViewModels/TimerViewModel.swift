//
//  TimerViewModel.swift
//  TaskDo
//
//  Created by Philippe Yong on 28/01/2021.
//

import Foundation
import SwiftUI
import Combine

final class TimerViewModel: ObservableObject {
    @ObservedObject var defaultSettings = DefaultSettings()
    @Published var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Published var timerValue = 60
    @Published var time = 0
    @Published var percentage: Double = 0.0
    @Published var start = false
    @Published var isActive = false
    @Published var startDate = Date()
    @Published var firstStart = false
    @Published var timerIsCompleted = false
    @Published var timerIsPaused = false
    
    @Published var focusTime = 0
    @Published var focusRecord: [FocusRecord] = []
    
    @Published var action: Action = .start
    @Published var showExit = false
    
    @Published var second: Int = 0
    @Published var minute: Int = 0

    @Published var error: TaskDoError?
    @Published var focusTimeNotEnough = false
    
    @Published var resignDate = DateComponents()
    @Published var reenterDate = DateComponents()
    @State var timerDefault: UserDefaults = UserDefaults.standard
    
    var notiIdentifier = UUID().uuidString
    
    let buttonActions: [TimerButton] = [
        TimerButton(buttonTitle: "Start", imageName: "arrowtriangle.right.fill", action: .start),
        TimerButton(buttonTitle: "Pause", imageName: "pause.fill", action: .pause),
        TimerButton(buttonTitle: "Continue", imageName: nil, action: .resume),
        TimerButton(buttonTitle: "Quit", imageName: nil, action: .quit)
    ]
    
    let tagOptions: [Tags] = [
        Tags(title: "Study", imageName: "book.fill", color: Color(#colorLiteral(red: 0.9803921569, green: 0.3921568627, blue: 0.262745098, alpha: 1)), type: .study),
        Tags(title: "Work", imageName: "desktopcomputer", color: Color(#colorLiteral(red: 0.262745098, green: 0.7215686275, blue: 0.9803921569, alpha: 1)), type: .work),
        Tags(title: "Exercise", imageName: "exercise", color: Color(#colorLiteral(red: 0.9803921569, green: 0.5215686275, blue: 0.262745098, alpha: 1)), type: .exercise),
        Tags(title: "Fun", imageName: "gamecontroller.fill", color: Color(#colorLiteral(red: 0.9803921569, green: 0.8196078431, blue: 0.262745098, alpha: 1)), type: .fun),
        Tags(title: "Productivity", imageName: "bookmark.fill", color: Color(#colorLiteral(red: 0.09411764706, green: 0.937254902, blue: 0.7843137255, alpha: 1)), type: .productivity),
        Tags(title: "Others", imageName: "circle", color: Color(#colorLiteral(red: 0.8196078431, green: 0.5411764706, blue: 0.9921568627, alpha: 1)), type: .others)
    ]
    
    @Published var timerValueSelections: [Int] = [0]
    @Published var intervalValue = 1
    @Published var selectedTimerValueIndex = 0
    
    var taskId: String
    var taskTitle: String
    var taskColorIndex: Int
    var selectedTagIndex: Int
    
    private let userService: UserServiceProtocol
    private let statsService: StatsServiceProtocol
    private var cancellables: [AnyCancellable] = []
    
        
    init(
        taskId: String = "\(UUID())",
        taskTitle: String = "",
        taskColorIndex: Int = 0,
        selectedTagIndex: Int = 5,
        
        userService: UserServiceProtocol = UserService(),
        statsService: StatsServiceProtocol = StatsService()
    ) {
        self.taskId = taskId
        self.taskTitle = taskTitle
        self.taskColorIndex = taskColorIndex
        self.selectedTagIndex = selectedTagIndex
        
        self.userService = userService
        self.statsService = statsService
        
        intervalValue = defaultSettings.defaultValues.integer(forKey: "intervalValue")
        selectedTimerValueIndex = defaultSettings.defaultValues.integer(forKey: "selectedTimerValueIndex")
        
        print("selectedTimerValueIndex: \(selectedTimerValueIndex)")
        
        self.getTimerInterval()
    }
    
    func getTimerInterval() {
        if intervalValue == 0 {
            intervalValue = 1
        }
        
        self.timerValueSelections = []
        
        for i in stride(from: intervalValue, to: 121, by: intervalValue){
            self.timerValueSelections.append(i)
        }
    }
    
    func calcFocusTime(startDate: Date, endDate: Date) -> Int {
        let startDateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: startDate)
        let startDateHour = startDateComponents.hour ?? 0
        let startDateMin = startDateComponents.minute ?? 0
        let startDateSec = startDateComponents.second ?? 0
        let startDateTotalTime = (startDateHour*3600) + (startDateMin*60) + (startDateSec)
        
        let endDateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: endDate)
        let endDateHour = endDateComponents.hour ?? 0
        let endDateMin = endDateComponents.minute ?? 0
        let endDateSec = endDateComponents.second ?? 0
        let endDateTotalTime = (endDateHour*3600) + (endDateMin*60) + (endDateSec)
    
        return endDateTotalTime - startDateTotalTime
    }
    
    func send(action: Action) {
        switch action {
        case .start:
            timerValue = selectedTimerValueIndex
            focusTime = timerValue*60
            time = timerValue*60
            minute = Int(Double(time) / 60)
            second = time % 60
            
            startDate = Date()
            firstStart = true
            isActive = true
            start = true
            
            setNoti()
            self.action = .pause
            
            print("start")
            
        case .pause:
            start = false
            let endDate = Date()
            focusTime = calcFocusTime(startDate: startDate, endDate: endDate)
            
            // add focus record
            print("FOCUS RECORD VIA PAUSE: \(focusTime)")
            focusRecord.append(FocusRecord(date: startDate, focusTime: focusTime))
            
            deleteNoti()
            self.action = .resume
            self.timerIsPaused = true
            self.showExit = true
            print("pause")
            
        case .resume:
            setNoti()
            start = true
            // add new start date
            self.startDate = Date()
            self.action = .pause
            print("resume")
            
        case .quit:
            self.time = timerValue * 60 - self.time
            if self.time > 60 {
                print("TIME: \(self.time)")
                saveFocusTime()
            }
            else {
                focusTimeNotEnough = true
            }
            deleteNoti()
            resetTimer()
            print("quit")
        }
    }
    
    func getTimeStr(_ timer: Int) -> String {
        var str = ""
        if timer < 10 {
            str = "0\(timer)"
        }
        else {
            str = "\(timer)"
        }
        
        return str
    }
    
    func saveFocusTime() {
        currentUserId().flatMap { (userId) -> AnyPublisher<Void, TaskDoError> in
            return self.createStatsRecord(userId: userId)
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
    }
    
    func setNoti() {
        let content = UNMutableNotificationContent()
        content.title = "Task Completed 🎉"
        content.body = "You have completed \(self.timerValue) mins of \(self.taskTitle == "" ? "Untitled" : self.taskTitle)!"
        content.sound = UNNotificationSound.default

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(self.time), repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: self.notiIdentifier, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
    
    func deleteNoti() {
        let center = UNUserNotificationCenter.current() // Delete previous complete notification
        center.removePendingNotificationRequests(withIdentifiers: [self.notiIdentifier])
        center.removeDeliveredNotifications(withIdentifiers: [self.notiIdentifier])
    }
    
    func fetchTimerValue() {
        // fetch timer value
        self.start = self.timerDefault.bool(forKey: "timerStatus")
        self.timerIsPaused = self.timerDefault.bool(forKey: "timerIsPaused")
        
        let resignArr = timerDefault.object(forKey: "resignArray") as? [Int] ?? [0, 0, 0]
        self.resignDate.hour = resignArr[0]
        self.resignDate.minute = resignArr[1]
        self.resignDate.second = resignArr[2]

        self.taskId = self.timerDefault.string(forKey: "taskId") ?? ""
        self.taskTitle = self.timerDefault.string(forKey: "taskTitle") ?? ""
        self.taskColorIndex = self.timerDefault.integer(forKey: "taskColorIndex")
            
        self.startDate = self.timerDefault.object(forKey: "startDate") as? Date ?? Date()
        self.selectedTagIndex = self.timerDefault.integer(forKey: "selectedTagIndex")
        self.time = self.timerDefault.integer(forKey: "focusTime")
        self.timerValue = self.timerDefault.integer(forKey: "timerValue")
        self.isActive = true
    }
    
    func saveTimerValue() {
        // Items to be saved
        // resign date
        // timer status

        // timer
        self.timerDefault.set(self.timerValue, forKey: "timerValue")
        self.timerDefault.set(self.timerIsPaused, forKey: "timerIsPaused")
        self.timerDefault.set(self.start, forKey: "timerStatus")
        let resignDateArray = [self.resignDate.hour, self.resignDate.minute, self.resignDate.second]
        self.timerDefault.set(resignDateArray, forKey: "resignArray")
        
        // task
        self.timerDefault.set(self.taskId, forKey: "taskId")
        self.timerDefault.set(self.taskTitle, forKey: "taskTitle")
        self.timerDefault.set(self.taskColorIndex, forKey: "taskColorIndex")
        
        // record
        self.timerDefault.setValue(self.startDate, forKey: "startDate")
        self.timerDefault.setValue(self.selectedTagIndex, forKey: "selectedTagIndex")
        self.timerDefault.set(self.time, forKey: "focusTime") // Timer state
        
        print("EXIT TIMER VALUE SAVED")
    }
    
    func recordResignDate() {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: Date()) // Getting reenter date
        resignDate.hour = components.hour!
        resignDate.minute = components.minute!
        resignDate.second = components.second!
    }
    
    func restoreTimerValue() {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
        // Getting reenter date
        reenterDate.hour = components.hour ?? 0
        reenterDate.minute = components.minute ?? 0
        reenterDate.second = components.second ?? 0
        
        var total = 0

        if reenterDate.hour! >= resignDate.hour! { // User reenter app at same day
            let hour = (reenterDate.hour! - resignDate.hour!) * 3600
            let min = (reenterDate.minute! - resignDate.minute!) * 60
            let sec =  reenterDate.second! - resignDate.second!
            total = Int(hour + min + sec)
        }
        else { // User reenter app on next day
            let hour = (reenterDate.hour! + 24 - resignDate.hour!) * 3600
            let min = (reenterDate.minute! - resignDate.minute!) * 60
            let sec = reenterDate.second! - resignDate.second!
            total = hour + min + sec
        }
        print("TIME BEFORE: \(time)")
        print("TOTAL MINUS TIME: \(total)")
        self.time -= total
        print("TIME AFTER: \(time)")
    }
    
    func resetTimer() {
        start = false
        firstStart = false
        isActive = false
        self.action = .start
        percentage = 0
        second = 0
        minute = 0
        timerValue = 60
        focusRecord = []
        
        timerDefault.removeObject(forKey: "timerStatus")
        timerDefault.removeObject(forKey: "resignArray")
        
        timerDefault.removeObject(forKey: "taskId")
        timerDefault.removeObject(forKey: "taskTitle")
        timerDefault.removeObject(forKey: "taskColorIndex")
        
        timerDefault.removeObject(forKey: "startDate")
        timerDefault.removeObject(forKey: "selectedTagIndex")
        timerDefault.removeObject(forKey: "focusTime")
    }
}

enum Action: CaseIterable {
    case start
    case pause
    case resume
    case quit
}

struct TimerButton: Hashable {
    var buttonTitle: String
    var imageName: String?
    var action: Action
}

extension TimerViewModel {
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
        
    private func createStatsRecord(userId: UserId) -> AnyPublisher<Void, TaskDoError> {
        let record = Record(focusRecord: self.focusRecord, selectedTagIndex: self.selectedTagIndex)
        
        if self.taskTitle.isEmpty {
            self.taskTitle = "Untitled"
        }
        
        let stats = Stats(
            id: self.taskId,
            taskTitle: self.taskTitle,
            taskColorIndex: self.taskColorIndex,
            record: [record],
            userId: userId
        )
        
        print("SAVE STATS: \(stats)")

        return self.statsService.create(stats, record: record).eraseToAnyPublisher()
    }
}

extension TimerViewModel {
    public func startTimer() {
        print("START TIMER TIME: \(self.time)")
        if time > 0 {
            time -= 1
            let timerValueSec = timerValue * 60
            minute = Int(Double(time) / 60)
            second = time % 60
            percentage = Double(timerValueSec - time) / Double(timerValueSec)
        }
        else {
            sessionCompleted()
        }
    }
    
    public func sessionCompleted() {
        timerIsCompleted = true
        // add record
        if focusRecord.count < 1 {
            focusRecord.append(FocusRecord(date: startDate, focusTime: timerValue*60))
            print("NO PAUSE")
        }
        else {
            let totalSec = focusRecord.map { $0.focusTime }.reduce(0, +)
            let lastSessionFocusSec = timerValue*60 - totalSec
            focusRecord.append(FocusRecord(date: startDate, focusTime: lastSessionFocusSec))
            print("GOT PAUSE")
        }
        print("TOTAL FOCUS RECORD: \(focusRecord)")
        
        if focusRecord[0].focusTime > 0 {
            saveFocusTime()
            resetTimer()
            withAnimation(.softRipple()) {
                self.timerIsCompleted = false
            }
        }
    }
}

extension TimerViewModel {
    func selectTag(_ index: Int) {
        selectedTagIndex = index
    }
}
