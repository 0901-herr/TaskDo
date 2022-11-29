//
//  LandingButtonStyle.swift
//  TaskDo
//
//  Created by Philippe Yong on 23/01/2021.
//

import SwiftUI

struct LandingButtonStyle: ButtonStyle {
    var fillColor: Color = .themeOrange
    
    func makeBody(configuration: Configuration) -> some View {
        return LandingButton(configuration: configuration, fillColor: fillColor)
    }
    
    struct LandingButton: View {
        let configuration: Configuration
        let fillColor: Color
        
        var body: some View {
            return configuration.label
                .frame(width: UIScreen.main.bounds.width * 0.6, height: 60)
                .background(RoundedRectangle(cornerRadius: 30)
                .fill(fillColor))
        }
    }
}

struct CircleButtonStyle: ButtonStyle {
    var fillColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        return CircleButton(configuration: configuration, fillColor: fillColor)
    }
    
    struct CircleButton: View {
        let configuration: Configuration
        let fillColor: Color
        
        var body: some View {
            return configuration.label
                .frame(width: 52, height: 52)
                .background(
                    Circle()
                        .frame(width: 52, height: 52)
                        .foregroundColor(fillColor)
                )
        }
    }
}

struct LandingButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: {}) {
            Text("Start")
        }
//        .previewDevice("iPhone 8")
        .previewDevice("iPhone 11")
        .buttonStyle(LandingButtonStyle())
    }
}

