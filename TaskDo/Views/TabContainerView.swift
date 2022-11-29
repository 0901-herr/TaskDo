//
//  TabContainerView.swift
//  TaskDo
//
//  Created by Philippe Yong on 23/01/2021.
//

import SwiftUI

struct TabContainerView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @StateObject var tabContainerViewModel = TabContainverViewModel()
    @StateObject var timerViewModel = TimerViewModel()
    @StateObject var newTaskViewModel = NewTaskViewModel()
    @StateObject var statsViewModel = StatsViewModel()
        
    @State var taskIsTapped = false
    @State var timerIsTapped = false
    @State var optionIsSelected = false
    
    @State var taskTapped: Task = Task(id: "",
                                       taskTitle: "",
                                       taskColorIndex: 0,
                                       taskWorkDays: [],
                                       taskWorkDate: Date(),
                                       taskWorkDaysReminderId: [],
                                       taskWorkDaysReminderDate: Date(),
                                       activities: [],
                                       createdAt: Date(),
                                       userId: "")
    
    @State var taskNotes: [Notes] = []
    @State var notesIsTapped = false
    @State var editIsTapped = false
    
    @State var tagIsTapped = false
    @State var timerSettingsIsTapped = false
    @State var selectedTagIndex = 5
    
    @State var profileIsTapped = false
    
    @State var view: TabItemViewModel.TabItemViewType = .taskListView
    @GestureState private var translation: CGFloat = 0
    @State var offset: CGFloat = 0
    @State var offsetN = CGSize.zero
    
    @State var timerViewWidth = UIScreen.main.bounds.width
    @State var timerViewHeight = UIScreen.main.bounds.height
    @State var timerIsCompleted = false
    
    @State var focusModeIsOn = false
    @State var showPopUp = false
    @State var taskDisplayOptionIsTapped = false
    @State var taskDisplayType: TaskDisplayAction = .today
    @State var taskDisplayDetail: TaskDisplayOption = TaskDisplayOption(title: "Today", description: "", name: "", nameSelect: "", type: .today)
    
    @ObservedObject var defaultSettings = DefaultSettings()
    @State var popUpOffset: CGFloat = 0
    @State var timerIsDragged = false
        
    @State var showDetails = false

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                
                VStack(spacing: 0) {
                    tabView(for: view)
                    
                    VStack {
                        // tab items
                        HStack(spacing: 180) {
                            Image(view == .taskListView ? (isDarkMode ? "home3" : "home") : (isDarkMode ? "home4" : "home2"))
                                .resizable()
                                .frame(width: 28, height: 28)
                                .onTapGesture {
                                    view = .taskListView
                                }
                                .padding(.top, 10)

                            Image(systemName: "chart.bar")
                                .font(.system(size: 25, weight: .regular))
                                .foregroundColor(view == .statsView ? (isDarkMode ? Color.white : Color.black) : (isDarkMode ? Color.smallButtonColor : Color(#colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8823529412, alpha: 1))))
                                .onTapGesture {
                                    view = .statsView
                                }
                                .padding(.top, 10)
                        }
                    }
                    .padding(.bottom, proxy.safeAreaInsets.bottom > 0 ? 80 : 40) //45
                }
                .opacity(notesIsTapped || profileIsTapped ? 0 : 1)
                
                // Timer view
                TimerView(viewModel: timerViewModel, timerIsTapped: $timerIsTapped, timerIsCompleted: $timerIsCompleted, tagIsTapped: $tagIsTapped, taskTapped: $taskTapped, offset: $offset, focusModeIsOn: $focusModeIsOn, showPopUp: $showPopUp, timerIsDragged: $timerIsDragged, timerSettingsIsTapped: $timerSettingsIsTapped)
                    .frame(width: timerIsTapped ? defaultSettings.screenWidth : 40)
                    .background(Color.primaryColor.opacity(timerIsTapped ? 1 - Double(offset)/120 : 0).edgesIgnoringSafeArea(.all))
                    .animation(Animation.expand().speed(1.5))
                    .onTapGesture {
                        if !timerIsTapped && !timerViewModel.firstStart {
                            taskTapped = Task(id: "\(UUID())", taskTitle: "", taskColorIndex: taskTapped.taskColorIndex, taskWorkDays: [], taskWorkDate: Date(), taskWorkDaysReminderId: [], taskWorkDaysReminderDate: Date(), activities: [], createdAt: Date(), userId: "")
                                focusModeIsOn = false
                        }
                        timerIsTapped = true
                        taskIsTapped = false
                        optionIsSelected = false
                    }
                    .offset(y: offset)
                    .gesture(
                        DragGesture()
                            .onChanged(change(value:))
                            .onEnded(end(value:))
                    )
                    .padding(.bottom, timerIsTapped ? proxy.safeAreaInsets.bottom+40 : proxy.safeAreaInsets.bottom > 0 ? 20 : -15)
                    .opacity(notesIsTapped || profileIsTapped ? 0 : 1)

                Color.black
                    .opacity(
                        (taskIsTapped && !optionIsSelected) ||
                        (timerIsTapped && tagIsTapped) ||
                        taskDisplayOptionIsTapped ||
                        timerSettingsIsTapped ||
                        showDetails //|| profileIsTapped || notesIsTapped
                        ? (isDarkMode ? 0.5 : 0.35): 0)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            if taskIsTapped {
                                taskIsTapped = false
                            }
                            else if tagIsTapped {
                                tagIsTapped = false
                            }
                            else if timerSettingsIsTapped {
                                timerSettingsIsTapped = false
                            }
                            else if taskDisplayOptionIsTapped {
                                optionIsSelected = false
                                taskDisplayOptionIsTapped = false
                            }
                            else if editIsTapped {
                                    editIsTapped = false
                            }
                            else if showDetails {
                                showDetails = false
                            }
                        }
                    }
                
                // Task Options
                if taskIsTapped && !optionIsSelected {
                    TaskViewOptionsView(newTaskViewModel: newTaskViewModel, view: $view, timerIsTapped: $timerIsTapped, notesIsTapped: $notesIsTapped, editIsTapped: $editIsTapped, optionIsSelected: $optionIsSelected,  taskTapped: $taskTapped)
                        .transition(.moveAndFade)
                        .animation(.ripple())
                        .padding(.bottom, proxy.safeAreaInsets.bottom + 10)
//                        .offset(y: popUpOffset)
                        .gesture(
                            DragGesture()
                                .onChanged(popUpChange(value:))
                                .onEnded(popUpEnd(value:))
                        )
                }
                
                if showDetails {
                    StatsDetails(statsViewModel: statsViewModel, showDetails: $showDetails)
                        .transition(.moveAndFade)
                        .animation(.ripple())
                        .padding(.bottom, proxy.safeAreaInsets.bottom + 10)
                }
                
                // Timer tags
                VStack {
                    if tagIsTapped {
                        TimerTagsOptionsView(viewModel: timerViewModel, tagIsTapped: $tagIsTapped)
                            .transition(.moveAndFade)
                            .animation(.ripple())
                            .padding(.bottom, proxy.safeAreaInsets.bottom + 10)
                    }
                    else if timerSettingsIsTapped {
                        TimerSettingsView(timerViewModel: timerViewModel, timerSettingsIsTapped: self.$timerSettingsIsTapped, taskColorIndex: taskTapped.taskColorIndex)
                            .transition(.moveAndFade)
                            .animation(.ripple())
                            .padding(.bottom, proxy.safeAreaInsets.bottom + 10)
                    }
                }
//                .offset(y: popUpOffset)
//                .gesture(
//                    DragGesture()
//                        .onChanged(popUpChange(value:))
//                        .onEnded(popUpEnd(value:))
//                )
                    
                // Notes view
                if notesIsTapped {
                    NotesView(notesIsTapped: $notesIsTapped, taskId: taskTapped.id!, taskTitle: taskTapped.taskTitle, taskColorIndex: taskTapped.taskColorIndex, taskNotes: $taskNotes)
                }
                
                // Profile view
                if profileIsTapped {
                    ProfileView(profileIsTapped: $profileIsTapped)
                }
                
                // Top pop ups (Focus mode and Complete task pop ups)
                VStack {
                    if showPopUp {
                        FocusModePopUpView(focusModeIsOn: $focusModeIsOn, showPopUp: $showPopUp, colorIndex: taskTapped.taskColorIndex)
                            .transition(.moveAndFadeTop)
                            .animation(.softRipple())
                    }
                    else if timerIsCompleted {
                        TopPopUpView(focusTime: timerViewModel.timerValue)
                            .transition(.moveAndFadeTop)
                            .animation(.softRipple())
                    }
                }
            }
            .frame(width: defaultSettings.screenWidth, height: defaultSettings.screenHeight, alignment: .center)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    @ViewBuilder
    func tabView(for tabItemType: TabItemViewModel.TabItemViewType) -> some View {
        switch tabItemType {
        case .taskListView:
            TaskListView(newTaskViewModel: newTaskViewModel, view: $view, timerIsTapped: $timerIsTapped, taskIsTapped: $taskIsTapped, editIsTapped: $editIsTapped, optionIsSelected: $optionIsSelected, taskTapped: $taskTapped, taskNotes: $taskNotes, notesIsTapped: $notesIsTapped, profileIsTapped: $profileIsTapped, taskDisplayOptionIsTapped: $taskDisplayOptionIsTapped, taskDisplayType: $taskDisplayType, taskDisplayDetail: $taskDisplayDetail)
        case .statsView:
            StatsContentView(showDetails: $showDetails)
        }
    }
    
    func change(value: DragGesture.Value) {
        withAnimation {
            timerIsDragged = true
        }
        if value.translation.height > 0 && timerIsTapped {
            withAnimation {
                offset = value.translation.height
//                print("OFFSET: \(offset)")
                if offset > 40 {
                    timerIsTapped = false
                    offset = 0
                }
            }
        }
    }
    
    func end(value: DragGesture.Value) {
        withAnimation {
            timerIsDragged = false
        }
        withAnimation {
            if value.translation.height > 40 {
                timerIsTapped = false
            }
            offset = 0
        }
    }
    
    func popUpChange(value: DragGesture.Value) {
        if value.translation.height > 0 {
            withAnimation {
                popUpOffset = value.translation.height
                print("OFFSET: \(offset)")
                if popUpOffset > 30 {
                    popUpOffset = 0
                }
            }
        }
    }
    
    func popUpEnd(value: DragGesture.Value) {
        withAnimation {
            if value.translation.height > defaultSettings.screenHeight/10 {
                taskIsTapped = false
                optionIsSelected = false
                tagIsTapped = false
                taskDisplayOptionIsTapped = false
            }
            popUpOffset = 0
        }
    }
}

final class TabContainverViewModel: ObservableObject {
    @Published var selectedTab: TabItemViewModel.TabItemViewType = .taskListView
    
    let tabItemViewModels = [
        TabItemViewModel(viewTitle: "TaskListView", type: .taskListView),
        TabItemViewModel(viewTitle: "StatsView", type: .statsView)
    ]
}

struct TabItemViewModel: Hashable {
    let viewTitle: String
    let type: TabItemViewType
    
    enum TabItemViewType {
        case taskListView
        case statsView
    }
}
