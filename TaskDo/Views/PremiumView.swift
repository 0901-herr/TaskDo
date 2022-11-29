//
//  PremiumView.swift
//  TaskDo
//
//  Created by Philippe Yong on 07/08/2021.
//

import Foundation
import SwiftUI


struct PremiumView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @StateObject var viewModel = PremiumViewModel()
    
    let defaultSettings = DefaultSettings()
    let premiumFeaturesText: [String] = ["Full access to statistics",
                                         "Full color options",
                                         "Unlimited notes",
                                         "Dark mode"]
    
    var heading: some View {
        VStack(spacing: 15) {
            Text("T A S K D O")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(Color(#colorLiteral(red: 0.8666666667, green: 0.6470588235, blue: 0.0862745098, alpha: 1)))
            
            Text("PREMIUM")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.premiumViewColor)
        }
    }
    
    var premiumFeatures: some View {
        VStack {
            ForEach(premiumFeaturesText, id: \.self) { text in
                HStack(spacing: 15) {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color.primaryColor2)
                        .font(.system(size: 16, weight: .semibold))

                    Text(text)
                        .font(.system(size: 16, weight: .semibold))
                }
                .padding(.leading, 5)
                .frame(width: defaultSettings.frameWidth, alignment: .leading)
            }
            .padding(.all, 6)
        }
    }
    
    var planOption: some View {
        HStack(spacing: 10) {
            VStack(spacing: 20) {
                Text("Life time")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(viewModel.getPlan()==0 ? Color(#colorLiteral(red: 0.8666666667, green: 0.6470588235, blue: 0.0862745098, alpha: 1)) : Color.primaryColor2)
                
                Text("$ 4.99")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(viewModel.getPlan()==0 ? Color(#colorLiteral(red: 0.8666666667, green: 0.6470588235, blue: 0.0862745098, alpha: 1)) : Color.primaryColor2)
            }
            .frame(width: defaultSettings.frameWidth*0.45, height: 165)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(viewModel.getPlan()==0 ? Color(#colorLiteral(red: 0.8666666667, green: 0.6470588235, blue: 0.0862745098, alpha: 1)) : Color.viewColor, lineWidth: 2)
            )
            .onTapGesture {
                viewModel.setPlan(plan: 0)
            }
            
            VStack(spacing: 15) {
                Text("3 months")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(viewModel.getPlan()==1 ? Color(#colorLiteral(red: 0.8666666667, green: 0.6470588235, blue: 0.0862745098, alpha: 1)) : Color.primaryColor2)

                Text("$ 0.99")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(viewModel.getPlan()==1 ? Color(#colorLiteral(red: 0.8666666667, green: 0.6470588235, blue: 0.0862745098, alpha: 1)) : Color.primaryColor2)
            }
            .frame(width: defaultSettings.frameWidth*0.45, height: 165)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(viewModel.getPlan()==1 ? Color(#colorLiteral(red: 0.8666666667, green: 0.6470588235, blue: 0.0862745098, alpha: 1)) : Color.viewColor, lineWidth: 2)
            )
            .onTapGesture {
                viewModel.setPlan(plan: 1)
            }
        }
        .frame(width: defaultSettings.frameWidth)
    }
    
    var subscribeButton: some View {
        VStack {
            Button(action: {
                // TODO: Subscribe mechanism
            }) {
                VStack {
                    Text("Subscribe")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.white)
                }
                .frame(width: defaultSettings.frameWidth*0.8, height: 60)
                .background(Color.premiumViewColor)
                .cornerRadius(25)
            }
            
            Text("By subscribing you agree to our tems and condition")
                .font(.system(size: 11))
                .foregroundColor(Color.textColor)
                .padding(.top, 10)
        }
    }
    
    var body: some View {
        VStack(spacing: 25) {
            heading
            premiumFeatures
                .padding(.top, 10)
            planOption
                .padding(.top, 10)
            subscribeButton
                .padding(.top, 20)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

final class PremiumViewModel: ObservableObject {
    @Published var plan = 0
    
    public func setPlan(plan: Int) {
        self.plan = plan
    }
    
    public func getPlan() -> Int {
        return self.plan
    }
}
