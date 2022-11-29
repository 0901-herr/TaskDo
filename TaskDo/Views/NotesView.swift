//
//  NotesView.swift
//  TaskDo
//
//  Created by Philippe Yong on 01/02/2021.
//

import SwiftUI
import Combine

struct NotesView: View {    
    @StateObject var viewModel = NotesViewModel()
    
    @Binding var notesIsTapped: Bool
    @State var taskId: String
    @State var taskTitle: String
    @State var taskColorIndex: Int

    @Binding var taskNotes: [Notes]
    
    @State var newNotesIsTapped = false
    @State var editNotesIsTapped = false
    @ObservedObject var defaultSettings = DefaultSettings()
    @State var showAdd = true
    
    var title: some View {
        HStack(spacing: 10) {
            Circle()
                .frame(width: 10)
                .foregroundColor(taskColorIndex == 0 || taskColorIndex > 7 ? Color.taskColors[0] : Color.taskColors[taskColorIndex])

            Text(taskTitle)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
        }
        .frame(width: defaultSettings.frameWidth * 0.65, height: defaultSettings.screenHeight*0.05, alignment: .leading)
    }
    
    var notesList: some View {
        ScrollView(.vertical) {
            ForEach(viewModel.notesList, id: \.id) { notes in
                if notes.id == taskId {
                    ForEach(notes.notesItem.reversed(), id: \.self) { item in
                        VStack(spacing: 10) {
                            HStack {
                                Text("\(viewModel.getFormattedDate(item.date))")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.taskColors[taskColorIndex])
                            }
                            .frame(width: 120, height: 33, alignment: .center)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.taskColors[taskColorIndex], lineWidth: 1.5)
                            )
                            .padding(.bottom, 6)
                            
                            VStack {
                                Text("\(item.text)")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.primary)
                            }
                            .padding()
                            .frame(width: defaultSettings.screenWidth * 0.935, alignment: .topLeading)
                            .background(Color.viewColor)
                            .cornerRadius(10)
                        }
                        .padding(.vertical, 15)
                        .frame(width: defaultSettings.screenWidth)
                        .onAppear {
                            if viewModel.getFormattedDate(Date()) == viewModel.getFormattedDate(item.date) {
                                self.showAdd = false
                            }
                        }
                        .onTapGesture {
                            viewModel.date = item.date
                            viewModel.notes = item.text
                            editNotesIsTapped = true
                            newNotesIsTapped.toggle()
                        }
                    }
                }
            }
        }
    }
    
    var notesCount: some View {
        VStack {
            HStack(spacing: 0) {
                Text("\(viewModel.notesList.count)")
                    .font(.system(size: 14))
                    .foregroundColor(Color.textColor)
                    .frame(width: 22)
                
                Text(" / 10")
                    .font(.system(size: 11))
                    .foregroundColor(Color.textColor)
                    .frame(width: 34)

            }
        }
        .frame(width: 80, height: 35)
        .background(Color.viewColor)
        .cornerRadius(20)
    }

    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                VStack {
                    HStack {
                        HStack(spacing: 20) {
                            Button(action: {
                                withAnimation {
                                    notesIsTapped.toggle()
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color.primaryColor2)
                            }
                            
                            Text("Notes")
                                .font(.system(size: 20, weight: .bold))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                viewModel.notes = ""
                                
                                newNotesIsTapped.toggle()
                                viewModel.send(action: .addNewNotes)
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(Font.system(size: 24, weight: .semibold))
                                .foregroundColor(Color.primaryColor2)
                        }
                        .opacity(self.showAdd ? 1 : 0)
                    }
                    .padding(.top, proxy.safeAreaInsets.top > 0 ? 20 : 0)
                }
                .padding(.top, 10)
                .padding(.horizontal, 25)
                .frame(width: defaultSettings.screenWidth, height: proxy.safeAreaInsets.top + 60, alignment: .center)
                .padding(.bottom, 0)
                
                HStack {
                    title
                    Spacer()
                    notesCount
                }
                .frame(width: defaultSettings.frameWidth)
                
                notesList
                    .padding(.top, 4)
                
                Spacer()
                    .frame(height: 20)
            }
            .onAppear {
                viewModel.taskId = taskId
                viewModel.taskNotes = taskNotes
            }
            .edgesIgnoringSafeArea(.all)
            .frame(width: defaultSettings.screenWidth, height: defaultSettings.screenHeight - proxy.safeAreaInsets.top, alignment: .center)
            .sheet(isPresented: $newNotesIsTapped) {
                NewNotesView(viewModel: viewModel, taskColorIndex: taskColorIndex, newNotesIsTapped: $newNotesIsTapped, editNotesIsTapped: $editNotesIsTapped)
            }
            .frame(width: defaultSettings.screenWidth)
        }
        .frame(width: defaultSettings.screenWidth)
        .background(Color.primaryColor.edgesIgnoringSafeArea(.all))
        .transition(.slideRightToLeft)
        .animation(.slide())
    }
}

struct NewNotesView: View {
    private let defaultSettings = DefaultSettings()
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    @ObservedObject var viewModel: NotesViewModel
    @ObservedObject var keyboardHeightHelper = KeyboardHeightHelper()

    @State var notes = ""
    @State var taskColorIndex: Int = 0

    @Binding var newNotesIsTapped: Bool
    @Binding var editNotesIsTapped: Bool
    @State var textFieldHeight = UIScreen.main.bounds.height * 0.35
    let textLimit = 300

    var navBar: some View {
        VStack {
            HStack {
                HStack(spacing: 20) {
                    Button(action: {
                        endEditing(true)
                        withAnimation {
                            newNotesIsTapped.toggle()
                        }
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.primaryColor2)
                    }
                    
                    Text(editNotesIsTapped ?  "Edit" : "Today")
                        .font(.system(size: 20, weight: .bold))
                }
                
                Spacer()
                
                Button(action: {
                    endEditing(true)
                    newNotesIsTapped.toggle()
                    viewModel.send(action: .saveNotes)
                }) {
                    Text("Save")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.taskColors[taskColorIndex])
                        .frame(width: 65, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.taskColors[taskColorIndex], lineWidth: 1.5)
                        )
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(width: defaultSettings.screenWidth, height: 70, alignment: .center)
        .padding(.bottom, 0)
    }
    
    var wordCount: some View {
        VStack {
            HStack(spacing: 0) {
                Text("\(viewModel.notes.count)")
                    .font(.system(size: 14))
                    .foregroundColor(Color.textColor)
                    .frame(width: 30)
                
                Text(" / \(textLimit)")
                    .font(.system(size: 11))
                    .foregroundColor(Color.textColor)
                    .frame(width: 34)

            }
        }
        .frame(width: 85, height: 35)
        .background(Color.viewColor)
        .cornerRadius(20)
    }
    
    var textField: some View {
        TextEditor(text: $viewModel.notes)
            .onReceive(Just(viewModel.notes)) { _ in limitText(textLimit) }
            .frame(width: defaultSettings.frameWidth, height: defaultSettings.screenHeight*0.35)
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                navBar
                
                HStack {
                    wordCount
                    Spacer()
                }
                .frame(width: defaultSettings.frameWidth)
                .padding(.top, 6)
                
                TextEditor(text: $viewModel.notes)
                    .onReceive(Just(viewModel.notes)) { _ in limitText(textLimit) }
                    .frame(width: defaultSettings.frameWidth, height: textFieldHeight)
                    .padding(.top, 10)
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardDidHideNotification)) {_ in
                        textFieldHeight = UIScreen.main.bounds.height * 0.7
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardDidShowNotification)) {_ in
                        textFieldHeight = UIScreen.main.bounds.height * 0.35
                    }
                    
                Spacer()
            }
            .frame(width: defaultSettings.screenWidth, height: defaultSettings.screenHeight, alignment: .center)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                endEditing(true)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    //Function to keep text length in limits
    func limitText(_ upper: Int) {
        if viewModel.notes.count > upper {
            viewModel.notes = String(viewModel.notes.prefix(upper))
        }
    }
}


/*
struct MultiTextField: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        return MultiTextField.Coordinator(parent1: self)
    }
    
    @EnvironmentObject var obj: observed
    
    func makeUIView(context: Context) -> some UIView {
        let view = UITextView()
        view.font = .systemFont(ofSize: 18)
        view.text = "Your thoughts"
        view.textColor = UIColor.black.withAlphaComponent(0.35)
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MultiTextField
        
        init(parent1: MultiTextField) {
            parent = parent1
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            textView.text = ""
            textView.textColor = .black
        }
        
        func textViewDidChange(_ textView: UITextView) {
            
        }
    }
}

class observed: ObservableObject {
    @Published var size: CGFloat = 0
}
*/


