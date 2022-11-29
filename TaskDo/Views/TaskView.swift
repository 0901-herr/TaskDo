//
//  TaskView.swift
//  TaskDo
//
//  Created by Philippe Yong on 24/01/2021.
//

import SwiftUI

struct TaskView: View {
    private let viewModel: TaskViewModel
    @StateObject var newTaskViewModel = NewTaskViewModel()

    @Binding var view: TabItemViewModel.TabItemViewType
    @Binding var timerIsTapped: Bool
    @Binding var notesIsTapped: Bool
    @Binding var editIsTapped: Bool
    
    @Binding var defaultDayIsSelected: Bool
    @Binding var taskIsTapped: Bool
    @Binding var optionIsSelected: Bool
    @Binding var taskNotes: [Notes]
    @Binding var taskTapped: Task
    @Binding var selectedDay: Int
    @Binding var calendarTappedDate: Date
    
    @State var dayStatus: UserDefaults = UserDefaults.standard
    @State var dayIsChange = false
    
    @Binding var upcommingTask: Bool
    @Binding var currentPage: Int
    
    @State var dragOffset: CGFloat = 0
    @Binding var isDrag: Bool
    @Binding var isDragLeft: Bool
    @State var translationWidth: CGFloat = 0
    
    @ObservedObject var defaultSettings = DefaultSettings()
    
    init(
        viewModel: TaskViewModel,
        view: Binding<TabItemViewModel.TabItemViewType>,
        timerIsTapped: Binding<Bool>,
        notesIsTapped: Binding<Bool>,
        editIsTapped: Binding<Bool>,

        defaultDayIsSelected: Binding<Bool>,
        taskIsTapped: Binding<Bool>,
        optionIsSelected: Binding<Bool>,
        taskNotes: Binding<[Notes]>,
        taskTapped: Binding<Task>,
        selectedDay: Binding<Int>,
        calendarTappedDate: Binding<Date>,
        upcommingTask: Binding<Bool>,
        currentPage: Binding<Int>,
        isDrag: Binding<Bool>,
        isDragLeft: Binding<Bool>
    ){
        self.viewModel = viewModel
        self._view = view
        self._timerIsTapped = timerIsTapped
        self._notesIsTapped = notesIsTapped
        self._editIsTapped = editIsTapped
        
        self._defaultDayIsSelected = defaultDayIsSelected
        self._taskIsTapped = taskIsTapped
        self._optionIsSelected = optionIsSelected
        self._taskNotes = taskNotes
        self._taskTapped = taskTapped
        self._selectedDay = selectedDay
        self._calendarTappedDate = calendarTappedDate
        self._upcommingTask = upcommingTask
        self._currentPage = currentPage
        self._isDrag = isDrag
        self._isDragLeft = isDragLeft
    }

    var label: some View {
        Text("")
            .frame(width: defaultSettings.frameWidth * 0.05, height: 60)
            .background(RoundedCornersStyle(color: viewModel.taskColorIndex == 0 || viewModel.taskColorIndex > 7 ? Color.viewColor : Color.taskColors[viewModel.taskColorIndex], tl: 10, tr: 0, bl: 10, br: 0))
    }
        
    var circleCheckView: some View {
        VStack {
            Button(action: {
                viewModel.send(action: .toggleComplete)
            }) {
                if !viewModel.isTaskComplete {
                    Circle()
                        .stroke(lineWidth: 1.6)
                        .frame(width: 24)
                        .foregroundColor(Color.tickColor)
                }
                else {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 26))
                        .foregroundColor(Color.green)
                }
            }
        }
        .opacity(displayTick(viewModel) ? 1 : 0)
    }
    
    var taskInfo: some View {
        VStack(alignment: .leading, spacing: 6.75) {
            HStack {
                Text(viewModel.taskTitle)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.leading, 2)
            }
            
            HStack {
                if !viewModel.taskWorkDaysReminderStrDate.isEmpty {
                    Text(viewModel.taskWorkDaysReminderStrDate)
                        .font(.system(size: 10))
                        .foregroundColor(Color.textColor)
                        .frame(width: 50, height: 12, alignment: .leading)
                }
                
                if viewModel.taskWorkDate != nil {
                    if defaultSettings.getFormattedDateII(viewModel.taskWorkDate!) == defaultSettings.getFormattedDateII(Date()) {
                        Text("Today")
                            .font(.system(size: 10))
                            .foregroundColor(Color.textColor)
                    }
                    else {
                        Text("\(defaultSettings.getFormattedDateI(viewModel.taskWorkDate!))")
                            .font(.system(size: 10))
                            .foregroundColor(Color.textColor)
                    }
                }

                ForEach(viewModel.taskWorkDays, id: \.self) { index in
                    Text("\(viewModel.workDays[index])")
                        .font(.system(size: 10))
                        .foregroundColor(Color.textColor)
                        .frame(width: index == 7 ? nil : 24 )
                }
            }
            .padding(.leading, 2)
        }
    }
    
    var body: some View {
        ZStack {
            // Drag options
            if isDrag {
                VStack {
                    Image(systemName: "trash")
                        .foregroundColor(Color.white)
                        .font(.system(size: 18))
                        .padding(.trailing, 20)
                        .frame(width: abs(dragOffset) > 6 ? abs(dragOffset)-6 : 0, height: 58, alignment: .trailing)
                        .background(Color(#colorLiteral(red: 1, green: 0.3333333333, blue: 0.2901960784, alpha: 1)))
                }
                .frame(width: defaultSettings.frameWidth, height: 60, alignment: .trailing)
            }
            
            else if isDragLeft {
                VStack {
                    Image(systemName: viewModel.isTaskComplete ? "arrow.uturn.left" : "checkmark")
                        .foregroundColor(viewModel.isTaskComplete ? Color.textColor.opacity(0.75) : Color.white)
                        .font(.system(size: 18))
                        .padding(.leading, abs(dragOffset)*0.45)
                        .frame(width: dragOffset > 6 ? dragOffset-6 : 0, height: 58, alignment: .leading)
                        .background(viewModel.isTaskComplete || dragOffset < 120 ? Color.viewColor : Color(#colorLiteral(red: 0.3098039216, green: 0.9411764706, blue: 0.3333333333, alpha: 1)))
                }
                .frame(width: defaultSettings.frameWidth, height: 60, alignment: .leading)
            }

            HStack(spacing: 10) {
                label
                    .frame(width: defaultSettings.frameWidth * 0.02)
                
                taskInfo
                    .padding(.leading, viewModel.taskColorIndex == 0 || viewModel.taskColorIndex > 7 ? -8 : 2)
                    .frame(width: defaultSettings.frameWidth * 0.72, alignment: .leading)
                
                circleCheckView
                    .padding(.leading, 10)
                    .frame(width: defaultSettings.frameWidth * 0.25, alignment: .center)
                    .opacity(upcommingTask ? 0 : 1)
            }
            .frame(width: defaultSettings.frameWidth, height: 60, alignment: .leading)
            .background(Color.viewColor)
            .cornerRadius(10)
            .offset(x: dragOffset)
        }
        .padding(.vertical, 0.3)
            
        // Tap task action
        .onTapGesture {
            taskIsTapped = true
            taskTappedAction()
        }
        
        .onChange(of: isDrag) { _ in
            dragOffset = 0
        }
                
        // Resign app - Save resign date
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            dayStatus.set(Date(), forKey: "todayDate")
        }
        
        // Reenter app - Retrieve saved date
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            let date = self.dayStatus.object(forKey: "todayDate") as! Date
            
            // Not same day
            if defaultSettings.getFormattedDateII(Date()) != defaultSettings.getFormattedDateII(date) {
                print("NOT SAME DAY")
                if viewModel.isTaskComplete {
                    viewModel.send(action: .toggleComplete)
                }
            }
            else {
                print("SAME DAY")
            }
        }
    }
    
    func change(value: DragGesture.Value) {
        taskTappedAction()
        
        withAnimation {
            dragOffset = value.translation.width
        }
            
        if value.translation.width > 0 {
            isDrag = false
            isDragLeft = true
        }
        else {
            isDrag = true
            isDragLeft = false
        }
    }
    
    func end(value: DragGesture.Value) {
        if currentPage != 1 {
            if value.translation.width > 0 && value.translation.width < 120 {
                withAnimation {
                    dragOffset = 0
                    isDragLeft = false
                }
            }
            else {
                withAnimation {
                    dragOffset = 0
                    isDrag = false
                }
            }
            
            if value.translation.width > 120 {
                withAnimation {
                    viewModel.send(action: .toggleComplete)
                    dragOffset = 0
                    isDragLeft = false
                }
            }
            else {
                isDrag = false
                // TODO: Delete task
//                taskViewOptionsViewModel.send(option: .delete)
                dragOffset = 0
            }
        }
    }
    
    func displayTopdayTask(_ viewModel: TaskViewModel) -> Bool {
        if viewModel.taskWorkDate != nil {
            let taskDate = defaultSettings.getFormattedDateII(viewModel.taskWorkDate!)
            let todayDate = defaultSettings.getFormattedDateII(Date())
            let con1 = taskDate == todayDate
            return con1
        }
        else {
            return false
        }
    }

    func displayTick(_ viewModel: TaskViewModel) -> Bool {
        var flag = false
        let weekDay = Date().getWeekDay(date: Date())
        let isToday = defaultSettings.getFormattedDateII(calendarTappedDate) == defaultSettings.getFormattedDateII(Date())
        
        if viewModel.taskWorkDays.contains(7) && isToday {
            flag = true
        }
        else if viewModel.taskWorkDate != nil && defaultSettings.getFormattedDateII(viewModel.taskWorkDate!) == defaultSettings.getFormattedDateII(Date()) {
            flag = true
        }
        else {
            for day in viewModel.taskWorkDays {
                if day == weekDay && isToday {
                    flag = true
                    break
                }
                else {
                    flag = false
                }
            }
        }
        
        return flag
    }
    
    func taskTappedAction() {
        let task = Task(
                        id: viewModel.id,
                        taskTitle: viewModel.taskTitle,
                        taskColorIndex: viewModel.taskColorIndex,
                        taskWorkDays: viewModel.taskWorkDays,
                        taskWorkDate: viewModel.taskWorkDate,
                        taskWorkDaysReminderId: viewModel.taskWorkDaysReminderId,
                        taskWorkDaysReminderDate: viewModel.taskWorkDaysReminderDate,
                        activities: viewModel.activities,
                        createdAt: viewModel.createdAt,
//                            position: 0,
                        userId: viewModel.userId
                    )
        taskTapped = task
        optionIsSelected = false
    }
}


struct WeekTaskView: View {
    private let viewModel: TaskViewModel
    @StateObject var newTaskViewModel = NewTaskViewModel()
    @Binding var view: TabItemViewModel.TabItemViewType
    @Binding var timerIsTapped: Bool
    @Binding var notesIsTapped: Bool
    @Binding var editIsTapped: Bool
    
    @Binding var defaultDayIsSelected: Bool
    @Binding var taskIsTapped: Bool
    @Binding var optionIsSelected: Bool
    @Binding var taskNotes: [Notes]
    @Binding var taskTapped: Task
    @Binding var selectedDay: Int
    @Binding var calendarTappedDate: Date
    
    @State var dayStatus: UserDefaults = UserDefaults.standard
    @State var dayIsChange = false
    
    @Binding var upcommingTask: Bool
    @Binding var currentPage: Int
    
    @State var dragOffset: CGFloat = 0
    @Binding var isDrag: Bool
    @Binding var isDragLeft: Bool
    @State var translationWidth: CGFloat = 0
    
    private let defaultSettings = DefaultSettings()
    
    init(
        viewModel: TaskViewModel,
        view: Binding<TabItemViewModel.TabItemViewType>,
        timerIsTapped: Binding<Bool>,
        notesIsTapped: Binding<Bool>,
        editIsTapped: Binding<Bool>,

        defaultDayIsSelected: Binding<Bool>,
        taskIsTapped: Binding<Bool>,
        optionIsSelected: Binding<Bool>,
        taskNotes: Binding<[Notes]>,
        taskTapped: Binding<Task>,
        selectedDay: Binding<Int>,
        calendarTappedDate: Binding<Date>,
        upcommingTask: Binding<Bool>,
        currentPage: Binding<Int>,
        isDrag: Binding<Bool>,
        isDragLeft: Binding<Bool>
    ){
        self.viewModel = viewModel
        self._view = view
        self._timerIsTapped = timerIsTapped
        self._notesIsTapped = notesIsTapped
        self._editIsTapped = editIsTapped
        
        self._defaultDayIsSelected = defaultDayIsSelected
        self._taskIsTapped = taskIsTapped
        self._optionIsSelected = optionIsSelected
        self._taskNotes = taskNotes
        self._taskTapped = taskTapped
        self._selectedDay = selectedDay
        self._calendarTappedDate = calendarTappedDate
        self._upcommingTask = upcommingTask
        self._currentPage = currentPage
        self._isDrag = isDrag
        self._isDragLeft = isDragLeft
    }

    var label: some View {
        Text("")
            .frame(width: defaultSettings.frameWidth * 0.05, height: 60)
            .background(RoundedCornersStyle(color: viewModel.taskColorIndex == 0 || viewModel.taskColorIndex > 7 ? Color.viewColor : Color.taskColors[viewModel.taskColorIndex], tl: 10, tr: 0, bl: 10, br: 0))
    }
            
    var taskInfo: some View {
        VStack(alignment: .leading, spacing: 6.75) {
            HStack {
                Text(viewModel.taskTitle)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.leading, 2)
            }
            
            HStack {
                if !viewModel.taskWorkDaysReminderStrDate.isEmpty {
                    Text(viewModel.taskWorkDaysReminderStrDate)
                        .font(.system(size: 10))
                        .foregroundColor(Color.textColor)
                        .frame(width: 50, height: 12, alignment: .leading)
                }
                
                if viewModel.taskWorkDate != nil {
                    if defaultSettings.getFormattedDateII(viewModel.taskWorkDate!) == defaultSettings.getFormattedDateII(Date()) {
                        Text("Today")
                            .font(.system(size: 10))
                            .foregroundColor(Color.textColor)
                    }
                    else {
                        Text("\(defaultSettings.getFormattedDateI(viewModel.taskWorkDate!))")
                            .font(.system(size: 10))
                            .foregroundColor(Color.textColor)
                    }
                }

                ForEach(viewModel.taskWorkDays, id: \.self) { index in
                    Text("\(viewModel.workDays[index])")
                        .font(.system(size: 10))
                        .foregroundColor(Color.textColor)
                        .frame(width: index == 7 ? nil : 24 )
                }
            }
            .padding(.leading, 2)
        }
    }
    
    var body: some View {
        HStack(spacing: 10) {
            label
                .frame(width: defaultSettings.frameWidth * 0.02)
                
            taskInfo
                .padding(.leading, viewModel.taskColorIndex == 0 || viewModel.taskColorIndex > 7 ? -8 : 2)
                .frame(width: defaultSettings.frameWidth * 0.72, alignment: .leading)
        }
        .frame(width: defaultSettings.frameWidth, height: 60, alignment: .leading)
        .background(Color.viewColor)
        .cornerRadius(10)
        .offset(x: dragOffset)
        .padding(.vertical, 0.3)
        
        // Tap task action
        .onTapGesture { taskTappedAction() }
    }
    
    
    func taskTappedAction() {
        withAnimation {
            taskIsTapped = true
            let task = Task(
                            id: viewModel.id,
                            taskTitle: viewModel.taskTitle,
                            taskColorIndex: viewModel.taskColorIndex,
                            taskWorkDays: viewModel.taskWorkDays,
                            taskWorkDate: viewModel.taskWorkDate,
                            taskWorkDaysReminderId: viewModel.taskWorkDaysReminderId,
                            taskWorkDaysReminderDate: viewModel.taskWorkDaysReminderDate,
//                            taskDueDayReminderDate: viewModel.taskDueDayReminderDate,
                            activities: viewModel.activities,
                            createdAt: viewModel.createdAt,
//                            position: 0,
                            userId: viewModel.userId
                        )
            taskTapped = task
            optionIsSelected = false
        }
    }
}



