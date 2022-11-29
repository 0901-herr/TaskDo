//
//  DragRelocateView.swift
//  TaskDo
//
//  Created by Philippe Yong on 12/07/2021.
//

import Foundation
import SwiftUI
import Combine

struct DropOutsideDelegate: DropDelegate {
    @Binding var current: TaskViewModel?
    
    func performDrop(info: DropInfo) -> Bool {
        current = nil
        return true
    }
}

struct DragRelocateDelegate: DropDelegate {
    let item: TaskViewModel
    @Binding var listData: [TaskViewModel]
    @Binding var current: TaskViewModel?
    //    @StateObject var taskOrderViewModel = TaskOrderViewModel()

    func dropEntered(info: DropInfo) {
        if item != current {
            let from = listData.firstIndex(of: current!)!
            let to = listData.firstIndex(of: item)!
            if listData[to].id != current!.id {
                listData.move(fromOffsets: IndexSet(integer: from),
                    toOffset: to > from ? to + 1 : to)
            }
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        print("MOVING")
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        self.current = nil
        print("IS DROPPED")
        return true
    }
    
    func savePosition() {
        
    }
}


final class TaskOrderViewModel: ObservableObject {
    @Published var taskList: [TaskViewModel] = []
    
    private let onDelete: (String) -> Void
    private let onToggleComplete: (String, [Activity]) -> Void
    
    init(
         onDelete: @escaping (String) -> Void,
         onToggleComplete: @escaping (String, [Activity]) -> Void
    ) {
//        self.task = task
        self.onDelete = onDelete
        self.onToggleComplete = onToggleComplete
    }

    // Implement sorting logic here
    
    // 1. Get whole items list sorted in position
    
    // 2. Acquire
    
    // Update new position here
    
    func send(action: Action) {
//        guard let id = task.id else { return }
//        switch action {
//        case .delete:
//            onDelete(id)
//        case .toggleComplete:
//            let activities = task.activities.map { activity -> Activity in
//                return .init(date: Date(), isComplete: !activity.isComplete)
//            }
//            onToggleComplete(id, activities)
//        }
    }
}



/*
final class TaskOrderViewModel: ObservableObject {
    @Published private(set) var itemViewModels: [TaskOrderItemViewModel] = []
    @Published private(set) var error: TaskDoError?
    @Published private(set) var isLoading = false
        
    private let userService: UserServiceProtocol
    private let taskOrderService: TaskOrderServiceProtocol
    private var cancellables: [AnyCancellable] = []
            
    init(
        userService: UserServiceProtocol = UserService(),
        taskService: TaskOrderServiceProtocol = TaskOrderService()
    ) {
        isLoading = true
        self.userService = userService
        self.taskOrderService = taskService
        observeChallenges { completion in
            if completion {
                
            }
        }
    }
    
    private func observeChallenges(completion: @escaping (Bool) -> Void) {
        userService.currentUserPublisher()
            .compactMap { $0?.uid }
            .flatMap { [weak self] userId -> AnyPublisher<[TaskOrder], TaskDoError> in
                guard let self = self else { return Fail(error: .default()).eraseToAnyPublisher() }
                return self.taskOrderService.observeChallenges(userId: userId)
            }
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case let .failure(error):
                    self.error = error
                case .finished:
                    print("finished")
                }
            } receiveValue: { [weak self] tasksOrder in
                guard let self = self else { return }
                self.error = nil
                self.itemViewModels = tasksOrder.map { order in
                    .init(
                        order,
                        onDelete: { [weak self] id in
                            self?.deleteChallenge(id)
                        },
                        onToggleComplete: { [weak self] id, taskInfo in
                            self?.updateChallenge(id: id, taskOrder: taskInfo)
                        })
                }
                completion(true)
            }.store(in: &cancellables)
    }
    
    private func deleteChallenge(_ challengeId: String) {
        taskOrderService.delete(challengeId).sink { completion in
            switch completion {
            case let .failure(error):
                print(error.localizedDescription)
            case .finished:
                break
            }
        } receiveValue: { _ in }
        .store(in: &cancellables)
    }
    
    private func updateChallenge(id: String, taskOrder: [TaskInfo]) {
        taskOrderService.updateChallenge(id, order: taskOrder).sink { completion in
            switch completion {
            case let .failure(error):
                print(error.localizedDescription)
            case .finished:
                break
            }
        } receiveValue: { _ in }
        .store(in: &cancellables)
    }
}

struct TaskOrderItemViewModel: Identifiable {
    private let taskOrder: TaskOrder
    private let onDelete: (String) -> Void
    private let onToggleComplete: (String, [TaskInfo]) -> Void
        
    var id: String {
        taskOrder.id!
    }
    
    init(_ taskOrder: TaskOrder,
         onDelete: @escaping (String) -> Void,
         onToggleComplete: @escaping (String, [TaskInfo]) -> Void
    ) {
        self.taskOrder = taskOrder
        self.onDelete = onDelete
        self.onToggleComplete = onToggleComplete
    }
    
    var order: [TaskInfo] {
        taskOrder.order
    }
    
    func send(action: Action) {
        guard let id = taskOrder.id else { return }
        switch action {
        case .delete:
            onDelete(id)
        case .toggleComplete:
            let order = taskOrder.order.map { order -> TaskInfo in
                return .init(taskId: id, position: 0)
            }
            onToggleComplete(id, order)
        }
    }
}

extension TaskOrderItemViewModel {
    enum Action {
        case delete
        case toggleComplete
    }
}
*/
