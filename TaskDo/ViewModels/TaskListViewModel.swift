//
//  TaskListViewModel.swift
//  TaskDo
//
//  Created by Philippe Yong on 24/01/2021.
//

import SwiftUI
import Combine

typealias UserId = String

final class TaskListViewModel: ObservableObject {
    @Published var addTaskPushed = false
    @Published private(set) var itemViewModels: [TaskViewModel] = []
    @Published private(set) var error: TaskDoError?
    @Published private(set) var isLoading = false
    
    @Published var showingCreateModel = false
    
    private let userService: UserServiceProtocol
    private let taskService: TaskServiceProtocol
    private var cancellables: [AnyCancellable] = []
    
    @Published var thisWeekDate: [[String]] = []
    @Published var taskListByDate: [[TaskViewModel]] = [[], [], [], [], [], [], []]
        
    @Published var selectedDayTask: [TaskViewModel] = []
    @Published var selectedWeekTask: [[TaskViewModel]] = []
    @Published var date = Date()
    @Published var finishedLoading = false
    @Published var reloadTask = true
    
    @Published var isToggle = false
    @Published var isDelete = false
    
    let columns = [GridItem(.fixed(1))]
    
    enum Action {
        case retry
        case create
        case timeChange
    }
    
    init(
        userService: UserServiceProtocol = UserService(),
        taskService: TaskServiceProtocol = TaskService()
    ) {
        isLoading = true
        self.userService = userService
        self.taskService = taskService
        observeChallenges { completion in
            if completion {
//                self.itemViewModels.sort { $0.position > $1.position }
                print("INIT CALLED HERE")
                self.reloadTask(date: self.date)
                self.finishedLoading = true
                print()
            }
        }
        // Print out item view models retrieved tasks
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.itemViewModels = self.itemViewModels.sorted { $0.id < $1.id }
            for i in 0..<self.itemViewModels.count {
                print(self.itemViewModels[i])
            }
        }

        isLoading = false
    }
    
    func send(action: Action) {
        switch action {
        case .retry:
            observeChallenges { _ in }
        case .create:
            showingCreateModel = true
        case .timeChange:
            cancellables.removeAll()
            observeChallenges { _ in }
        }
    }

    private func observeChallenges(completion: @escaping (Bool) -> Void) {
        userService.currentUserPublisher()
            .compactMap { $0?.uid }
            .flatMap { [weak self] userId -> AnyPublisher<[Task], TaskDoError> in
                guard let self = self else { return Fail(error: .default()).eraseToAnyPublisher() }
                return self.taskService.observeChallenges(userId: userId)
            }
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case let .failure(error):
                    self.error = error
                case .finished:
                    print("finished")
                }
            } receiveValue: { [weak self] tasks in
                guard let self = self else { return }
                self.error = nil
                self.showingCreateModel = false
                self.itemViewModels = tasks.map { task in
                    .init(
                        task,
                        onDelete: { [weak self] id in
                            self?.isDelete = true
                            self?.deleteChallenge(id)
                        },
                        onToggleComplete: { [weak self] id, activities in
                            self?.isToggle = true
                            print("ON TOGGLE")
                            self?.updateChallenge(id: id, activities: activities)
                        })
                }
                print("RETRIEVED TASKS")
                completion(true)
            }.store(in: &cancellables)
    }
    
    public func displayTodayTask(selectedDate: Date) {
        print("DISPLAY TODAY FUNC CALLED")
        
        var taskList: [TaskViewModel] = []
        let selectedDay = Date().getWeekDay(date: selectedDate)
        
        for task in self.itemViewModels {
            // For everyday
            if task.taskWorkDays.contains(7) {
                taskList.append(task)
            }
            // For week days
            else if task.taskWorkDays.contains(selectedDay) ||  task.taskWorkDays.contains(Date().getWeekDay(date: selectedDate)) {
                    taskList.append(task)
            }
            // For selected days
            else if task.taskWorkDate != nil && getFormattedDateXI(task.taskWorkDate!) == getFormattedDateXI(selectedDate) {
                taskList.append(task)
            }
        }
                
        self.selectedDayTask = taskList
    }
    
    public func displayThisWeekTask(selectedDate: Date) {
        print("DISPLAY THIS WEEK FUNC CALLED")
        
        let thisWeekDate = Date().getSelectedWeekDates(date: selectedDate).map {getFormattedDateXI($0)}
        var taskListByDate: [[TaskViewModel]] = []
        
        for _ in 0..<7 {
            taskListByDate.append([])
        }
        
        for task in self.itemViewModels {
            if task.taskWorkDate != nil {
                for i in 0..<7 {
                    if thisWeekDate[i] == getFormattedDateXI(task.taskWorkDate!) {
                        taskListByDate[i].append(task)
                    }
                }
            }
            else if task.taskWorkDays.contains(7) {
                for i in 0..<7 {
                    taskListByDate[i].append(task)
                }
            }
            else {
                for i in 0..<7 {
                    for day in task.taskWorkDays {
                        if i == day {
                            taskListByDate[i].append(task)
                        }
                    }
                }
            }
        }
        
        self.selectedWeekTask = taskListByDate
    }
    
    public func reloadTask(date: Date) {
        displayTodayTask(selectedDate: date)
        displayThisWeekTask(selectedDate: date)
    }

    
    public func getFormattedDateXI(_ date: Date) -> String {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = "dd.MM"
        
        return formattedDate.string(from: date)
    }

    
    private func deleteChallenge(_ challengeId: String) {
        taskService.delete(challengeId).sink { completion in
            switch completion {
            case let .failure(error):
                print(error.localizedDescription)
            case .finished:
//                self.reloadTask = true
                break
            }
        } receiveValue: { _ in }
        .store(in: &cancellables)
    }
    
    private func updateChallenge(id: String, activities: [Activity]) {
        print("UPDATE CHALLENGE")
        taskService.updateChallenge(id, activities: activities).sink { completion in
            switch completion {
            case let .failure(error):
                print(error.localizedDescription)
            case .finished:
                print("UPDATE FINISHED")
                break
            }
        } receiveValue: { _ in }
        .store(in: &cancellables)
    }
}



