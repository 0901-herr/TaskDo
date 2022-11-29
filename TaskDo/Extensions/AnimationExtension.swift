//
//  AnimationExtension.swift
//  TaskDo
//
//  Created by Philippe Yong on 27/01/2021.
//

import SwiftUI

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        let insertion = AnyTransition.move(edge: .bottom)
            .combined(with: .opacity)
        let removal = AnyTransition.move(edge: .bottom)
            .combined(with: .opacity).animation(.spring())
        return .asymmetric(insertion: insertion, removal: removal)
    }
    
    static var moveAndFadeTop: AnyTransition {
        let insertion = AnyTransition.move(edge: .top)
            .combined(with: .opacity)
        let removal = AnyTransition.move(edge: .top)
            .combined(with: .opacity).animation(.spring())
        return .asymmetric(insertion: insertion, removal: removal)
    }

    
    static var slideLeftToRight: AnyTransition {
        let insertion = AnyTransition.move(edge: .leading)
            //.combined(with: .opacity)
        let removal = AnyTransition.move(edge: .leading)
            //.combined(with: .opacity)//.animation(.spring())
        return .asymmetric(insertion: insertion, removal: removal)
    }
    
    static var slideRightToLeft: AnyTransition {
        let insertion = AnyTransition.move(edge: .trailing)
            //.combined(with: .opacity)
        let removal = AnyTransition.move(edge: .trailing)
            //.combined(with: .opacity)//.animation(.spring())
        return .asymmetric(insertion: insertion, removal: removal)
    }
}

extension Animation {
    static func ripple() -> Animation {
        Animation.default//.spring()
            .speed(1.5)
    }
    
    static func softRipple() -> Animation {
        Animation.default//.spring(dampingFraction: 0.8)
            .speed(1)
    }
    
    static func expand() -> Animation {
        Animation.default
            .speed(1.5)
    }
    
    static func slide() -> Animation {
        Animation.default
            .speed(1.5)
    }
}
