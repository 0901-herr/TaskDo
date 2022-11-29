//
//  ProfileView.swift
//  TaskDo
//
//  Created by Philippe Yong on 16/02/2021.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject var loginSignupViewModel = LogInSignUpViewModel(mode: .signup)
    @Binding var profileIsTapped: Bool
    @State var toneIsTapped = false
    
    @State var premiumIsTapped = false
    @State var activeSheet: ActiveSheet?

//    @State var signUpIsTapped = false

    @ObservedObject var defaultSettings = DefaultSettings()
    
    var profileDetails: some View {
        HStack {
            VStack(spacing: 10) {
                Text(loginSignupViewModel.name)
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.leading, 10)
                    .frame(width: defaultSettings.screenWidth * 0.7, alignment: .leading)

                Text(loginSignupViewModel.email)
                    .font(.system(size: 14))
                    .padding(.leading, 10)
                    .foregroundColor(Color.textColor)
                    .frame(width: defaultSettings.screenWidth * 0.7, alignment: .leading)
            }
        }
    }
    
    var premiumBanner: some View {
        HStack {
            Text("Premium")
                .foregroundColor(Color(#colorLiteral(red: 0.8666666667, green: 0.6470588235, blue: 0.0862745098, alpha: 1)))
                .font(.system(size: 17, weight: .semibold))
            
            Spacer()
            
            Text("Join now")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(#colorLiteral(red: 0.8666666667, green: 0.6470588235, blue: 0.0862745098, alpha: 1)))
                .frame(width: 80, height: 35)
        }
        .padding(.horizontal, 20)
        .frame(width: defaultSettings.screenWidth*0.9, height: 70)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.premiumViewColor, lineWidth: 2)
        )
        .onTapGesture {
            premiumIsTapped = true
            activeSheet = .second
        }
    }
    
    var settingsItemList: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Tone")
                    .font(.system(size: 16))
                Spacer()
                
                Circle()
                    .foregroundColor(Color.taskColors[defaultSettings.defaultValues.integer(forKey: "tone")])
                    .frame(width: 30)
                    .onTapGesture {
                        self.toneIsTapped = true
                    }
            }
            .padding(.horizontal, 6)
            .frame(width: defaultSettings.screenWidth*0.9, height: 65)
            .onTapGesture {
                viewModel.send(.rate)
            }

            HStack {
                Text("Dark Mode")
                    .font(.system(size: 16))
                
                Spacer()
                
                Button(action: {
                    viewModel.send(.onDarkMode)
                }) {
                    VStack {
                        Text(isDarkMode ? "ON" : "OFF")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(isDarkMode ? Color.premiumViewColor : Color.textColor)
                    }
                    .frame(width: 60, height: 30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isDarkMode ? Color.premiumViewColor : Color.viewColor, lineWidth: 1.5)
//                            .opacity(isDarkMode ? 1 : 0)
                    )
//                    .background(
//                        Color.smallRoundCornerBtnColor
//                            .cornerRadius(20)
//                            .opacity(isDarkMode ? 0 : 1)
//                    )
//                    .animation(profileIsTapped ? .none : nil)
                }
            }
            .padding(.horizontal, 6)
            .frame(width: defaultSettings.screenWidth*0.9, height: 65)

            HStack {
                Text("Rate our app")
                    .font(.system(size: 16))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.primaryColor2)
            }
            .padding(.horizontal, 6)
            .frame(width: defaultSettings.screenWidth*0.9, height: 65)
            .onTapGesture {
                viewModel.send(.rate)
            }
            
            HStack {
                Text("Privacy Policy")
                    .font(.system(size: 16))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.primaryColor2)
            }
            .padding(.horizontal, 6)
            .frame(width: defaultSettings.screenWidth*0.9, height: 65)
            .onTapGesture {
                viewModel.send(.privacy)
            }
        }
    }
    
    var logOutButton: some View {
        Button(action: {
            viewModel.loginSignupPushed = true
            activeSheet = .first
        }){
            VStack {
                if loginSignupViewModel.name != "Untitled"{
                    Image(systemName: "arrow.right.square")
                        .font(.system(size: 24))
                        .foregroundColor(Color.primaryColor2)
                }
                else {
                    Image(systemName: "arrow.left.square")
                        .font(.system(size: 24))
                        .foregroundColor(Color.primaryColor2)
                }
            }
        }
    }
    
    var toneOptions: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                ForEach(0..<4) { index in
                    Circle()
                        .frame(width: 40)
                        .foregroundColor(Color.taskColors[index])
                        .onTapGesture {
                            defaultSettings.defaultValues.setValue(index, forKey: "tone")
                            defaultSettings.tone = Color.taskColors[index]
                            self.toneIsTapped = false
                        }
                }
            }
            .frame(width: 310)

            HStack(spacing: 10) {
                ForEach(4..<8) { index in
                    Circle()
                        .frame(width: 40)
                        .foregroundColor(Color.taskColors[index])
                        .onTapGesture {
                            defaultSettings.defaultValues.setValue(index, forKey: "tone")
                            defaultSettings.tone = Color.taskColors[index]
                            self.toneIsTapped = false
                        }
                }
            }
            .frame(width: 310)

            HStack(spacing: 10) {
                ForEach(0..<4) { index in
                    Circle()
                        .frame(width: 40)
                        .foregroundColor(Color.taskColors[index])
                        .onTapGesture {
                            defaultSettings.defaultValues.setValue(index, forKey: "tone")
                            defaultSettings.tone = Color.taskColors[index]
                            self.toneIsTapped = false
                        }
                }
            }
            .frame(width: 310)

            HStack(spacing: 10) {
                ForEach(4..<8) { index in
                    Circle()
                        .frame(width: 40)
                        .foregroundColor(Color.taskColors[index])
                        .onTapGesture {
                            defaultSettings.defaultValues.setValue(index, forKey: "tone")
                            defaultSettings.tone = Color.taskColors[index]
                            self.toneIsTapped = false
                        }
                }
            }
            .frame(width: 310)
        }
        .frame(width: 320, height: 320)
        .background(Color.viewColor)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack {
                    VStack {
                        HStack {
                            HStack(spacing: 20) {
                                Button(action: {
                                    withAnimation {
                                        profileIsTapped.toggle()
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color.primaryColor2)
                                }
                                
                                Text("Profile")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            Spacer()
                        }
                        .padding(.top, proxy.safeAreaInsets.top > 0 ? 20 : 0)
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 25)
                    .frame(width: defaultSettings.screenWidth, height: proxy.safeAreaInsets.top + 60, alignment: .center)
                    .padding(.bottom, 0)
                    
                    HStack {
                        profileDetails
                            .frame(width: defaultSettings.screenWidth * 0.8, alignment: .leading)
                        Spacer()
                        logOutButton
                            .padding(.trailing, 10)
                    }
                    .frame(width: defaultSettings.screenWidth * 0.9, height: defaultSettings.screenHeight*0.1)

                    premiumBanner
                        .padding(.top, 15)
                    settingsItemList
                        .padding(.top, 15)
                    Spacer()
                }
                .frame(width: defaultSettings.screenWidth, height: defaultSettings.screenHeight)
                
                if toneIsTapped {
                    Color.black
                        .opacity(0.4)
                        .frame(width: defaultSettings.screenWidth, height: defaultSettings.screenHeight)
                        .onTapGesture {
                            toneIsTapped = false
                        }
                }
                
                if toneIsTapped {
                    toneOptions
                }
            }
            .edgesIgnoringSafeArea(.all)
            .sheet(item: $activeSheet) { item in
                switch item {
                    case .first:
                        LogInSignUpView(mode: .login, isPushed: $viewModel.loginSignupPushed)
                    case .second:
                        PremiumView()
                }
            }
            .frame(width: defaultSettings.screenWidth, height: defaultSettings.screenHeight - proxy.safeAreaInsets.top, alignment: .center)
            .background(Color.primaryColor.edgesIgnoringSafeArea(.all))
            .onTapGesture {
                withAnimation {
                    toneIsTapped = false
                }
            }
        }
        .transition(.slideLeftToRight)
        .animation(.slide())
    }
}

enum ActiveSheet: Identifiable {
    case first, second
    
    var id: Int {
        hashValue
    }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView()
//    }
//}
