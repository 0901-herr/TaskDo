//
//  ContentView.swift
//  TaskDo
//
//  Created by Philippe Yong on 06/01/2021.
//

import SwiftUI

struct LandingView: View {
    @StateObject private var viewModel = LandingViewModel()

    var startButton: some View {    
        Button(action: {
            viewModel.send(action: .enterTaskListView)
        }){
            VStack {
                Text(viewModel.startButtonTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(#colorLiteral(red: 0.4666666667, green: 0.2235294118, blue: 0, alpha: 1)))
            }
        }
        .buttonStyle(LandingButtonStyle())
    }
    
    var body: some View {
        if viewModel.startPushed {
            TabContainerView()
        }
        else {
            NavigationView {
                GeometryReader { proxy in
                    VStack {
                        Text(viewModel.title)
                            .font(.system(size: 30, weight: .bold))
                        
                        Spacer()
                            .frame(height: proxy.size.height * 0.6)
                                            
                        startButton
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView().previewDevice("iPhone 8")
    }
}
