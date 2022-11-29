//
//  TaskView.swift
//  TaskDo
//
//  Created by Philippe Yong on 23/01/2021.
//

import SwiftUI
import UniformTypeIdentifiers
import FSCalendar

struct TaskListView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false

    @StateObject var viewModel = TaskListViewModel()
    
    @StateObject var calendarListViewModel = CalendarListViewModel()
    @StateObject var calendarViewModel = CalendarViewModel()
    @StateObject var newTaskViewModel: NewTaskViewModel
    @StateObject var calendarActionViewModel = CalendarActionViewModel()

    @State var myCalendarItem = MyCalendarItem(date: Date(), month: Date(), isSwipe: false, dateIsTapped: false, calendarPad: -190, scope: .week)


    @State var selectedDay = 0
    @State var defaultDayIsSelected = true
    
    @Binding var view: TabItemViewModel.TabItemViewType
    @Binding var timerIsTapped: Bool
    @Binding var taskIsTapped: Bool
    @Binding var editIsTapped: Bool
    @Binding var optionIsSelected: Bool
    @Binding var taskTapped: Task

    @State var isDrag = false
    @State var isDragLeft = false
    
    @Binding var taskNotes: [Notes]
    @Binding var notesIsTapped: Bool
    
    @State var showCalendar = false
    
    @Binding var profileIsTapped: Bool
    @Binding var taskDisplayOptionIsTapped: Bool
    @Binding var taskDisplayType: TaskDisplayAction
    @Binding var taskDisplayDetail: TaskDisplayOption
    
    @State var upcommingTask1 = false
    @State var upcommingTask2 = false
    @State var selectedWeek: [Date] = []
    @State var counterIndex = 0

    @State private var dragging: TaskViewModel?

    @ObservedObject var defaultSettings = DefaultSettings()
    let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    @State var todayTasksList = []
    @State var dateSetIsFinished = false

    var todayTasks: some View {
        VStack {
            LazyVGrid(columns: viewModel.columns) {
                if viewModel.finishedLoading {
                    ForEach(viewModel.selectedDayTask) { viewModel in
                        TaskView(viewModel: viewModel, view: $view, timerIsTapped: $timerIsTapped, notesIsTapped: $notesIsTapped, editIsTapped: $editIsTapped, defaultDayIsSelected: $defaultDayIsSelected, taskIsTapped: $taskIsTapped, optionIsSelected: $optionIsSelected, taskNotes: $taskNotes, taskTapped: $taskTapped, selectedDay: $selectedDay, calendarTappedDate: $myCalendarItem.date, upcommingTask: $upcommingTask1, currentPage: self.$counterIndex, isDrag: $isDrag, isDragLeft: $isDragLeft)
                            
                            .overlay(dragging?.id == viewModel.id ? Color.viewColor.opacity(0.4) : Color.clear.opacity(0.4))
                            
                            .onDrag {
                                self.dragging = viewModel
                                return NSItemProvider(object: String(viewModel.id) as NSString)
                            }
                            
                            .onDrop(of: [UTType.text], delegate: DragRelocateDelegate(item: viewModel, listData: $viewModel.selectedDayTask, current: $dragging))
                    }
                }
            }
        }
    }
    
    var thisWeekTasks: some View {
        VStack {
            ForEach(0..<7) { day in
                VStack {
                    HStack {
                        Text("\(weekdays[day])")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(getFormattedDateXI(Date()) == getFormattedDateXI(Date().getSelectedWeekDates(date: myCalendarItem.date)[day]) ? Color.taskColors[defaultSettings.defaultValues.integer(forKey: "tone")] : Color.primaryColor2)

                        Spacer()
                        
                        if dateSetIsFinished {
                            Text("\(getFormattedDateXI(selectedWeek[day]))")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(getFormattedDateXI(Date()) == getFormattedDateXI(selectedWeek[day]) ? Color.taskColors[defaultSettings.defaultValues.integer(forKey: "tone")] : Color.primaryColor2)
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.bottom, 6)
                    .frame(width: defaultSettings.frameWidth, alignment: .leading)
                    .onTapGesture {
                        // TODO: Calendar select day
                        calendarActionViewModel.selectDate = true
                        calendarActionViewModel.date = selectedWeek[day]
                        
                        myCalendarItem.date = selectedWeek[day]
                        newTaskViewModel.reset()
                        newTaskViewModel.taskWorkDate = myCalendarItem.date
                        withAnimation {
                            viewModel.addTaskPushed.toggle()
                        }
                    }
                    
                    if viewModel.finishedLoading {
                        ForEach(viewModel.selectedWeekTask[day]) { viewModel in
                            WeekTaskView(viewModel: viewModel, view: $view, timerIsTapped: $timerIsTapped, notesIsTapped: $notesIsTapped, editIsTapped: $editIsTapped, defaultDayIsSelected: $defaultDayIsSelected, taskIsTapped: $taskIsTapped, optionIsSelected: $optionIsSelected, taskNotes: $taskNotes, taskTapped: $taskTapped, selectedDay: $selectedDay, calendarTappedDate: $myCalendarItem.date, upcommingTask: $upcommingTask1, currentPage: self.$counterIndex, isDrag: $isDrag, isDragLeft: $isDragLeft)
                        }
                    }
    
                    VStack {
                        Text("")
                            .font(.system(size: 16))
                            .foregroundColor(Color.primaryColor)
                    }
                    .frame(width: defaultSettings.frameWidth, height: 40, alignment: .center)
                    .background(Color.primaryColor)
                    .cornerRadius(10)
                    .onTapGesture {
//                        calendarViewModel.calendar.select(selectedWeek[day])
                        // TODO: Calendar select day
                        calendarActionViewModel.selectDate = true
                        calendarActionViewModel.date = selectedWeek[day]
                        
                        myCalendarItem.date = selectedWeek[day]
                        newTaskViewModel.reset()
                        newTaskViewModel.taskWorkDate = myCalendarItem.date
                        withAnimation {
                            viewModel.addTaskPushed.toggle()
                        }
                    }
                }
            }
            .padding(.top, 6)
        }
        .onAppear {
            selectedWeek = Date().getWeekDates(Date())
            dateSetIsFinished = true
        }
    }
    
    var taskList: some View {
        DoublePagerView(pageCount: 2, currentIndex: self.$counterIndex) {
            VStack {
                HStack {
                    Text("\(getFormattedDateXI(myCalendarItem.date) == getFormattedDateXI(Date()) ? "Today" : getFormattedDateXI(myCalendarItem.date))")
                        .font(.system(size: 18, weight: .semibold))

                    Spacer()
                }
                .frame(width: defaultSettings.frameWidth)

                ScrollView(.vertical, showsIndicators: false) {
                    todayTasks
                        .frame(width: defaultSettings.screenWidth)
                    Spacer()
                        .padding(.bottom, 20)
                }
                .padding(.top, 10)
                .frame(width: UIScreen.main.bounds.width)
                .onDrop(of: [UTType.text], delegate: DropOutsideDelegate(current: $dragging))
            }
            .tag(0)
            .padding(.bottom, 4)

            
            VStack {
                HStack {
                    Text("Week")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Spacer()
                }
                .frame(width: defaultSettings.frameWidth)

                ScrollView(.vertical, showsIndicators: false) {
                    thisWeekTasks
                        .frame(width: defaultSettings.screenWidth)
                    Spacer()
                        .padding(.bottom, 60)
                }
                .padding(.top, 4)
            }
            .frame(width: UIScreen.main.bounds.width)
            .tag(1)
        }
        .frame(width: defaultSettings.screenWidth)
        
        .onChange(of: myCalendarItem.isSwipe) { _ in
            print("CALENDAR DATE: \(myCalendarItem.date)")
            selectedWeek = Date().getSelectedWeekDates(date: myCalendarItem.date)
            viewModel.reloadTask(date: myCalendarItem.date)
        }
        
        .onChange(of: myCalendarItem.dateIsTapped) { _ in
            print("DATE TAPPED")
            selectedWeek = Date().getSelectedWeekDates(date: myCalendarItem.date)
            viewModel.reloadTask(date: myCalendarItem.date)
        }
        
        .onTapGesture {
            // Dragged task
            isDrag = false
            isDragLeft = false
        }
    }
    
    var chosenPage: some View {
        HStack(spacing: 8) {
            Circle()
                .frame(width: counterIndex == 0 ? 10 : 7)
                .foregroundColor(counterIndex == 0 ? Color.taskColors[defaultSettings.defaultValues.integer(forKey: "tone")] : Color.smallButtonColor)
            
            Circle()
                .frame(width: counterIndex == 1 ? 10 : 7)
                .foregroundColor(counterIndex == 1 ? Color.taskColors[defaultSettings.defaultValues.integer(forKey: "tone")] : Color.smallButtonColor)
        }
        .onTapGesture {
            self.counterIndex = (self.counterIndex == 0) ? 1 : 0
        }
    }
    
    var addTaskButton: some View {
        Button(action: {
            newTaskViewModel.reset()
            newTaskViewModel.taskWorkDate = myCalendarItem.date
            withAnimation {
                viewModel.addTaskPushed.toggle()
            }
        }) {
            ZStack {
                Circle()
                    .frame(width: 56, height: 56)
                    .foregroundColor(Color.taskColors[defaultSettings.defaultValues.integer(forKey: "tone")])
                    .shadow(color: Color.taskColors[defaultSettings.defaultValues.integer(forKey: "tone")].opacity(0.5), radius: 2.5, y: 3)
                
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.white)
            }
        }
    }
    
    var bottomLeftView: some View {
        VStack(spacing: 20) {
            chosenPage
            addTaskButton
        }
        .frame(height: 100)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CalendarListView(viewModel: calendarListViewModel, calendarViewModel: calendarViewModel, taskListViewModel: viewModel, calendarActionViewModel: calendarActionViewModel, myCalendarItem: $myCalendarItem, selectedDay: $selectedDay, defaultDayIsSelected: $defaultDayIsSelected, showCalendar: $showCalendar, profileIsTapped: $profileIsTapped)
                    .onAppear {
                        self.selectedDay = calendarListViewModel.daySelected
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
                            calendarListViewModel.thisWeekDays = Date().getFutureWeekDays()
                    }
                    .padding(.top, 14)

                taskList
                    .padding(.top, myCalendarItem.calendarPad+4)
            }
        
            bottomLeftView
                .padding(.bottom, 10)
                .frame(width: defaultSettings.frameWidth, height: defaultSettings.screenHeight*0.84, alignment: .bottomTrailing)
        }
        .animation(.none)
        .frame(width: defaultSettings.frameWidth)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: editIsTapped ? self.$editIsTapped : $viewModel.addTaskPushed) {
            NewTaskView(viewModel: newTaskViewModel, taskListViewModel: viewModel, addTaskPushed: $viewModel.addTaskPushed, editIsTapped: $editIsTapped, myCalendarItem: $myCalendarItem)
        }
    }
    
    
    // ====== Functions =======
    
    public func displayTodayTask(_ viewModel: TaskViewModel) -> Bool {
        print("DISPLAY TODAY TASK")

        let day = Date().getWeekDay(date: myCalendarItem.date)
        var flag = false
        
        // For everyday
        if viewModel.taskWorkDays.contains(7) {
            flag = true
        }
        // For week days
        else if viewModel.taskWorkDays.contains(day) {
            flag = true
        }
        // For selected days
        else if viewModel.taskWorkDate != nil && getFormattedDateXI(viewModel.taskWorkDate!) == getFormattedDateXI(myCalendarItem.date) {
            flag = true
        }
        
        return flag
    }
    
    public func displayThisWeekTask(_ viewModel: TaskViewModel, dayDate: Date) -> Bool {
        print("DISPLAY THIS WEEK TASK")
        
        var flag = false
        let selectedDay = Date().getWeekDay(date: dayDate)
        
        // For everyday
        if viewModel.taskWorkDays.contains(7) {
            flag = true
        }
        // For specific date
        else if viewModel.taskWorkDate != nil {
            if getFormattedDateXI(viewModel.taskWorkDate!) == getFormattedDateXI(dayDate){
                flag = true
            }
        }
        // For work days
        else {
            for day in viewModel.taskWorkDays {
                if selectedDay == day {
                    flag = true
                    break
                }
            }
        }

        return flag
    }
        
    public func getFormattedDateXI(_ date: Date) -> String {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = "dd.MM"
        
        return formattedDate.string(from: date)
    }
    
    func change(value: DragGesture.Value) {
        if value.translation.height > 20 {
            withAnimation {
                
            }
        }
        if -value.translation.height > 20 {
            withAnimation {
                
            }
        }
    }
    
    func end(value: DragGesture.Value) {
        if value.translation.height > 20 {
            withAnimation {
                showCalendar.toggle()
                calendarViewModel.month = myCalendarItem.date

                withAnimation {
                    if calendarViewModel.calendar.scope == .week {
                        calendarViewModel.calendar.scope = FSCalendarScope.month
                    }
                    else {
                        calendarViewModel.calendar.scope = FSCalendarScope.week
                    }
                }
            }
        }
        if -value.translation.height > 20 {
            withAnimation {
                showCalendar.toggle()
                calendarViewModel.month = myCalendarItem.date

                withAnimation {
                    if calendarViewModel.calendar.scope == .week {
                        calendarViewModel.calendar.scope = FSCalendarScope.month
                    }
                    else {
                        calendarViewModel.calendar.scope = FSCalendarScope.week
                    }
                }

            }
        }
    }

}

struct PullToRefresh: View {
    var coordinateSpaceName: String
    @Binding var showCalendar: Bool
    
    var onPull: ()->Void
    
    var body: some View {
        GeometryReader { geo in
            if (geo.frame(in: .named(coordinateSpaceName)).midY > 190) {
                Spacer()
                    .onAppear {
                        showCalendar = true
                        print(geo.frame(in: .named(coordinateSpaceName)).midY)
                        print("SHOW CALENDAR: \(showCalendar)")
                    }
            }
            if !showCalendar {
                HStack {
                    Spacer()
                    Text("CALENDAR")
                        .font(.system(size: 18))
                        .foregroundColor(Color.textColor)
                    Image(systemName: "calendar")
                        .font(.system(size: 18))
                        .foregroundColor(Color.textColor)
                    Spacer()
                }
                .padding(.top, 6)
            }
        }
        .padding(.top, -50)
    }
}

enum TaskModalType {
    case newTask
    case editTask
}



//struct TaskListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TaskListView().previewDevice("iPhone 11 Pro")
////        TaskListView().previewDevice("iPhone 8")
//    }
//}

