//
//  ViewExtension.swift
//  TaskDo
//
//  Created by Philippe Yong on 27/01/2021.
//

import SwiftUI

extension View {
    func endEditing(_ force: Bool) {
        UIApplication.shared.windows.forEach { $0.endEditing(force)}
    }
}

struct MultilineTextField: UIViewRepresentable {
    
    @Binding var text: String
    @State var txt: String = ""
    
    func makeCoordinator() -> Coordinator {
        return MultilineTextField.Coordinator(parent1: self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<MultilineTextField>) -> UITextView {
        let textView = UITextView()
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        textView.text = self.txt
        textView.textColor = UIColor.gray
        textView.font = .systemFont(ofSize: 18)
        textView.delegate = context.coordinator
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        
        var parent: MultilineTextField
        
        init(parent1: MultilineTextField) {
            
            parent = parent1
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
        }
        func textViewDidBeginEditing(_ textView: UITextView) {
            textView.text = ""
            textView.textColor = .label
        }
//        func textViewDidEndEditing(_ textView: UITextView) {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
//                textView.text = "Type something..."
//                textView.textColor = UIColor.gray
//            }
//        }
    }
}

struct FirstResponderTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        var becamFirstResponder = false
        
        init(text: Binding<String>) {
            self._text = text
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }
    
    func makeUIView(context: Context) -> some UIView {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        return textField
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if !context.coordinator.becamFirstResponder {
            uiView.becomeFirstResponder()
            context.coordinator.becamFirstResponder = true
        }
    }
}


