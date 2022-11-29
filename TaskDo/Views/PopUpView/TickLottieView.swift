//
//  TickLottieView.swift
//  TaskDo
//
//  Created by Philippe Yong on 25/06/2021.
//

import SwiftUI

struct TickLottieView: View {
    var body: some View {
        VStack {
            LottieView(filename: "Tick")
                .frame(width: 34)
        }
    }
}

struct TickLottieView_Previews: PreviewProvider {
    static var previews: some View {
        TickLottieView()
    }
}
