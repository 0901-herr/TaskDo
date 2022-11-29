//
//  BottomTaskDisplayTypePopUpView.swift
//  TaskDo
//
//  Created by Philippe Yong on 04/03/2021.
//

import SwiftUI

struct BottomTaskDisplayTypePopUpView: View {
    @ObservedObject var defaultSettings = DefaultSettings()
    @StateObject var viewModel = BottomTaskDisplayTypePopUpViewModel()
    @StateObject var taskListViewModel: TaskListViewModel

    @Binding var taskDisplayType: TaskDisplayAction
    @Binding var taskDisplayDetail: TaskDisplayOption
    
    var body: some View {
        VStack {
            VStack(spacing: 26) {
                ForEach(viewModel.taskDisplayOptionList, id: \.self) { option in
                    Button(action: {
                        if taskDisplayType == .thisWeek {
//                            taskListViewModel.displayThisWeekTask()
                            viewModel.send(option.type)
                            self.taskDisplayType = viewModel.taskDisplayAction
                        }
                        else {
                            viewModel.send(option.type)
                            self.taskDisplayType = viewModel.taskDisplayAction
                        }
                    }) {
                        HStack(spacing: 20) {
                            Image(systemName: viewModel.taskDisplayAction == option.type ? option.nameSelect : option.name)
                                .font(.system(size: 26))
                                .foregroundColor(Color(#colorLiteral(red: 1, green: 0.8933985829, blue: 0, alpha: 1)))
                                .frame(width: 32)
                            
                            VStack(spacing: 4) {
                                Text(option.title)
                                    .foregroundColor(Color.primaryColor2)
                                    .font(.system(size: 16, weight: .medium))
                                    .frame(width: defaultSettings.screenWidth * 0.75, alignment: .leading)
                                
                                Text(option.description)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.textColor)
                                    .frame(width: defaultSettings.screenWidth * 0.75, alignment: .leading)
                            }
                        }
                        .frame(width: defaultSettings.screenWidth * 0.85, alignment: .leading)
                    }
                }
            }
        }
        .frame(width: defaultSettings.screenWidth, height: 200, alignment: .center)
        .background(Color.halfModalViewColor)
        .cornerRadius(28)
        .onAppear {
            viewModel.taskDisplayAction = taskDisplayType
        }
    }
}

final class BottomTaskDisplayTypePopUpViewModel: ObservableObject {
    @Published var taskDisplayAction: TaskDisplayAction = .today
    @Published var taskDisplayOptionList: [TaskDisplayOption] = [
        TaskDisplayOption(title: "Today", description: "Display today task", name: "sun.max", nameSelect: "sun.max.fill", type: .today),
        TaskDisplayOption(title: "This week", description: "Display this week task", name: "bolt", nameSelect: "bolt.fill", type: .thisWeek),
    ]
    
    func send(_ action: TaskDisplayAction) {
        switch action {
        case .today:
            taskDisplayAction = .today
        case .thisWeek:
            taskDisplayAction = .thisWeek
        }
    }
}

struct TaskDisplayOption: Hashable {
    var title: String
    var description: String
    var name: String
    var nameSelect: String
    var type: TaskDisplayAction
}

enum TaskDisplayAction {
    case today
    case thisWeek
}


//struct BottomTaskDisplayTypePopUpView_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            BottomTaskDisplayTypePopUpView()
//        }
//        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//        .background(Color.black.opacity(0.2))
//    }
//}
