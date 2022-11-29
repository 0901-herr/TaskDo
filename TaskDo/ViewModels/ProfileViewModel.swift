//
//  ProfileViewModel.swift
//  TaskDo
//
//  Created by Philippe Yong on 18/02/2021.
//

import Foundation
import SwiftUI

final class ProfileViewModel: ObservableObject {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Published var logTxt = "Log Out"
    @Published var loginSignupPushed = false
    
    var userDefault: UserDefaults = UserDefaults.standard

    enum ProfileAction {
        case rate
        case privacy
        case onDarkMode
    }
    
    func send(_ action: ProfileAction) {
        switch action {
        case .rate:
            print("Rate app")
        case .privacy:
            print("Privacy Policy")
        case .onDarkMode:
            isDarkMode.toggle()
            print("Dark mode")
        }
    }
}

