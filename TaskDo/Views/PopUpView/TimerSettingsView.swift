//
//  TimerSettingsView.swift
//  TaskDo
//
//  Created by Philippe Yong on 15/09/2021.
//

import SwiftUI

struct TimerSettingsView: View {
    @ObservedObject var timerViewModel: TimerViewModel
    @Binding var timerSettingsIsTapped: Bool
    @State var taskColorIndex = 0
    @State var value = 0
    @State var selectedTimerValueIndex = 60
    @State var intervalValue = 1
    @State var timerValueSelections: [Int] = []
    
    private let defaultSettings = DefaultSettings()
    
    var navigationBar: some View {
        VStack {
            HStack {
                HStack(spacing: 20) {
                    Button(action: {
                        withAnimation {
                            timerSettingsIsTapped = false
                        }
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.primaryColor2)
                    }
                    
                    Text("Settings")
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        timerSettingsIsTapped = false
                        timerViewModel.selectedTimerValueIndex = self.selectedTimerValueIndex
                        timerViewModel.intervalValue = self.intervalValue
                        timerViewModel.getTimerInterval()
                                                
                        defaultSettings.defaultValues.set(self.selectedTimerValueIndex, forKey: "selectedTimerValueIndex")
                        defaultSettings.defaultValues.set(self.intervalValue, forKey: "intervalValue")
                    }
                }){
                    Text("Save")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.taskColors[taskColorIndex])
                        .frame(width: 65, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.taskColors[taskColorIndex], lineWidth: 1.5)
                        )
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(width: defaultSettings.screenWidth, height: 70, alignment: .center)
        .padding(.bottom, 0)
    }
    
    var interval: some View {
        VStack(spacing: 15) {
            Text("Interval")
                .font(.system(size: 16, weight: .semibold))
                .frame(width: defaultSettings.frameWidth, alignment: .leading)
            
            HStack {
                VStack(spacing: 4) {
                    HStack {
                        Text("1 mins")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(intervalValue==1 ? Color.taskColors[taskColorIndex] : Color.primaryColor2)
                    }
                    .frame(height: 44)
                    
                    Rectangle()
                        .frame(width: defaultSettings.frameWidth/2-12, height: 1.5)
                        .foregroundColor(intervalValue==1 ? Color.taskColors[taskColorIndex] : Color.halfModalViewColor)
                }
                .frame(width: defaultSettings.frameWidth/2-6, height: 44)
                .onTapGesture {
                    self.intervalValue = 1
                    self.selectedTimerValueIndex = 60
                    self.getTimerInterval()
                }
                
                VStack(spacing: 4) {
                    HStack {
                        Text("5 mins")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(intervalValue==5 ? Color.taskColors[taskColorIndex] : Color.primaryColor2)
                    }
                    .frame(height: 44)
                    
                    Rectangle()
                        .frame(width: defaultSettings.frameWidth/2-12, height: 1.5)
                        .foregroundColor(intervalValue==5 ? Color.taskColors[taskColorIndex] : Color.halfModalViewColor)
                }
                .frame(width: defaultSettings.frameWidth/2-6, height: 44)
                .onTapGesture {
                    self.intervalValue = 5
                    self.selectedTimerValueIndex = 60
                    self.getTimerInterval()
                }
            }
            /*
            VStack(spacing: 0) {
                Button(action: {
                    self.intervalValue = 5
                    self.getTimerInterval()
                    self.selectedTimerValueIndex = 11
                }) {
                    HStack {
                        Text("5 mins")
                            .font(.system(size: 16))
                            .foregroundColor(Color.primaryColor2)
                        
                        Spacer()
                        
                        Circle()
                            .fill(intervalValue==5 ? Color.taskColors[taskColorIndex] : Color.primaryColor)
                            .frame(width: 12)
                            .opacity(intervalValue==5 ? 1 : 0)
                    }
                    .frame(width: defaultSettings.frameWidth, height: 40)
                }
                
                Button(action: {
                    self.intervalValue = 1
                    self.selectedTimerValueIndex = 60
                    self.getTimerInterval()
                }) {
                    HStack {
                        Text("1 mins")
                            .font(.system(size: 16))
                            .foregroundColor(Color.primaryColor2)
                        
                        Spacer()

                        Circle()
                            .fill(intervalValue==1 ? Color.taskColors[taskColorIndex] : Color.primaryColor)
                            .frame(width: 12)
                            .opacity(intervalValue==1 ? 1 : 0)
                    }
                    .frame(width: defaultSettings.frameWidth, height: 40)
                }
            }
            */
        }
    }
    
    var picker: some View {
        VStack(spacing: 20) {
            Text("Default")
                .font(.system(size: 16, weight: .semibold))
                .frame(width: defaultSettings.frameWidth, alignment: .leading)
            
            Picker(selection: self.$selectedTimerValueIndex, label: Text("")) {
                ForEach(self.timerValueSelections, id: \.self) { item in
                    Text("\(item)")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(Color.primaryColor2)
                }
            }
            .frame(width: defaultSettings.screenWidth*0.5, height: 110)
            .clipped()
        }
    }
    
    var line: some View {
        VStack {
            Rectangle()
                .foregroundColor(Color.viewColor)
                .frame(width: defaultSettings.screenWidth*0.935, height: 0.6)
        }
    }

    var body: some View {
        VStack {
            navigationBar
                .padding(.vertical, 6)
            
            interval
                
            Spacer()
//            line
//                .padding(.vertical, 26)
            
            picker

            Spacer()
        }
        .frame(width: defaultSettings.screenWidth, height: 430, alignment: .center)
        .background(Color.halfModalViewColor)
        .cornerRadius(28)
        .ignoresSafeArea(.all)
        
        .onAppear {
            intervalValue = defaultSettings.defaultValues.integer(forKey: "intervalValue")
            selectedTimerValueIndex = defaultSettings.defaultValues.integer(forKey: "selectedTimerValueIndex")
            
            if intervalValue == 0 {
                intervalValue = 1
                defaultSettings.defaultValues.set(self.intervalValue, forKey: "intervalValue")
            }
            
            getTimerInterval()
        }
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
}



