//
//  SignInView.swift
//  TaskDo
//
//  Created by Philippe Yong on 08/04/2021.
//

import SwiftUI

struct LogInSignUpView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State var placeholder = ["Username", "Email", "Password"]
    @State var text = ["", "", ""]
    @ObservedObject var  defaultSettings = DefaultSettings()
    
//    @Binding var signIn: Bool
    
    @StateObject var viewModel: LogInSignUpViewModel
    @Binding var isPushed: Bool
    
    init(mode: LogInSignUpViewModel.Mode, isPushed: Binding<Bool>){//, signIn: Binding<Bool>) {
//        self._signIn = signIn
        self._isPushed = isPushed
        self._viewModel = .init(wrappedValue: .init(mode: mode))
    }
    
    var xmark: some View {
        ZStack {
            Circle()
                .frame(width: 26)
                .foregroundColor(Color.taskColors[defaultSettings.defaultValues.integer(forKey: "tone")])
            
            Image(systemName: "xmark")
                .foregroundColor(Color.primaryColor)
                .font(.system(size: 17, weight: .semibold))
        }
        .onTapGesture {
            if !viewModel.logInIsTapped {
                isPushed = false
            }
        }
        .frame(height: 30)
    }
    
    var headerTitle: some View {
        VStack {
            Text("Welcome to TaskDO")
                .font(.system(size: 30, weight: .semibold))
            
            Text("Stay planned, stay focus")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.textColor)
                .padding(.top, 4)
        }
    }
    
    var inputList: some View {
        VStack(spacing: 14) {
            if !viewModel.logInIsTapped && !viewModel.nextIsTapped {
                VStack {
                    TextField("\(placeholder[0])", text: $viewModel.username)
                        .font(.system(size: 18))
                }
                .padding(.leading, 12)
                .frame(width: 310)
            }
            else {
                VStack {
                    TextField("\(placeholder[1])", text: $viewModel.emailText)
                        .font(.system(size: 18))
                        .autocapitalization(.none)
                }
                .padding(.leading, 12)
                .frame(width: 310)
                
                VStack {
                    SecureField("\(placeholder[2])", text: $viewModel.passwordText)
                        .font(.system(size: 18))
                        .autocapitalization(.none)
                }
                .padding(.leading, 12)
                .frame(width: 310)
            }
        }
        .frame(height: 100)
    }
    
    var signInButton: some View {
        Button(action: {
            if viewModel.isValidEmail(viewModel.emailText) {
                viewModel.tappedAction()
            }
            if !viewModel.username.isEmpty && !viewModel.nextIsTapped {
                viewModel.nextIsTapped = true
            }
            if viewModel.logInIsTapped && viewModel.nextIsTapped {
                isPushed = false
            }
        }){
            VStack {
                Text(viewModel.logInIsTapped ? "Log In": (viewModel.nextIsTapped ? "Sign Up" : "Next"))
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .opacity(viewModel.nextIsTapped ?  (viewModel.isValidEmail(viewModel.emailText) ? 1 : 0.75) : (viewModel.username.isEmpty ? 0.75 : 1))
            }
        }
        .buttonStyle(LandingButtonStyle())
        .opacity(viewModel.nextIsTapped ?  (viewModel.isValidEmail(viewModel.emailText) ? 1 : 0.75) : (viewModel.username.isEmpty ? 0.75 : 1))
    }
    
    var alrHaveAcc: some View {
        HStack(spacing: 2) {
            Text("Already have an account")
                .font(.system(size: 14))
                .foregroundColor(Color.textColor)

            Text("Log In")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.themeBlue)
                .padding(.leading, 2)
                .onTapGesture {
                    viewModel.logInIsTapped = true
                }
        }
    }
    
    var agreeToPolicy: some View {
        HStack(spacing: 1) {
            Text("By signing in, you have agreed to our")
                .font(.system(size: 12))
                .foregroundColor(Color.textColor)
                
            Text("Privacy Policy")
                .font(.system(size: 12))
                .foregroundColor(Color.themeBlue)
                .padding(.leading, 2)
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(Color.green)
        }
    }
    
    var body: some View {
        GeometryReader { _ in
            VStack {
                HStack {
                    Spacer()
                    xmark
                }
                .padding([.top, .trailing], 25)
                
                Spacer()
                    .frame(height: defaultSettings.screenHeight * 0.15)

                headerTitle
                
                inputList
                    .padding(.vertical, 40)

                signInButton
                
                alrHaveAcc
                    .padding(.top, 20)
                
                agreeToPolicy
                    .padding(.top, 40)
                
                Spacer()
            }
            .frame(width: defaultSettings.screenWidth, height: defaultSettings.screenHeight, alignment: .center)
            .edgesIgnoringSafeArea(.all)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onTapGesture {
            endEditing(true)
        }
    }
}


import Combine

final class LogInSignUpViewModel: ObservableObject {
    private let mode: Mode
    @Published var username = ""
    @Published var emailText = ""
    @Published var passwordText = ""
    
    @Published var name = ""
    @Published var email = ""
    
    @Published var isValid = false
    @Published var isPushed = true
    @Published var logInIsTapped = false
    @Published var nextIsTapped = false
    
    private(set) var emailPlaceholderText = "Email"
    private(set) var passwordPlaceholderText = "Password"
    private let userService: UserServiceProtocol
    private var cancellables: [AnyCancellable] = []
    
    var userDefault: UserDefaults = UserDefaults.standard
    
    init(
        mode: Mode,
        userService: UserServiceProtocol = UserService()
    ) {
        self.mode = mode
        self.userService = userService
        self.name = self.userDefault.string(forKey: "username") ?? "Untitled"
        self.email = self.userDefault.string(forKey: "emailText") ?? "Sign in with email"
        
        Publishers.CombineLatest($emailText, $passwordText)
            .map { [weak self] email, password in
                return self?.isValidEmail(email) == true && self?.isValidPassword(password) == true
            }
            .assign(to: &$isValid)
    }
    
    func tappedActionButton() {
        switch mode {
        case .login:
            userService.login(email: emailText, password: passwordText).sink { completion in
                switch completion {
                case let .failure(error):
                    print(error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
            
        case .signup:
            userService.linkAccount(email: emailText, password: passwordText).sink { [weak self] completion in
                switch completion {
                case let .failure(error):
                    print(error.localizedDescription)
                case .finished:
                    print("finished")
                    self?.isPushed = false
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
        }
    }
}

extension LogInSignUpViewModel {
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email) && email.count > 5
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return password.count > 5
    }
    
    func tappedAction() {
        self.userDefault.set(username, forKey: "username")
        self.userDefault.set(emailText, forKey: "emailText")
        self.userDefault.set(passwordText, forKey: "passwordText")
//        self.userDefault.set(isSignUp, forKey: "isSignUp")
            
        tappedActionButton()
//        self.timerDefault.set(self.taskTitle, forKey: "taskTitle")
//        self.taskTitle = self.timerDefault.string(forKey: "taskTitle") ?? ""
//        timerDefault.removeObject(forKey: "resignArray")
    }
    
    
    enum AccStatus {
        case logIn
        case signUp
    }
}

extension LogInSignUpViewModel {
    enum Mode {
        case login
        case signup
    }
}


//struct SignInView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignInView()
//    }
//}
