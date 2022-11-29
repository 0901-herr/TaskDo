//
//  TimerTagsOptionsView.swift
//  TaskDo
//
//  Created by Philippe Yong on 30/01/2021.
//

import SwiftUI

struct TimerTagsOptionsView: View {
    @ObservedObject var viewModel: TimerViewModel
    @Binding var tagIsTapped: Bool
    
    @ObservedObject var defaultSettings = DefaultSettings()
    
    var options: some View {
        VStack(spacing: 10) {
            Text("Select tags")
                .font(.system(size: 18, weight: .medium))
                .frame(width: defaultSettings.screenWidth * 0.9, alignment: .leading)
                .padding(.leading, 20)
                .padding(.bottom, 20)
            
            VStack(spacing: 25) {
                HStack {
                    ForEach(0..<3, id: \.self) { index in
                        VStack(spacing: 10) {
                            Button(action: {
                                viewModel.selectedTagIndex = index
                                tagIsTapped = false
                            }) {
                                if viewModel.tagOptions[index].imageName == "exercise" {
                                    Image("exercise")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(Color.white)
                                }
                                else {
                                    Image(systemName: viewModel.tagOptions[index].imageName)
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(Color.white)
                                }
                            }
                            .buttonStyle(CircleButtonStyle(fillColor: viewModel.tagOptions[index].color))
        
                            Text("\(viewModel.tagOptions[index].title)")
                                .font(.system(size: 14))
                        }
                        .frame(width: defaultSettings.screenWidth * 0.9 / 3)
                    }
                }
                .frame(width: defaultSettings.screenWidth * 0.85)
                
                HStack {
                    ForEach(3..<6, id: \.self) { index in
                        VStack(spacing: 10) {
                            Button(action: {
                                viewModel.selectTag(index)
                                tagIsTapped = false
                            }) {
                                Image(systemName: viewModel.tagOptions[index].imageName)
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(CircleButtonStyle(fillColor: viewModel.tagOptions[index].color))
        
                            Text("\(viewModel.tagOptions[index].title)")
                                .font(.system(size: 14))
                        }
                        .frame(width: defaultSettings.screenWidth * 0.9 / 3)
                    }
                }
                .frame(width: defaultSettings.screenWidth * 0.9)
            }
        }
    }
    
    var body: some View {
        VStack {
            options
        }
        .frame(width: defaultSettings.screenWidth, height: 310, alignment: .center)
        .background(Color.halfModalViewColor)
        .cornerRadius(28)
    }
}

enum TagOptions {
    case study
    case work
    case exercise
    case productivity
    case fun
    case others
}
struct Tags: Hashable {
    var title: String
    var imageName: String
    var color: Color
    var type: TagOptions
}

