//
//  CloudLottieView.swift
//  TaskDo
//
//  Created by Philippe Yong on 05/07/2021.
//

import SwiftUI

struct CloudLottieView: View {
    var body: some View {
        VStack {
            LottieLoopView(filename: "Cloud")
                .frame(width: UIScreen.main.bounds.width)
        }
    }
}

struct CloudLottieView_Previews: PreviewProvider {
    static var previews: some View {
        CloudLottieView()
    }
}
