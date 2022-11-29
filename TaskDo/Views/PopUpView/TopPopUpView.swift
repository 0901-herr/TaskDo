//
//  TopPopUpView.swift
//  TaskDo
//
//  Created by Philippe Yong on 18/02/2021.
//

import SwiftUI

struct TopPopUpView: View {
    @ObservedObject var defaultSettings = DefaultSettings()
    @State var focusTime: Int
    
    @State var isCompleted = true
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                HStack(spacing: 0) {
                    VStack(spacing: 8) {
                        Text("Task Completed")
                            .font(.system(size: 18, weight: .bold))
                            .frame(width: defaultSettings.screenWidth * 0.6, alignment: .leading)
                        Text("You have stayed focus for \(focusTime) mins")
                            .font(.system(size: 14))
                            .foregroundColor(Color.textColor)
                            .frame(width: defaultSettings.screenWidth * 0.6, alignment: .leading)
                    }
                    .padding(.leading, 10)
                    .frame(width: defaultSettings.screenWidth * 0.7, alignment: .leading)
                    
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 40))
                        .foregroundColor(Color.green)
                }
                .frame(width: defaultSettings.screenWidth * 0.9, height: 100)
                .background(
                    ZStack {
                        Color.viewColor
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.green, lineWidth: 3)
                    }
                )
                .cornerRadius(20)
                .onAppear {
                    delayCode()
                }
                
//                VStack {
//                    ConfettieLottieView()
//                        .opacity(isCompleted ? 1 : 0)
//                }
            }
            Spacer()
        }
        .frame(height: defaultSettings.screenHeight)
    }
    
    func delayCode() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isCompleted = false
        }
    }
}
