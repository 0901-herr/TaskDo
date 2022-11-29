//
//  FocusModePopUpView.swift
//  TaskDo
//
//  Created by Philippe Yong on 03/03/2021.
//

import SwiftUI

struct FocusModePopUpView: View {
    @ObservedObject var defaultSettings = DefaultSettings()
    
    @Binding var focusModeIsOn: Bool
    @Binding var showPopUp: Bool
    @State var colorIndex = 0
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ZStack {
                    Circle()
                        .stroke(Color.taskColors[colorIndex], lineWidth: 1.5)
                        .frame(width: 25*1.6)
                    Circle()
                        .stroke(Color.taskColors[colorIndex], lineWidth: 0.8)
                        .frame(width: 20*1.6)
                    Circle()
                        .frame(width: 15*1.6)
                        .foregroundColor(Color.taskColors[colorIndex])
                }
                
                VStack(spacing: 8) {
                    Text("Focus Mode ")
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: defaultSettings.screenWidth * 0.6, alignment: .leading)
                    Text("Leaving the app would halt the focus timer")
                        .font(.system(size: 14))
                        .foregroundColor(Color.textColor)
                        .frame(width: defaultSettings.screenWidth * 0.6, alignment: .leading)
                }
                .padding(.leading, 20)
                .frame(width: defaultSettings.screenWidth * 0.7, alignment: .leading)
            }
            .frame(width: defaultSettings.screenWidth * 0.9, height: 100)
            .background(Color.viewColor)
            .cornerRadius(20)
            Spacer()
        }
        .frame(height: defaultSettings.screenHeight)
    }
}

//struct FocusModePopUpView_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//        FocusModePopUpView()
//            .padding(.top, 100)
//        }
//    }
//}
