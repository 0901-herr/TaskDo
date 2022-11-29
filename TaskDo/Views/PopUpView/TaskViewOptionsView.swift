//
//  TaskViewOption.swift
//  TaskDo
//
//  Created by Philippe Yong on 04/03/2021.
//

import SwiftUI

struct TaskViewOptionsView: View {
    @StateObject var viewModel = TaskViewOptionsViewModel()
    @StateObject var newTaskViewModel: NewTaskViewModel
    @Binding var view: TabItemViewModel.TabItemViewType
    
    @Binding var timerIsTapped: Bool
    @Binding var notesIsTapped: Bool
    @Binding var editIsTapped: Bool
    @Binding var optionIsSelected: Bool
    @Binding var taskTapped: Task
    
    @ObservedObject var defaultSettings = DefaultSettings()
    @State var deletedIsSelected = false

    var options: some View {
        HStack(spacing: 34) {
            ForEach(viewModel.options, id: \.self) { option in
                VStack(spacing: 10) {
                    Button(action: {
                        if option.optionType == .delete {
                            deletedIsSelected = true
                        }
                        else {
                            withAnimation {
                                buttonOptionAction(option)
                            }
                        }
                    }) {
                        VStack {
                            Image(systemName: "\(option.imageName)")
                                .font(.system(size: 18))
                                .foregroundColor(Color.white)
                        }
                        .frame(width: 55, height: 55)
                        .background(option.imageName == "circle" ? (taskTapped.taskColorIndex == 0 ? Color.taskColors[0].opacity(0.75) : Color.taskColors[taskTapped.taskColorIndex]) : option.color)
                        .cornerRadius(22)
                    }
                    
                    Text("\(option.title)")
                        .font(.system(size: 14))
                }
            }
            .padding(.bottom, 6)
        }
    }
    
    var body: some View {
        VStack {
            options
        }
        .frame(width: defaultSettings.screenWidth, height: 150, alignment: .center)
        .background(Color.halfModalViewColor)
        .cornerRadius(25)
        .alert(isPresented: self.$deletedIsSelected) {
            Alert(title: Text("Delete this Task?"), primaryButton: .destructive(Text("Delete")) {self.dltTask()}, secondaryButton: .cancel())
        }
    }
    
    func buttonOptionAction(_ option: TaskViewOptionsItem) {
        viewModel.taskId = taskTapped.id!
        viewModel.send(option: option.optionType)
        view = viewModel.selectedView
        timerIsTapped = viewModel.timerIsSelected
        notesIsTapped = viewModel.notesIsSelected
        editIsTapped = viewModel.editIsSelected

        if editIsTapped {setEditDatas()}
        optionIsSelected = true
    }
    
    func dltTask() {
        viewModel.taskId = taskTapped.id!
        viewModel.send(option: .delete)
        let reminderIdList = taskTapped.taskWorkDaysReminderId
        newTaskViewModel.taskWorkDaysReminderId = reminderIdList ?? []
        newTaskViewModel.deleteReminder()
        
        // If task display option is .thisweek, call display this week func again
//        taskListViewModel.displayThisWeekTask()
        
        deletedIsSelected = false
        optionIsSelected = true
    }
    
    func setEditDatas() {
        newTaskViewModel.reset()
        newTaskViewModel.editIsTapped = true
        
        newTaskViewModel.taskId = taskTapped.id!
        newTaskViewModel.taskTitle = taskTapped.taskTitle
        newTaskViewModel.taskColorIndex = taskTapped.taskColorIndex
        
        if taskTapped.taskWorkDate == nil {
            newTaskViewModel.workDateIsSet = false
        }
        else {
            newTaskViewModel.workDateIsSet = true
            newTaskViewModel.taskWorkDate = taskTapped.taskWorkDate!
        }
        if taskTapped.taskWorkDaysReminderDate != nil {
            newTaskViewModel.workDaysReminderOn = true
            newTaskViewModel.taskWorkDaysReminderDate = taskTapped.taskWorkDaysReminderDate!
            newTaskViewModel.taskWorkDaysReminderId = taskTapped.taskWorkDaysReminderId!
        }
        newTaskViewModel.taskWorkDays = taskTapped.taskWorkDays
//        newTaskViewModel.taskDueDayReminderDate = taskTapped.taskDueDayReminderDate ?? Date()
        newTaskViewModel.createdAt = taskTapped.createdAt
        newTaskViewModel.editWorkDaysReminderOn = true
    }
}

struct DeleteTaskViewOptionsView: View {
    @StateObject var viewModel = TaskViewOptionsViewModel()
    @StateObject var newTaskViewModel: NewTaskViewModel
//    @StateObject var taskListViewModel: TaskListViewModel
    @Binding var view: TabItemViewModel.TabItemViewType
    
    @Binding var timerIsTapped: Bool
    @Binding var notesIsTapped: Bool
    @Binding var editIsTapped: Bool
    @Binding var optionIsSelected: Bool
    @Binding var taskTapped: Task
    
    private let defaultSettings = DefaultSettings()
    @State var deletedIsSelected = false

    var options: some View {
        HStack(spacing: 5) {
    
        }
        .frame(width: 200)
    }
    
    var body: some View {
        VStack {
            options
        }
        .frame(width: defaultSettings.frameWidth, height: 60, alignment: .trailing)
        .cornerRadius(20)
        .alert(isPresented: self.$deletedIsSelected) {
            Alert(title: Text("Delete this Task?"), primaryButton: .destructive(Text("Delete")) {self.dltTask()}, secondaryButton: .cancel())
        }
    }
    
    func buttonOptionAction(_ option: TaskViewOptionsItem) {
        viewModel.taskId = taskTapped.id!
        viewModel.send(option: option.optionType)
        view = viewModel.selectedView
        timerIsTapped = viewModel.timerIsSelected
        notesIsTapped = viewModel.notesIsSelected
        editIsTapped = viewModel.editIsSelected

        if editIsTapped {setEditDatas()}
        optionIsSelected = true
    }
    
    func dltTask() {
        viewModel.taskId = taskTapped.id!
        viewModel.send(option: .delete)
        let reminderIdList = taskTapped.taskWorkDaysReminderId
        newTaskViewModel.taskWorkDaysReminderId = reminderIdList ?? []
        newTaskViewModel.deleteReminder()
        
        // If task display option is .thisweek, call display this week func again
//        taskListViewModel.displayThisWeekTask()
        
        deletedIsSelected = false
        optionIsSelected = true
    }
    
    func setEditDatas() {
        newTaskViewModel.reset()
        newTaskViewModel.editIsTapped = true
        
        newTaskViewModel.taskId = taskTapped.id!
        newTaskViewModel.taskTitle = taskTapped.taskTitle
        newTaskViewModel.taskColorIndex = taskTapped.taskColorIndex
        
        if taskTapped.taskWorkDate == nil {
            newTaskViewModel.workDateIsSet = false
        }
        else {
            newTaskViewModel.workDateIsSet = true
            newTaskViewModel.taskWorkDate = taskTapped.taskWorkDate!
        }
        if taskTapped.taskWorkDaysReminderDate != nil {
            newTaskViewModel.workDaysReminderOn = true
            newTaskViewModel.taskWorkDaysReminderDate = taskTapped.taskWorkDaysReminderDate!
            newTaskViewModel.taskWorkDaysReminderId = taskTapped.taskWorkDaysReminderId!
        }
        newTaskViewModel.taskWorkDays = taskTapped.taskWorkDays
//        newTaskViewModel.taskDueDayReminderDate = taskTapped.taskDueDayReminderDate ?? Date()
        newTaskViewModel.createdAt = taskTapped.createdAt
        newTaskViewModel.editWorkDaysReminderOn = true
    }
}


enum Options: CaseIterable {
    case timer
    case notes
    case edit
    case delete
}

import Combine

final class TaskViewOptionsViewModel: ObservableObject {
//    @Published var timerButtonColor = defaultSettings.tone
    @Published var timerIsSelected = false
    @Published var notesIsSelected = false
    @Published var editIsSelected = false
    @Published var deleteIsSelected = false
    @Published var selectedView: TabItemViewModel.TabItemViewType
    @Published var taskId = ""
    
    private let taskService: TaskServiceProtocol
    private var cancellables: [AnyCancellable] = []
    
    let defaultSettings = DefaultSettings()

    init(selectedView: TabItemViewModel.TabItemViewType = .taskListView,
        taskService: TaskServiceProtocol = TaskService()
    ) {
        self.taskService = taskService
        self.selectedView = selectedView
    }
    
    let options: [TaskViewOptionsItem] = [
        TaskViewOptionsItem(title: "Timer", imageName: "circle", color: Color.themeOrange, optionType: .timer),
        TaskViewOptionsItem(title: "Notes", imageName: "book", color: Color(#colorLiteral(red: 1, green: 0.8, blue: 0.2901960784, alpha: 1)), optionType: .notes),
        TaskViewOptionsItem(title: "Edit", imageName: "pencil", color: Color(#colorLiteral(red: 0.2901960784, green: 0.4901960784, blue: 1, alpha: 1)), optionType: .edit),
        TaskViewOptionsItem(title: "Delete", imageName: "trash", color: Color(#colorLiteral(red: 1, green: 0.3333333333, blue: 0.2901960784, alpha: 1)), optionType: .delete)
    ]
    
    func send(option: Options) {
        switch option {
        case .timer:
            print("timerIsSelected")
            timerIsSelected = true
        case .notes:
            print("notesIsSelected")
            notesIsSelected = true
        case .edit:
            print("editIsSelected")
            editIsSelected = true
        case .delete:
            print("deleteIsSelected")
            deleteIsSelected = true
            deleteChallenge(taskId)
        }
    }
    
    private func deleteChallenge(_ challengeId: String) {
        taskService.delete(challengeId).sink { completion in
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

struct TaskViewOptionsItem: Hashable {
    var title: String
    var imageName: String
    var color: Color
    var optionType: Options
}

