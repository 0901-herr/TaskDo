//
//  DayStatsView.swift
//  TaskDo
//
//  Created by Philippe Yong on 08/02/2021.
//

import SwiftUI


struct DayStatsView: View {
    @StateObject var viewModel: StatsViewModel
    @State var barHeight: CGFloat = 0
    @State var percent: CGFloat = 0
    @State var startAnimation = false
    
    let defaultSettings = DefaultSettings()
    private let frameWidth = UIScreen.main.bounds.width * 0.9
            
    var timeDistributionList: some View {
        VStack{
            Text("Time distribution")
                .font(.system(size: 14, weight: .semibold))
                .frame(width: defaultSettings.frameWidth, alignment: .leading)
            
            VStack {
                if viewModel.timeDistributionList[0].reduce(0, +) > 0 {
                    ForEach(0...5, id: \.self) { index in
                        if viewModel.timeDistributionList[0][index] > 0 {
                            VStack {
                                HStack(spacing: 0) {
                                    ZStack {
                                        Circle()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(viewModel.tagOptions[index].color)
                                        
                                        if viewModel.tagOptions[index].imageName == "exercise" {
                                            Image(viewModel.tagOptions[index].imageName)
                                                .resizable()
                                                .frame(width: 18, height: 18)
                                                .foregroundColor(.white)
                                        }
                                        else {
                                            Image(systemName: viewModel.tagOptions[index].imageName)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding(.leading, 4)
                                    .frame(width: defaultSettings.frameWidth * 0.2, alignment: .leading)
                                
                                    VStack(spacing: 6) {
                                        Text("\(viewModel.tagOptions[index].title)")
                                            .font(.system(size: 12))
                                            .frame(width: defaultSettings.frameWidth * 0.55, alignment: .leading)
                                        
                                        Text("\(viewModel.getFormattedTime(viewModel.timeDistributionList[0][index]))")
                                            .font(.system(size: 18, weight: .semibold))
                                            .frame(width: defaultSettings.frameWidth * 0.55, alignment: .leading)
                                    }
                                    .frame(width: defaultSettings.frameWidth * 0.55)
                                    
                                    ZStack {
                                        Circle()
                                            .stroke(style: .init(lineWidth: 4.5, lineCap: .round, lineJoin: .round))
                                            .fill(Color.viewColor)
                                            .frame(width: 54, height: 54)
                                        Circle()
                                            .trim(from: 0.0, to: CGFloat(Double(viewModel.getPercentage(0, viewModel.maxFocusTimeList[0], sec: viewModel.timeDistributionList[0][index]))/100))
                                            .stroke(style: .init(lineWidth: 4.5, lineCap: .round, lineJoin: .round))
                                            .fill(viewModel.tagOptions[index].color)
                                            .rotationEffect(.init(degrees: -90))
                                            .frame(width: 54, height: 54)
                                        
                                        HStack(spacing: 0) {
                                            Text("\(viewModel.getPercentage(0, viewModel.maxFocusTimeList[0], sec: viewModel.timeDistributionList[0][index]))")
                                                .font(.system(size: 15, weight: .semibold))
                                                .padding(.leading, 6)
                                            
                                            Text("%")
                                                .font(.system(size: 8))
                                                .frame(height: 20, alignment: .bottomTrailing)
                                        }
                                    }
                                    .padding(.trailing, 4)
                                    .frame(width: defaultSettings.frameWidth * 0.25, alignment: .trailing)
                                }
                            }
                            .frame(width: defaultSettings.frameWidth, height: 85)
                        }
                    }
                }
                
                else {
                    Text("No data recorded")
                        .font(.system(size: 14))
                        .foregroundColor(Color.textColor)
                        .frame(width: defaultSettings.frameWidth, alignment: .leading)
                }
            }
            .padding(.top, 5)
        }
        .padding(.top, 20)
        .frame(width: defaultSettings.frameWidth)
    }
    
    var focusTaskList: some View {
        VStack {
            Text("Focused task")
                .font(.system(size: 14, weight: .semibold))
                .frame(width: defaultSettings.frameWidth, alignment: .leading)
            
            VStack {
                if viewModel.focusedTaskList.count > 0 {
                    VStack {
                        ForEach(viewModel.focusedTaskList, id: \.self) { task in
                            VStack(spacing: 2) {
                                FocusTask(viewModel: viewModel, taskTitle: task.taskTitle, taskColorIndex: task.taskColorIndex, date: task.date, focusTime: task.focusTime)
                                    .padding(.vertical, 0)
                                
                                Rectangle()
                                    .frame(width: defaultSettings.frameWidth+3, height: 0.8)
                                    .foregroundColor(Color.viewColor)
                            }
                        }
                    }
                }
                
                else {
                    Text("No data recorded")
                        .font(.system(size: 14))
                        .foregroundColor(Color.textColor)
                        .frame(width: defaultSettings.frameWidth, alignment: .leading)

//                    .background(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.textColor, lineWidth: 2.4)
//                    )
                }
            }
            .padding(.top, 5)
        }
        .padding(.top, 20)
    }
    
    var body: some View {
        VStack {
            FocusTimeGraph(viewModel: viewModel)
            timeDistributionList
                .padding(.bottom, 10)
            focusTaskList
                .padding(.bottom, 80)
        }
    }
}

struct FocusTimeGraph: View {
    @StateObject var viewModel: StatsViewModel
    private let defaultSettings = DefaultSettings()
    private let frameWidth = UIScreen.main.bounds.width * 0.9
    private let hourList = [0, 6, 12, 18, 23]
    @State var dateIsChanged = false
    
    var focusTimeGraphTitleBar: some View {
        HStack {
            VStack(spacing: 12) {
                Text("Total focus time")
                    .font(.system(size: 12))
//                    .foregroundColor(Color.textColor)
                    .frame(width: defaultSettings.frameWidth * 0.5, alignment: .bottomLeading)
                Text("\(viewModel.getFormattedTime(viewModel.totalFocusTimeList[0]))")
                    .font(.system(size: 24, weight: .bold))
                    .frame(width: defaultSettings.frameWidth * 0.5, alignment: .bottomLeading)
                    .animation(dateIsChanged ? .none : nil)
            }
            .frame(height: 50, alignment: .bottomLeading)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "arrowtriangle.left")
                    .font(.system(size: 12))
                    .foregroundColor(Color.primaryColor2)
                    .onTapGesture {
                        dateIsChanged = true
                        viewModel.currentDate = Date().getNextDay(date: viewModel.currentDate, -1)
                        viewModel.getSelectedDayData()
                    }
                    .frame(width: 24)
                
                Text("\(viewModel.getFormattedDateVII(viewModel.currentDate))")
                    .font(.system(size: 12))
                    .animation(dateIsChanged ? .none : nil)
                    .frame(width: 38)
                
                Image(systemName: "arrowtriangle.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color.primaryColor2)
                    .onTapGesture {
                        dateIsChanged = true
                        viewModel.currentDate = Date().getNextDay(date: viewModel.currentDate, 1)
                        viewModel.getSelectedDayData()
                    }
                    .frame(width: 24)
            }
            .frame(height: 50, alignment: .bottomTrailing)
        }
        .frame(width: defaultSettings.frameWidth, height: 50)
    }

    var body: some View {
        VStack(spacing: 20) {
            focusTimeGraphTitleBar
            
            ZStack {
                VStack(spacing: 0) {
                    HStack {
                        Rectangle()
                            .frame(width: defaultSettings.frameWidth * 0.85, height: 0.5)
                            .foregroundColor(Color(#colorLiteral(red: 0.8901960784, green: 0.8901960784, blue: 0.8901960784, alpha: 1)))
                        
                        Spacer()
                        
                        Text("\(viewModel.graphLineDataList[0][0])\(viewModel.lineUnit[0])")
                            .font(.system(size: 11))
                            .foregroundColor(Color.textColor)
                    }
                    Spacer()
                    HStack {
                        Rectangle()
                            .frame(width: defaultSettings.frameWidth * 0.85, height: 0.5)
                            .foregroundColor(Color(#colorLiteral(red: 0.8901960784, green: 0.8901960784, blue: 0.8901960784, alpha: 1)))
                        
                        Spacer()
                        Text("\(viewModel.graphLineDataList[0][1])\(viewModel.lineUnit[0])")
                            .font(.system(size: 11))
                            .foregroundColor(Color.textColor)
                    }
                    Spacer()
                    HStack {
                        Rectangle()
                            .frame(width: defaultSettings.frameWidth * 0.85, height: 0.5)
                            .foregroundColor(Color(#colorLiteral(red: 0.8901960784, green: 0.8901960784, blue: 0.8901960784, alpha: 1)))
                        
                        Spacer()
                        Text("\(viewModel.graphLineDataList[0][2])\(viewModel.lineUnit[0])")
                            .font(.system(size: 11))
                            .foregroundColor(Color.textColor)
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(viewModel.graphLineDataList[0][3])\(viewModel.lineUnit[0])")
                            .font(.system(size: 11))
                            .foregroundColor(Color.textColor)
                    }
                }
                .frame(width: defaultSettings.frameWidth * 0.95, height: 180)
                .padding(.bottom, 20)
                
                VStack {
                    HStack(spacing: 0) {
                        ForEach(0..<12, id: \.self) { hr in
                            VStack {
                                HStack(spacing: 0) {
                                    ForEach(0..<2, id: \.self) { i in
                                        VStack(spacing: 1) {
                                            VStack {
                                                Rectangle()
                                                    .frame(width: defaultSettings.frameWidth / 24 - 6, height: viewModel.getDayBarHeight(viewModel.graphBarDataList[0][hr*2+i]))
                                                    .cornerRadius(8)
                                                    .foregroundColor(Color.taskColors[defaultSettings.defaultValues.integer(forKey: "tone")])
                                            }
                                            .frame(width: defaultSettings.frameWidth / 24 - 6, height: 160, alignment: .bottom)
                                            
                                            Rectangle()
                                                .frame(width: defaultSettings.frameWidth / 24 - 4, height: 3)
                                                .cornerRadius(4)
                                                .foregroundColor(Color(#colorLiteral(red: 0.8210434318, green: 0.81849581, blue: 0.8230430484, alpha: 1)))
                                        }
                                        .frame(width: defaultSettings.frameWidth * 0.82 / 24, alignment: .center)
                                    }
                                }
                                VStack {
                                    if hr == 11 {
                                        Text("\(23)")
                                            .font(.system(size: 11))
//                                            .foregroundColor(Color.textColor)
                                            .padding(.leading, 8)
                                    }
                                    else {
                                        Text(hr<5 ? "0\(hr*2)" : "\(hr*2)")
                                            .font(.system(size: 11))
//                                            .foregroundColor(Color.textColor)
                                            .padding(.trailing, 8)
                                    }
                                }
                                .frame(width: defaultSettings.frameWidth*0.82 / 12, alignment: hr==11 ? .trailing : .leading)
                                .opacity(hourList.contains(hr*2) || hr==11 ? 1 : 0)
                            }
                        }
                    }
                    .frame(width: defaultSettings.frameWidth * 0.85, alignment: .center)
                }
                .padding(.top, 20)
                .frame(width: defaultSettings.frameWidth * 0.95, height: 180, alignment: .leading)
            }
            .frame(width: frameWidth, height: 240)
        }
    }
}

//struct FocusTimeGraph_Previews: PreviewProvider {
//    static var previews: some View {
//        FocusTimeGraph()
//    }
//}
