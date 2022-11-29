//
//  WeekStatsView.swift
//  TaskDo
//
//  Created by Philippe Yong on 08/02/2021.
//

import SwiftUI

struct WeekStatsView: View {
    @StateObject var viewModel: StatsViewModel
    @State var barHeight: CGFloat = 0
    @State var percent: CGFloat = 0
    @Binding var showDetails: Bool
    
    private let defaultSettings = DefaultSettings()
    private let frameWidth = UIScreen.main.bounds.width * 0.9
                
    var timeDistributionList: some View {
        VStack{
            HStack {
                Text("Time distribution")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: defaultSettings.frameWidth, alignment: .leading)
            }
            
            VStack {
                if viewModel.timeDistributionList[1].reduce(0, +) > 0 {
                    ForEach(0...5, id: \.self) { index in
                        if viewModel.timeDistributionList[1][index] > 0 {
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
//                                            .foregroundColor(Color.textColor)
                                            .frame(width: defaultSettings.frameWidth * 0.55, alignment: .leading)
                                        
                                        Text("\(viewModel.getFormattedTime(viewModel.timeDistributionList[1][index]))")
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
                                            .trim(from: 0.0, to: CGFloat(Double(viewModel.getPercentage(1, viewModel.maxFocusTimeList[1], sec: viewModel.timeDistributionList[1][index]))/100))
                                            .stroke(style: .init(lineWidth: 4.5, lineCap: .round, lineJoin: .round))
                                            .fill(viewModel.tagOptions[index].color)
                                            .rotationEffect(.init(degrees: -90))
                                            .frame(width: 54, height: 54)
                                        
                                        HStack(spacing: 0) {
                                            Text("\(viewModel.getPercentage(1, viewModel.maxFocusTimeList[1], sec: viewModel.timeDistributionList[1][index]))")
                                                .font(.system(size: 15, weight: .semibold))
                                                .padding(.leading, 6)
                                            
                                            Text("%")
                                                .font(.system(size: 8))
//                                                .foregroundColor(Color.textColor)
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
    
    var insights: some View {
        HStack(spacing: 0) {
            VStack(spacing: 12) {
                Text("Total focus time")
                    .font(.system(size: 12))
//                    .foregroundColor(Color.textColor)
                    .frame(width: defaultSettings.frameWidth/2, alignment: .leading)
                
                Text("\(viewModel.getFormattedTime(viewModel.totalFocusTimeList[1]))")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: defaultSettings.frameWidth/2, alignment: .leading)
            }
            .frame(width: defaultSettings.frameWidth/2, height: 65)

            VStack(spacing: 12) {
                Text("Compare to last week")
                    .font(.system(size: 12))
//                    .foregroundColor(Color.textColor)
                    .frame(width: defaultSettings.frameWidth/2, alignment: .leading)

                HStack(spacing: 14) {
                    Image(systemName: viewModel.weekFocusTimeCompareBool ? "arrow.up.circle" : "arrow.down.circle")
                        .font(.system(size: 18))
                        .foregroundColor(viewModel.weekFocusTimeCompareBool ? Color.green : Color.red)

                    Text("\(viewModel.weekFocusTimeComparePrecentage) %")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(viewModel.weekFocusTimeCompareBool ? Color.green : Color.red)
                }
                .frame(width: defaultSettings.frameWidth/2, alignment: .leading)
            }
            .frame(width: defaultSettings.frameWidth/2, height: 65)
        }
        .frame(width: defaultSettings.frameWidth, height: 80)
        .onTapGesture {
            showDetails = true
        }
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                WeekFocusTimeGraph(viewModel: viewModel)
                insights
            }
            timeDistributionList
                .padding(.top, 10)
                .padding(.bottom, 80)
        }
    }
}

struct WeekFocusTimeGraph: View {
    @StateObject var viewModel: StatsViewModel
    private let defaultSettings = DefaultSettings()
    private let frameWidth = UIScreen.main.bounds.width * 0.9
    private let barWidth = (UIScreen.main.bounds.width * 0.9)*0.95 / 7
    
    @State var graphIsTapped = false
    @State private var touchLocation: CGPoint = .zero
    @State var focusTime = 0
    @State var selectedIndex = 0
    
    var focusTimeGraphTitleBar: some View {
        HStack {
            VStack(spacing: 12) {
                Text("Daily average")
                    .font(.system(size: 12))
//                    .foregroundColor(Color.textColor)
                    .frame(width: defaultSettings.frameWidth * 0.5, alignment: .bottomLeading)
                
                Text(graphIsTapped ? "\(viewModel.getFormattedTime(viewModel.graphBarDataList[1][selectedIndex]))" : "\(viewModel.getFormattedTime(viewModel.focusTimeAvr))")
                    .font(.system(size: 24, weight: .bold))
                    .frame(width: defaultSettings.frameWidth * 0.5, alignment: .bottomLeading)
                    .animation(self.graphIsTapped ? .none : nil)
            }
            .frame(height: 50, alignment: .bottomLeading)
                    
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "arrowtriangle.left")
                    .font(.system(size: 12))
                    .foregroundColor(Color.primaryColor2)
                    .onTapGesture {
                        viewModel.weekPointer -= 1
                        viewModel.getSelectedWeekData()
                    }
                    .frame(width: 24)
                
                Text("\(viewModel.getFormattedDateVII(viewModel.selectedWeekDates[0])) - \(viewModel.getFormattedDateVII(viewModel.selectedWeekDates[6]))")
                    .font(.system(size: 12))
                    .frame(width: 92)

                Image(systemName: "arrowtriangle.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color.primaryColor2)
                    .onTapGesture {
                        viewModel.weekPointer += 1
                        viewModel.getSelectedWeekData()
                    }
                    .frame(width: 24)
            }
            .animation(self.graphIsTapped ? .none : nil)
            .frame(height: 50, alignment: .bottomTrailing)
        }
        .frame(width: defaultSettings.frameWidth, height: 50)
    }

    var body: some View {
        VStack(spacing: 20) {
            focusTimeGraphTitleBar
            
            VStack {
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { index in
                        VStack(spacing: 6) {
                            VStack {
                                if viewModel.graphBarDataList[1][index] > 0 {
                                    Text("\(viewModel.getFormattedTimeII(viewModel.graphBarDataList[1][index]))")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color.textColor)
                                        .frame(width: 40, alignment: .center)
                                }
                                
                                Rectangle()
                                    .frame(width: 15, height: viewModel.totalFocusTimeList[1] > 0 ?
                                            (viewModel.getWeekBarHeight(viewModel.graphBarDataList[1][index])) : 0)
                                    .cornerRadius(10)
                                    .foregroundColor(Color.taskColors[defaultSettings.defaultValues.integer(forKey: "tone")].opacity(graphIsTapped ? (selectedIndex == index ? 1 : 0.6) : 1))
                                    .padding(.bottom, 4)
                            }
                            .frame(width: defaultSettings.frameWidth / CGFloat(viewModel.graphBarDataList[1].count) - 6, height: 160, alignment: .bottom)
                            
                            Text("\(defaultSettings.weekDays[index])")
                                .font(.system(size: 11))
                                .frame(width: 20, alignment: .center)
//                                .foregroundColor(Color.textColor)
                        }
                        .frame(width: defaultSettings.frameWidth / 7, alignment: .center)
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            graphIsTapped = true
                            self.touchLocation = value.location
                            let x = Double(touchLocation.x)
                            
                            var index = 0
                            let barIdxWidth = Double(defaultSettings.frameWidth / 7)
                            
                            if (x > barIdxWidth) && (Int(x/barIdxWidth) < 7) {
                                index = Int(round(x/barIdxWidth))
                            }
                            else if (x <= barIdxWidth) {
                                index = 0
                            }
                            else if Int(x/barIdxWidth) >= 7 {
                                index = 6
                            }
                            
                            if index == 7 {
                                index = 6
                            }
                            
                            selectedIndex = index
                            focusTime = Int(viewModel.graphBarDataList[1][selectedIndex])
                        })
                        .onEnded {_ in
                            graphIsTapped = false
                        })
                .padding(.top, 24)
                .frame(width: defaultSettings.frameWidth * 0.95, height: 195, alignment: .center)
                }
                .frame(width: defaultSettings.frameWidth, height: 240, alignment: .center)
        }
    }
}

//struct WeekStatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        WeekStatsView()
//    }
//}
