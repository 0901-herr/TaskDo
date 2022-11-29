//
//  PagerView.swift
//  TaskDo
//
//  Created by Philippe Yong on 06/02/2021.
//

import Foundation
import SwiftUI

struct PagerView<Content: View>: View {
    @Binding var currentIndex: Int
    let pageCount: Int
    let content: Content
    
    init(pageCount: Int, currentIndex: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self.content = content()
    }
    
    @GestureState private var translation: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                self.content.frame(width: geometry.size.width)
            }
            .frame(width: geometry.size.width, alignment: .leading)
            .offset(x: -CGFloat(self.currentIndex) * geometry.size.width)
            .offset(x: self.translation)
            .animation(Animation.default.speed(2.0))
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    if self.currentIndex != 0 && value.translation.width > 50 {
                        state = value.translation.width // right swipe
                    }
                    
                    else {}
                    
                    if self.currentIndex != 2 && -value.translation.width > 50 {
                        state = value.translation.width // left swipe
                    }
                    
                    else{}
                }
                .onEnded { value in
                    let offset = (value.translation.width / geometry.size.width) * 2
                    let newIndex = (CGFloat(self.currentIndex) - offset).rounded()
                    self.currentIndex = min(max(Int(newIndex), 0), self.pageCount - 1)
                }
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct DoublePagerView<Content: View>: View {
    @Binding var currentIndex: Int
    let pageCount: Int
    let content: Content
    
    init(pageCount: Int, currentIndex: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self.content = content()
    }
    
    @GestureState private var translation: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                self.content.frame(width: geometry.size.width)
            }
            .frame(width: geometry.size.width, alignment: .leading)
            .offset(x: -CGFloat(self.currentIndex) * geometry.size.width)
            .offset(x: self.translation)
            .animation(Animation.default.speed(1.5))
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    if self.currentIndex == 1 && value.translation.width > 50 {
                        state = value.translation.width // right swipe
                    }
                    
                    else {}
                    
                    if self.currentIndex == 0 && -value.translation.width > 50 {
                        state = value.translation.width // left swipe
                    }
                    else{}
                }
                .onEnded { value in
                    let offset = (value.translation.width / geometry.size.width) * 3.5
                    let newIndex = (CGFloat(self.currentIndex) - offset).rounded()
                    self.currentIndex = min(max(Int(newIndex), 0), self.pageCount - 1)
                }
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct PageTabView<Content: View>: View {
    @Binding var currentIndex: Int
    @Binding var direction: Int
    let pageCount: Int
    let content: Content
    
    init(pageCount: Int, currentIndex: Binding<Int>, direction: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self._direction = direction
        self.content = content()
    }
    
    @GestureState private var translation: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                self.content.frame(width: geometry.size.width)
            }
            .frame(width: geometry.size.width, alignment: .leading)
            .offset(x: -CGFloat(self.currentIndex) * geometry.size.width)
            .offset(x: self.translation)
            .animation(Animation.default.speed(2.0))
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    if value.translation.width > 50 {
                        state = value.translation.width // right swipe
                    }
                    
                    else {}
                    
                    if -value.translation.width > 50 {
                        state = value.translation.width // left swipe
                    }
                    
                    else{}
                }
                .onEnded { value in
                    let oldIndx = self.currentIndex
                    let offset = (value.translation.width / geometry.size.width) * 2
                    let newIndex = (CGFloat(self.currentIndex) - offset).rounded()
                    self.currentIndex = min(max(Int(newIndex), 0), self.pageCount - 1)
                    
                    if oldIndx < currentIndex {
                        self.direction += 1
                    }
                    else if oldIndx > currentIndex {
                        self.direction -= 1
                    }
                }
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
}


