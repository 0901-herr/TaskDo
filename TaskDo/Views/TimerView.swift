//
//  TimerView.swift
//  TaskDo
//
//  Created by Philippe Yong on 27/01/2021.
//

import SwiftUI

struct TimerView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @ObservedObject var viewModel: TimerViewModel
    
    @Binding var timerIsTapped: Bool
    @Binding var timerIsCompleted: Bool
    @Binding var tagIsTapped: Bool
    @Binding var taskTapped: Task
    
    @Binding var offset: CGFloat
    
    @Binding var focusModeIsOn: Bool
    @Binding var showPopUp: Bool
    @Binding var timerIsDragged: Bool
    
    @Binding var timerSettingsIsTapped: Bool

    @ObservedObject var defaultSettings = DefaultSettings()
    
    var navButtons: some View {
        HStack {
            Button(action: {
                timerIsTapped = false
            }) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color.primaryColor2)
            }
            
            Spacer()
            
            timerSettings
        }
        .frame(width: defaultSettings.frameWidth)
    }
    
    var tags: some View {
        HStack(spacing: 15) {
            Button(action: {
                tagIsTapped = true
            }) {
                ZStack {
                    Circle()
                        .foregroundColor(viewModel.tagOptions[viewModel.selectedTagIndex].color)
                        .frame(width: 30, height: 30)
                    if viewModel.tagOptions[viewModel.selectedTagIndex].imageName == "exercise" {
                        Image("exercise")
                            .resizable()
                            .frame(width: 14, height: 14)
                            .foregroundColor(Color.white)
                    }
                    else {
                        Image(systemName: viewModel.tagOptions[viewModel.selectedTagIndex].imageName)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.white)
                    }
                }
                .frame(width: 30, height: 30)
            }
            if !taskTapped.taskTitle.isEmpty {
                Text(taskTapped.taskTitle)
                    .font(.system(size: 18, weight: .medium))
            }
            Spacer()
        }
        .frame(width: defaultSettings.frameWidth)
    }
    
    var timerSettings: some View {
        Button(action: {
            withAnimation {
                timerSettingsIsTapped = true
            }
        }) {
            HStack(spacing: 2) {
                ForEach(0..<3) { _ in
                    Circle()
                        .frame(width: 7, height: 7)
                        .foregroundColor(Color.primaryColor2)
                }
            }
        }
        .opacity(viewModel.firstStart ? 0 : 1)
    }
    
    var timeCircle: some View {
        ZStack {
            Circle()
                .fill(Color.primaryColor)
                .opacity(timerIsTapped ? 0 : 1)
            Circle()
                .stroke(style: .init(lineWidth: timerIsTapped ? 5 : 4, lineCap: .round, lineJoin: .round))
                .fill(Color.timerColor)
            Circle()
                .trim(from: 0.0, to: viewModel.firstStart ? CGFloat(viewModel.percentage) : 0)
                .stroke(style: .init(lineWidth: timerIsTapped ? 5 : 4, lineCap: .round, lineJoin: .round))
                .fill(Color.taskColors[taskTapped.taskColorIndex].opacity(taskTapped.taskColorIndex==0 ? 0.75 : 1))
                .rotationEffect(.init(degrees: -90))

            if timerIsTapped && !viewModel.firstStart {
                VStack {
                    Picker(selection: $viewModel.selectedTimerValueIndex, label: Text("")) {
                        ForEach(viewModel.timerValueSelections, id: \.self) { item in
                            Text("\(item)")
                                .font(.system(size: 24, weight: .regular))
                                .foregroundColor(Color.primaryColor2)
                        }
                    }
                    .frame(width: 80, height: (defaultSettings.frameWidth - 120)*0.4)
                    .clipped()
                    .scaleEffect(x: 1.1, y: 1.1)
                                        
                    Text("min")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 50)
                        .padding(.top, 6)
                }
                .opacity(timerIsTapped ? 1 - Double(offset)/110 : 0)
            }
            
            else {
                VStack(spacing: 20) {
                    VStack {
                        Text("\(viewModel.firstStart ? viewModel.minute : viewModel.selectedTimerValueIndex)")
                            .font(.system(size: timerIsTapped ? 42 : 16, weight: .medium))
                            .padding(.top, timerIsTapped ? offset/5 : 0)
                    }
                    .frame(width: 100, alignment: .center)
                    .onAppear {
                        viewModel.intervalValue = defaultSettings.defaultValues.integer(forKey: "intervalValue")
                        viewModel.getTimerInterval()
                        viewModel.selectedTimerValueIndex = defaultSettings.defaultValues.integer(forKey: "selectedTimerValueIndex")

                        print("timer value selections: \(viewModel.timerValueSelections)")
                        print("timer index: \(viewModel.selectedTimerValueIndex)")
                    }

                    if timerIsTapped && viewModel.firstStart {
                        HStack {
                            Text(":")
                                .font(.system(size: 22, weight: .medium))
                            VStack {
                                Text("\(viewModel.getTimeStr(viewModel.second))")
                                    .font(.system(size: 22, weight: .medium))
                            }
                            .frame(width: 40, alignment: .center)
                        }
                        .opacity(timerIsTapped ? 1 - Double(offset)/110 : 0)
                    }
                }
                .animation(.none)
            }
        }
        .frame(width: timerIsTapped ? defaultSettings.frameWidth - 65 - (offset*0.45) : 56, height: timerIsTapped ? defaultSettings.frameWidth - 65 - (offset*0.45) : 56)
    }
    
    var buttons: some View {
        HStack(spacing: 20) {
            ForEach(viewModel.buttonActions.indices, id: \.self) { index in
                if viewModel.action == viewModel.buttonActions[index].action {
                    Button(action: {
                        viewModel.taskId = taskTapped.id!
                        viewModel.taskTitle = taskTapped.taskTitle
                        viewModel.taskColorIndex = taskTapped.taskColorIndex
                        withAnimation {
                            viewModel.send(action: viewModel.buttonActions[index].action)
                        }
                    }) {
                        HStack {
                            if let imageName = viewModel.buttonActions[index].imageName {
                                Image(systemName: imageName)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color.white)
                            }
                            Text(viewModel.buttonActions[index].buttonTitle)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color.white)
                        }
                        .frame(width: 110, height: 55, alignment: .center)
                        .background(Color.taskColors[taskTapped.taskColorIndex].opacity(taskTapped.taskColorIndex==0 ? 0.75 : 1))
                        .cornerRadius(30)
                    }
                }
            }
            
            if viewModel.action == viewModel.buttonActions[2].action {
                Button(action: {
                    withAnimation {
                        viewModel.send(action: viewModel.buttonActions[3].action)
                    }
                }) {
                    HStack {
                        Text(viewModel.buttonActions[3].buttonTitle)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.taskColors[taskTapped.taskColorIndex])
                    }
                    .frame(width: 110, height: 55, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.taskColors[taskTapped.taskColorIndex], lineWidth: 1.6)
                            .opacity(taskTapped.taskColorIndex==0 ? 0.75 : 1)
                    )
                }
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                if timerIsTapped {
                    VStack(spacing: 20) {
                        navButtons
                        tags
                }
                .padding(.top, 20)
                .opacity(timerIsTapped ? 1 - Double(offset)/120 : 0)
                
                Spacer()
                    .opacity(timerIsTapped ? 1 - Double(offset)/120 : 0)
                }
                
                VStack(spacing: timerIsTapped ? 60 : 0) {
                    timeCircle
                    buttons
                        .opacity(timerIsTapped ? 1 - Double(offset)/120 : 0)
                }
                
                Spacer()
                    .frame(height: timerIsTapped ? defaultSettings.screenHeight*0.2 : 4)
            }
        }
        
        .onAppear {
            // App is refreshed
//            viewModel.resetTimer()
            print("DID REFRESHED")
            viewModel.fetchTimerValue()
            print("TIMER IS ON: \(viewModel.start)")
            if viewModel.start {
                viewModel.restoreTimerValue()
                startTimer()
            }
        }
        
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            print("DID BECOME ACTIVE")
            viewModel.fetchTimerValue()
            
            if viewModel.start {
                viewModel.restoreTimerValue()
                startTimer()
            }
        }
        
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            print("DID RESIGNED")
            // stop timer
            viewModel.isActive = false
            
            // record resign date
            viewModel.recordResignDate()
            
            // save timer value and resign date
            viewModel.saveTimerValue()
        }
        
        .onReceive(viewModel.timer) { (_) in
            if viewModel.isActive {
                if viewModel.start {
                    startTimer()
                }
            }
        }
    }
    
    public func delayCode() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            self.showPopUp = false
        }
    }
    
    public func startTimer() {
        if viewModel.time > 0 {
            viewModel.time -= 1
            let timerValueSec = viewModel.timerValue * 60
            viewModel.minute = Int(Double(viewModel.time) / 60)
            viewModel.second = viewModel.time % 60
            viewModel.percentage = Double(timerValueSec - viewModel.time) / Double(timerValueSec)
        }
        else {
            sessionCompleted()
        }
    }
    
    public func sessionCompleted() {
        print("FINISHED")
        timerIsCompleted = true
        
        // add record
        if viewModel.focusRecord.count < 1 {
            viewModel.focusRecord.append(FocusRecord(date: viewModel.startDate, focusTime: viewModel.timerValue*60))
            print("NO PAUSE")
        }
        else {
            let totalSec = viewModel.focusRecord.map { $0.focusTime }.reduce(0, +)
            let lastSessionFocusSec = viewModel.timerValue*60 - totalSec
            viewModel.focusRecord.append(FocusRecord(date: viewModel.startDate, focusTime: lastSessionFocusSec))
            print("GOT PAUSE")
        }
        
        print("TOTAL FOCUS RECORD: \(viewModel.focusRecord)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.timerIsCompleted = false
        }

        if viewModel.focusRecord[0].focusTime > 0 {
            viewModel.saveFocusTime()
            viewModel.resetTimer()
        }
    }
}

