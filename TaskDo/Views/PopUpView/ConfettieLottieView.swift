//
//  ConfettieLottieView.swift
//  TaskDo
//
//  Created by Philippe Yong on 18/02/2021.
//

import SwiftUI

struct ConfettieLottieView: View {
    var body: some View {
        VStack {
            LottieView(filename: "Confetti2")
                .frame(width: UIScreen.main.bounds.width, height: 200)
        }
    }
}

struct ConfettieLottieView_Previews: PreviewProvider {
    static var previews: some View {
        ConfettieLottieView()
    }
}
