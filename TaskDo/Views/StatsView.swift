//
//  StatsView.swift
//  TaskDo
//
//  Created by Philippe Yong on 27/01/2021.
//

import SwiftUI

struct StatsContentView: View {
    @StateObject var viewModel = StatsViewModel()
    @State var loading = false
    
    @State var graphIsTapped = false
    @State var focusTime = 0
    @State var selectedIndex = 0
    
    @Binding var showDetails: Bool
        
    private let defaultSettings = DefaultSettings()
    private let frameWidth = UIScreen.main.bounds.width * 0.9
    
    var navBar: some View {
        VStack {
            Text("Statistics")
                .font(.system(size: 20, weight: .semibold))
        }
    }
    
    var picker: some View {
        ZStack {
            VStack {
                VStack {
                    Rectangle()
                        .frame(width: 60, height: 35, alignment: .center)
                        .foregroundColor(Color.viewColor)
                        .cornerRadius(20)
                }
                .frame(width: 60, alignment: .center)
                .padding(.leading, CGFloat(viewModel.selectedDataIndex*60))
                .animation(Animation.default.speed(1.5))
            }
            .frame(width: 180, alignment: .leading)
            
            HStack(spacing: 0) {
                ForEach(viewModel.dataOptions.indices, id: \.self) { index in
                    VStack {
                        Text("\(viewModel.dataOptions[index])")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(width: 60, alignment: .center)
                    .onTapGesture {
                        withAnimation {
                            viewModel.selectData(index)
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                navBar
                Spacer()
                picker
            }
            .padding(.horizontal, 18)
            .padding(.top, 20)
            .frame(width: defaultSettings.screenWidth, alignment: .bottomLeading)
            
            if !viewModel.isLoading {
                PagerView(pageCount: 3, currentIndex: $viewModel.selectedDataIndex) {
                    ScrollView(.vertical, showsIndicators: false) {
                        DayStatsView(viewModel: viewModel)
                        .padding(.top, 4)
                        Spacer()
                    }
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        WeekStatsView(viewModel: viewModel, showDetails: $showDetails)
                        .padding(.top, 4)
                        Spacer()
                    }

                    ScrollView(.vertical, showsIndicators: false) {
                        MonthStatsView(viewModel: viewModel, focusTime: $focusTime, graphIsTapped: $graphIsTapped, selectedIndex: $selectedIndex, showDetails: $showDetails)
                        .padding(.top, 4)
                        Spacer()
                    }
                }
                .padding(.top, 16)
            }
            else {
                Spacer()
                LoadingView()
                    .frame(width: 120)
                Spacer()
            }
        }
    }
}

struct FocusTask: View {
    private let defaultSettings = DefaultSettings()
    @ObservedObject var viewModel: StatsViewModel
    @State var taskTitle = ""
    @State var taskColorIndex = 0
    @State var date = Date()
    @State var focusTime = 0
    
    var body: some View {
        HStack {
            VStack(spacing: 4) {
                Text("\(viewModel.getFormattedDateIII(date))")
                    .font(.system(size: 11.5))
                    .frame(width: defaultSettings.frameWidth*0.6, alignment: .leading)
                
                HStack(spacing: 10) {
                    Circle()
                        .fill(taskColorIndex>7 ? Color.taskColors[0] : Color.taskColors[taskColorIndex])
                        .frame(width: 10)
                    
                    Text(taskTitle)
                        .font(.system(size: 14))
                        .padding(.trailing, 4)
                        .frame(width: defaultSettings.frameWidth*0.54, alignment: .leading)
                }
                .frame(width: defaultSettings.frameWidth*0.6, alignment: .leading)
            }
            .frame(width: defaultSettings.frameWidth*0.6, alignment: .leading)
                        
            Spacer()
            
            Text("\(viewModel.getFormattedTaskFocusTime(focusTime)) min")
                .font(.system(size: 14))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)//18)
        .frame(width: defaultSettings.frameWidth, height: 70, alignment: .leading) //75
    }
}

struct LoadingView: View {
    @State var loading = false
    var body: some View {
        Circle()
            .trim(from: 0.0, to: 0.8)
            .stroke(style: .init(lineWidth: 4, lineCap: .round, lineJoin: .round))
            .fill(Color.smallButtonColor)
            .frame(width: 60, height: 60)
            .rotationEffect(.init(degrees: self.loading ? 360 : 0))
            .animation(Animation.linear(duration: 0.7).repeatForever(autoreverses: false))
            .onAppear {
                self.loading.toggle()
            }
    }
}


struct StatsDetails: View {
    @ObservedObject var statsViewModel: StatsViewModel
    @Binding var showDetails: Bool
    let defaultSettings = DefaultSettings()
    
    var body: some View {
        VStack {
            Text("Summary")
                .font(.system(size: 18, weight: .semibold))
                .frame(width: defaultSettings.frameWidth, alignment: .leading)
                .padding(.bottom, 10)
            
            VStack(spacing: 20) {
                Text("Your total focus time for \("") is \(""), which is an average of \("") per day")
                    .font(.system(size: 14))
                    .frame(width: defaultSettings.frameWidth, alignment: .leading)
                
                Text("That is \("") minutes, \("") than last month.")
                    .font(.system(size: 14))
                    .frame(width: defaultSettings.frameWidth, alignment: .leading)
            }
            
            Button(action: {
                self.showDetails = false
            }) {
                Text("Got it")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.taskColors[defaultSettings.defaultValues.integer(forKey: "tone")])
                    .frame(width: 160, height: 45, alignment: .center)
                    .overlay (
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.taskColors[defaultSettings.defaultValues.integer(forKey: "tone")], lineWidth: 1.5)
                    )
            }
            .padding(.top, 25)
        }
        .frame(width: defaultSettings.screenWidth, height: 280)
        .background(Color.halfModalViewColor)
        .cornerRadius(20)
    }
}
