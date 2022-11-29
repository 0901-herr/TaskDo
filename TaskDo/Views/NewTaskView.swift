//
//  NewTaskView.swift
//  TaskDo
//
//  Created by Philippe Yong on 23/01/2021.
//

import SwiftUI

struct NewTaskView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @StateObject var viewModel: NewTaskViewModel
    @StateObject var taskListViewModel: TaskListViewModel
    @State var date = Date()
    @Binding var addTaskPushed: Bool
    @Binding var editIsTapped: Bool
    @Binding var myCalendarItem: MyCalendarItem
    
    @ObservedObject var defaultSettings = DefaultSettings()
    
    var navigationBar: some View {
        VStack {
            HStack {
                HStack(spacing: 20) {
                    Button(action: {
                        endEditing(true)
                        withAnimation {
                            self.addTaskPushed = false
                        }
                        self.editIsTapped = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            viewModel.reset()
                        }
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.primaryColor2)
                    }
                    
                    Text(editIsTapped ? "Edit Task" : "New Task")
                        .font(.system(size: 20, weight: .bold))
                }
                
                Spacer()
                
                Button(action: {
                    endEditing(true)
                    if !viewModel.taskTitle.isEmpty {
                        saveTask()
                    }
                    myCalendarItem.date = viewModel.taskWorkDate
                    myCalendarItem.dateIsTapped.toggle()
                }){
                    Text("Save")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(viewModel.taskColorIndex == 0 || viewModel.taskColorIndex > 7 ? Color.taskColors[0] : Color.taskColors[viewModel.taskColorIndex])
                        .frame(width: 65, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.taskColors[viewModel.taskColorIndex], lineWidth: 1.5)
                        )
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(width: defaultSettings.screenWidth, height: 70, alignment: .center)
        .padding(.bottom, 0)
    }
    
    var titleTextField: some View {
        VStack(spacing: 0) {
            if !editIsTapped {
                FirstResponderTextField(text: $viewModel.taskTitle, placeholder: "Title")
            }
            else {
                TextField("", text: $viewModel.taskTitle)
                    .font(.system(size: 17))
                    .padding(.bottom, 8)
            }
            
            Rectangle()
                .frame(width: defaultSettings.frameWidth, height: 1.5)
                .foregroundColor(Color.taskColors[viewModel.taskColorIndex])
        }
        .frame(width: defaultSettings.frameWidth, height: 60)
    }
    
    var workDayPicker: some View {
        VStack(spacing: 18) {
            HStack {
                Text("Workday")
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
            }
            .frame(width: defaultSettings.frameWidth)
            
            VStack(spacing: 10) {
                // top
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { index in
                        VStack {
                            Text(viewModel.workDayslist[index])
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(viewModel.workDayIsChosen(index) ? Color.taskColors[viewModel.taskColorIndex] : Color.primaryColor2)
                        }
                        .frame(width: defaultSettings.frameWidth/7 - 6, height: 40)
                        .onTapGesture {
                            endEditing(true)
                            viewModel.addWorkDay(index)
                            viewModel.workDateIsSet = false
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(viewModel.workDayIsChosen(index) ?  Color.taskColors[viewModel.taskColorIndex] : Color.viewColor, lineWidth: 1.5)
                        )
                    }
                    .frame(width: defaultSettings.frameWidth / 7)
                }
                    
                // bottom
                HStack {
                    VStack(spacing: 4) {
                        HStack {
                            Button(action: {
                                viewModel.taskWorkDate = Date().getNextDay(date: viewModel.taskWorkDate, -1)
                            }) {
                                Image(systemName: "arrowtriangle.left")
                                    .font(.system(size: 16))
                                    .foregroundColor(viewModel.workDateIsSet ? Color.taskColors[viewModel.taskColorIndex] : Color.primaryColor2)
                            }
                            .padding(.leading, 4)
                            
                            Spacer()
                            
                            Text("\(setTaskWorkDate(viewModel.taskWorkDate))")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(viewModel.workDateIsSet ? Color.taskColors[viewModel.taskColorIndex] : Color.primaryColor2)
                                .frame(width: 70, height: 44)
                            
                            Spacer()

                            Button(action: {
                                viewModel.taskWorkDate = Date().getNextDay(date: viewModel.taskWorkDate, 1)
                            }) {
                                Image(systemName: "arrowtriangle.right")
                                    .font(.system(size: 16))
                                    .foregroundColor(viewModel.workDateIsSet ? Color.taskColors[viewModel.taskColorIndex] : Color.primaryColor2)
                            }
                            .padding(.trailing, 4)
                        }
                        .frame(height: 44)
                        
                        Rectangle()
                            .frame(width: defaultSettings.frameWidth/2-12, height: 1.5)
                            .foregroundColor(viewModel.workDateIsSet ?  Color.taskColors[viewModel.taskColorIndex] : Color.viewColor)
                    }
                    .frame(width: defaultSettings.frameWidth/2-6, height: 44)
                    .onTapGesture {
                        endEditing(true)
                        viewModel.workDateIsSet = true
                        viewModel.taskWorkDays = []
                    }
                    
                    VStack(spacing: 4) {
                        HStack {
                            Text(viewModel.workDayslist[7])
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(viewModel.workDayIsChosen(7) && !viewModel.workDateIsSet ? Color.taskColors[viewModel.taskColorIndex] : Color.primaryColor2)
                        }
                        .frame( height: 44)
                        
                        Rectangle()
                            .frame(width: defaultSettings.frameWidth/2-12, height: 1.5)
                            .foregroundColor(viewModel.workDayIsChosen(7) && !viewModel.workDateIsSet ?  Color.taskColors[viewModel.taskColorIndex] : Color.viewColor)
                    }
                    .frame(width: defaultSettings.frameWidth/2-6, height: 44)
                    .onTapGesture {
                        endEditing(true)
                        viewModel.workDateIsSet = false
                        viewModel.addWorkDay(7)
                    }
                }
            }
        }
    }

    var colorPicker: some View {
        VStack(spacing: 18) {
            HStack {
                Text("Color")
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
            }
            .frame(width: defaultSettings.frameWidth)
            
            HStack {
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(0..<8, id: \.self) { index in
                                if index != 0 {
                                    Circle()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(Color.taskColors[index])
                                        .onTapGesture {
                                            endEditing(true)
                                            viewModel.taskColorIndex = index
                                        }
                                }
                                else {
                                    Circle()
                                        .stroke(Color.taskColors[index], lineWidth: 1.5)
                                        .frame(width: 40, height: 40)
                                        .onTapGesture {
                                            endEditing(true)
                                            viewModel.taskColorIndex = index
                                        }
                                }
                            }
                        }
                        .frame(height: 50)
                        .padding(.leading, defaultSettings.frameWidth*0.05+6)
                        .padding(.trailing, 8)
                    }
                }
                .frame(width: defaultSettings.screenWidth, height: 50)
            }
        }
    }
    
    var reminder: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Reminder")
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()

                Button(action: {
                    viewModel.onWorkDayReminder()
                }) {
                    VStack {
                        Text(viewModel.workDaysReminderOn ? "ON" : "OFF")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(viewModel.workDaysReminderOn ? Color.taskColors[viewModel.taskColorIndex] : Color.primaryColor2)
                    }
                    .frame(width: 60, height: 30)
//                    .background(Color.primaryColor)
                    .cornerRadius(20)
//                    .shadow(radius: !viewModel.workDaysReminderOn ? 2 : 0, y: !viewModel.workDaysReminderOn ? 2 : 0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(viewModel.workDaysReminderOn ? Color.taskColors[viewModel.taskColorIndex] : Color.viewColor, lineWidth: 1.5)
//                            .opacity(viewModel.workDaysReminderOn ? 1 : 0)
                    )
//                    .background(
//                        Color.smallRoundCornerBtnColor
//                            .cornerRadius(20)
//                            .opacity(viewModel.workDaysReminderOn ? 0 : 1)
//                    )
                }
            }
            .frame(width: defaultSettings.frameWidth)
            
            HStack {
                DatePicker("", selection: $viewModel.taskWorkDaysReminderDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .font(.system(size: 18))
                    .accentColor(Color.taskColors[viewModel.taskColorIndex])
                    .labelsHidden()
                    .padding(.leading, 25)
                    .opacity(viewModel.workDaysReminderOn ? 1 : 0)
            }
            .frame(width: defaultSettings.frameWidth)
        }
    }
        
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 40) {
                    titleTextField
                    workDayPicker
                    colorPicker
                    reminder
                    Spacer()
                }
                .frame(width: defaultSettings.screenWidth)
                .padding(.top, 10)
                .padding(.bottom, 20)
            }
        }
        .padding(.top, 10)
        .onTapGesture {
            self.endEditing(true)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    
    // ==== FUNCTIONS =====
    
    public func getFormattedDateII(_ date: Date) -> String {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = "dd.MM"
        return formattedDate.string(from: date)
    }
    
    public func setTaskWorkDate(_ date: Date) -> String {
        var res = ""
        if getFormattedDateII(date) == getFormattedDateII(Date()) {
            res = "Today"
        }
        else {
            res = getFormattedDateII(date)
        }
        return res
    }
    
    public func saveTask() {
        viewModel.send(action: .createNewTask)
        self.editIsTapped = false
        self.addTaskPushed = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.reset()
        }
        taskListViewModel.reloadTask = true
        taskListViewModel.reloadTask(date: viewModel.taskWorkDate)
    }
    
    func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
         if conditional {
             return AnyView(content(self))
         } else {
             return AnyView(self)
         }
     }
}
 
//struct NewTaskView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewTaskView().previewDevice("iPhone 11 Pro")//.preferredColorScheme(.dark)
//        NewTaskView().previewDevice("iPhone 8")
//    }
//}

