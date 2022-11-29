//
//  LineChartView.swift
//  TaskDo
//
//  Created by Philippe Yong on 09/02/2021.
//

import SwiftUI

struct LineGraph: Shape {
    var dataPoints: [CGFloat]
    @Binding var yDataList: [CGFloat]
        
    func path(in rect: CGRect) -> Path {
        func point(at i: Int) -> CGPoint {
            let point = dataPoints[i]
            let x = rect.width * CGFloat(i) / CGFloat(dataPoints.count - 1)
            let y = (1 - point) * rect.height
            return CGPoint(x: x, y: y)
        }
        
        return Path { p in
            guard dataPoints.reduce(0, +) > 0 else { return }
            let start = dataPoints[0]
            p.move(to: CGPoint(x: 0, y: Int((1 - start) * rect.height)))
            
            for i in dataPoints.indices {
                p.addLine(to: point(at: i))
            }
        }
    }
}

struct LineGraphView: View {
    @StateObject var viewModel: StatsViewModel
    @ObservedObject var defaultSettings = DefaultSettings()
    private let frameWidth = UIScreen.main.bounds.width * 0.9
    
    @State var barData: [WeekGraphData] = []
    @State var lineWidth: CGFloat = 0
    @State private var touchLocation: CGPoint = .zero
    @State var startAnimation = false

    @Binding var focusTime: Int
    @Binding var graphIsTapped: Bool
    @Binding var selectedIndex: Int
  
    @State var postions = CGPoint(x: 0, y: 162)
    @State var barDataNormalized: [CGFloat] = []
    @State var yDataList: [CGFloat] = []
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                        .frame(width: defaultSettings.frameWidth * 0.88, height: 0.5)

                    Text("\(viewModel.graphLineDataList[2][0])\(viewModel.lineUnit[2])")
                        .font(.system(size: 11))
                        .foregroundColor(Color.textColor)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                        .frame(width: defaultSettings.frameWidth * 0.88, height: 0.5)

                    Text("\(viewModel.graphLineDataList[2][1])\(viewModel.lineUnit[2])")
                        .font(.system(size: 11))
                        .foregroundColor(Color.textColor)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                        .frame(width: defaultSettings.frameWidth * 0.88, height: 0.5)
                    
                    Text("\(viewModel.graphLineDataList[2][2])\(viewModel.lineUnit[2])")
                        .font(.system(size: 11))
                        .foregroundColor(Color.textColor)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                        .frame(width: defaultSettings.frameWidth * 0.88, height: 0.5)

                    Text("\(viewModel.graphLineDataList[2][3])\(viewModel.lineUnit[2])")
                        .font(.system(size: 11))
                        .foregroundColor(Color.textColor)
                }
            }
            .frame(width: defaultSettings.frameWidth * 0.95, height: 180)

            ZStack {
                LinearGradient(gradient:
                    Gradient(colors: [Color(#colorLiteral(red: 0.4901960784, green: 0.5058823529, blue: 0.9803921569, alpha: 1)), Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))]), startPoint: .top, endPoint: .bottom)
                        .clipShape(LineGraph(dataPoints: barData.map { CGFloat($0.focusTime) }.normalized, yDataList: $yDataList))
                
                LineGraph(dataPoints: barData.map { CGFloat($0.focusTime) }.normalized, yDataList: $yDataList)
                    .stroke(style: StrokeStyle(lineWidth: 1.0, lineCap: .round))
                    .trim(to: startAnimation ? 1 : 0)
                    .stroke(lineWidth: 1.5)
                    .foregroundColor(Color.themeBlue)
                    .frame(width: frameWidth * 0.75, height: 168)
            }
            .frame(width: frameWidth * 0.85, alignment: .leading)
            
            if viewModel.weekGraphBarData.map{ $0.focusTime }.reduce(0, +) > 0 {
                VStack {
                    VStack {
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(Color(#colorLiteral(red: 0.8512224555, green: 0.8485807776, blue: 0.853295505, alpha: 1)))
                    }
                    .position(x: postions.x, y: postions.y)
                    .gesture(
                        DragGesture()
                        .onChanged({ value in
                            graphIsTapped = true

                            self.touchLocation = value.location
                            let x = Double(touchLocation.x)
                            let y = Double(touchLocation.y)
                            
                            print("LINE WIDTH: \(lineWidth)")
                            print("DRAG X LOCATION: \(x)")
                            print("DRAG Y LOCATION: \(y)")
                            
                            var index = 0
                            let lineIdxWidth = Double(lineWidth)
                            
                            if (x > lineIdxWidth) && (Int(x/lineIdxWidth) < barData.count-1) {
                                index = Int(round(x/lineIdxWidth))
                            }
                            else if !(x > lineIdxWidth) {
                                index = 0
                            }
                            else if !(Int(x/lineIdxWidth) < barData.count-1) {
                                index = barData.count - 1
                            }
                                
                            print("INDEX: \(index)")
                            selectedIndex = index
                            focusTime = Int(barData[index].focusTime)
                            
                            if value.location.x > 0 && value.location.x < 270 {
                                self.postions.x = value.location.x
                                self.postions.y = yDataList[selectedIndex] + 2
                            }
                            print("POSITIONs: \(postions)")
                        })
                        .onEnded {_ in
                            graphIsTapped = false
                        })
                    .padding(.top, 40)
                    .frame(width: frameWidth * 0.75, alignment: .leading)
                }
                .frame(width: frameWidth * 0.85, alignment: .leading)
            }
        }
        .onAppear {
            lineWidth = CGFloat(Double(frameWidth * 0.75) / Double(barData.count))
            barDataNormalized = barData.map { CGFloat($0.focusTime) }.normalized
            let rect = CGRect(x: 0.0, y: 0.0, width: frameWidth * 0.85, height: 160)
            for i in barDataNormalized.indices {
                yDataList.append((1 - barDataNormalized[i]) * rect.height)
            }
            withAnimation(.easeInOut(duration: 1.5)) {
                startAnimation = true
            }
        }
        .frame(width: frameWidth, height: 240)
//        .background(Color.viewColor)
//        .cornerRadius(10)
    }
}

extension Array where Element == CGFloat {
    var normalized: [CGFloat] {
        if let min = self.min(), let max = self.max() {
            return self.map { ($0 - min) / (max - min)}
        }
        return []
    }
}

//struct LineGraphView_Previews: PreviewProvider {
//    static var previews: some View {
//        LineGraphView()
//    }
//}
