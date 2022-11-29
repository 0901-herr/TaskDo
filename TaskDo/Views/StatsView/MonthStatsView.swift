//
//  MonthStatsView.swift
//  TaskDo
//
//  Created by Philippe Yong on 08/02/2021.
//

import SwiftUI

struct MonthStatsView: View {
    @StateObject var viewModel: StatsViewModel
    @State var barHeight: CGFloat = 0
    @State var percent: CGFloat = 0
    
    @Binding var focusTime: Int
    @Binding var graphIsTapped: Bool
    @Binding var selectedIndex: Int
    @Binding var showDetails: Bool
    
    private let defaultSettings = DefaultSettings()
    private let frameWidth = UIScreen.main.bounds.width * 0.9
                
    var timeDistributionList: some View {
        VStack{
            Text("Time distribution")
                .font(.system(size: 14, weight: .semibold))
                .frame(width: defaultSettings.frameWidth, alignment: .leading)
            
            VStack {
                if viewModel.timeDistributionList[2].reduce(0, +) > 0 {
                    ForEach(0...5, id: \.self) { index in
                        if viewModel.timeDistributionList[2][index] > 0 {
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
                                        
                                        Text("\(viewModel.getFormattedTime(viewModel.timeDistributionList[2][index]))")
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
                                            .trim(from: 0.0, to: CGFloat(Double(viewModel.getPercentage(2, viewModel.maxFocusTimeList[2], sec: viewModel.timeDistributionList[2][index]))/100))
                                            .stroke(style: .init(lineWidth: 4.5, lineCap: .round, lineJoin: .round))
                                            .fill(viewModel.tagOptions[index].color)
                                            .rotationEffect(.init(degrees: -90))
                                            .frame(width: 54, height: 54)
                                        
                                        HStack(spacing: 0) {
                                            Text("\(viewModel.getPercentage(2, viewModel.maxFocusTimeList[2], sec: viewModel.timeDistributionList[2][index]))")
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
//                    .background(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.textColor, lineWidth: 2.4)
//                    )
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
                
                Text("\(viewModel.getFormattedTime(viewModel.totalFocusTimeList[2]))")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: defaultSettings.frameWidth/2, alignment: .leading)
            }
            .frame(width: defaultSettings.frameWidth/2, height: 65, alignment: .leading)

            VStack(spacing: 12) {
                Text("Compare to last month")
                    .font(.system(size: 12))
//                    .foregroundColor(Color.textColor)
                    .frame(width: defaultSettings.frameWidth/2, alignment: .leading)

                HStack(spacing: 10) {
                    Image(systemName: viewModel.monthFocusTimeCompareBool ? "arrow.up.circle" : "arrow.down.circle")
                        .font(.system(size: 18))
                        .foregroundColor(viewModel.monthFocusTimeCompareBool ? Color.green : Color.red)

                    Text("\(viewModel.monthFocusTimeComparePercentage) %")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(viewModel.monthFocusTimeCompareBool ? Color.green : Color.red)
                        //Color(#colorLiteral(red: 0.3098039216, green: 0.9411764706, blue: 0.3333333333, alpha: 1)) : Color(#colorLiteral(red: 1, green: 0.3333333333, blue: 0.2901960784, alpha: 1)))
                }
                .frame(width: defaultSettings.frameWidth/2, alignment: .leading)
            }
            .frame(width: defaultSettings.frameWidth/2, height: 65, alignment: .leading)
        }
        .frame(width: defaultSettings.frameWidth, height: 80)
        .onTapGesture {
            showDetails = true
        }
    }

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                MonthFocusTimeGraph(viewModel: viewModel)
                insights
            }
            timeDistributionList
                .padding(.top, 10)
                .padding(.bottom, 80)
        }
    }
}


struct MonthFocusTimeGraph: View {
    @StateObject var viewModel: StatsViewModel
    
    @State var graphIsTapped = false
    @State private var touchLocation: CGPoint = .zero
    @State var focusTime = 0
    @State var selectedIndex = 0
    
    @State var barHeight: CGFloat = 0
    @State var percent: CGFloat = 0
    
    private let defaultSettings = DefaultSettings()
    private let frameWidth = UIScreen.main.bounds.width * 0.9
    
    var focusTimeGraphTitleBar: some View {
        HStack {
            VStack(spacing: 12) {
                Text("Daily average")
                    .font(.system(size: 12))
//                    .foregroundColor(Color.textColor)
                    .frame(width: defaultSettings.frameWidth * 0.5, alignment: .bottomLeading)
                
                Text(graphIsTapped ? "\(viewModel.getFormattedTime(viewModel.weekGraphBarData[selectedIndex].focusTime))" : "\(viewModel.getFormattedTime(viewModel.monFocusTimeAvr))")
                    .font(.system(size: 24, weight: .bold))
                    .frame(width: defaultSettings.frameWidth * 0.5, alignment: .bottomLeading)
                    .animation(graphIsTapped ? .none : nil)
            }
            .frame(height: 50, alignment: .bottomLeading)
                    
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "arrowtriangle.left")
                    .font(.system(size: 12))
                    .foregroundColor(Color.primaryColor2)
                    .onTapGesture {
                        viewModel.getSelectedMonth(-1)
                        viewModel.getSelectedMonthData()
                        // TODO: Change avr
                    }
                    .frame(width: 24)
                
                Text("\(graphIsTapped ? "\(viewModel.getFormattedDateVII(viewModel.weekGraphBarData[selectedIndex].date))" : "\(viewModel.getFormattedDateIX(viewModel.monthPointer))")")
                    .font(.system(size: 12))
                    .frame(width: 34)
                
                Image(systemName: "arrowtriangle.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color.primaryColor2)
                    .onTapGesture {
                        viewModel.getSelectedMonth(1)
                        viewModel.getSelectedMonthData()
                    }
                    .frame(width: 24)
            }
            .animation(graphIsTapped ? .none : nil)
            .frame(height: 50, alignment: .bottomTrailing)
        }
        .frame(width: defaultSettings.frameWidth, height: 50)
    }

    var body: some View {
        VStack(spacing: 20) {
            focusTimeGraphTitleBar
            
            VStack {
                HStack(spacing: 0) {
                    ForEach(0..<viewModel.weekGraphBarData.count, id: \.self) { index in
                        VStack {
                            Spacer()
                            
                            Rectangle()
                                .frame(
                                    width: ((defaultSettings.frameWidth * 0.95) / CGFloat(viewModel.weekGraphBarData.count)) - 2.5,
                                    height: viewModel.weekGraphBarData[index].focusTime > 0 ? viewModel.getMonthBarHeight(viewModel.weekGraphBarData[index].focusTime) : 4
                                    )
                                .cornerRadius(4)
                                .foregroundColor(Color.taskColors[defaultSettings.defaultValues.integer(forKey: "tone")].opacity(graphIsTapped ? (selectedIndex == index ? 1 : 0.6) : 1))
                        }
                        .frame(width: (defaultSettings.frameWidth * 0.96) / CGFloat(viewModel.weekGraphBarData.count), height: 185)
                    }
                }
                .gesture(
                    DragGesture()
                    .onChanged({ value in
                        graphIsTapped = true
                        self.touchLocation = value.location
                        let x = Double(touchLocation.x)
                        print("X LOCATION: \(x)")
                        print("TOTAL MONTH DATA: \(viewModel.weekGraphBarData.count)")
                        var index = 0
                        let barIdxWidth = Double((defaultSettings.frameWidth * 0.93) / CGFloat(viewModel.weekGraphBarData.count))
                        
                        if (x > barIdxWidth) && (Int(x/barIdxWidth) < viewModel.weekGraphBarData.count) {
                            index = Int(round(x/barIdxWidth))
                        }
                        else if (x <= barIdxWidth) {
                            index = 0
                        }
                        else if Int(x/barIdxWidth) >= viewModel.weekGraphBarData.count {
                            index = viewModel.weekGraphBarData.count - 1
                        }
                        
                        if index == viewModel.weekGraphBarData.count {
                            index = viewModel.weekGraphBarData.count - 1
                        }
                        print("MONTH INDEX: \(index)")
                        selectedIndex = index
                        focusTime = Int(viewModel.weekGraphBarData[selectedIndex].focusTime)
                    })
                    .onEnded {_ in
                        graphIsTapped = false
                    })
                .frame(width: defaultSettings.frameWidth, height: 195, alignment: .center)
            }
            .frame(width: defaultSettings.frameWidth, height: 240, alignment: .center)
        }
    }
}



 

