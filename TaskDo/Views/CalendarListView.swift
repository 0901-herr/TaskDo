//
//  CalendarView.swift
//  TaskDo
//
//  Created by Philippe Yong on 16/02/2021.
//

import SwiftUI
import UIKit
import FSCalendar

struct CalendarListView: View {
    @StateObject var viewModel = CalendarListViewModel()
    @StateObject var calendarViewModel = CalendarViewModel()
    @ObservedObject var taskListViewModel: TaskListViewModel
    
    @StateObject var myCalendarState = MyCalendarState()
    @StateObject var calendarActionViewModel: CalendarActionViewModel
    @State var changeScope = false
    
    @Binding var myCalendarItem: MyCalendarItem

    @Binding var selectedDay: Int
    @Binding var defaultDayIsSelected: Bool
    @State var weekDates = []
    
    @State var currentWeekIdx = 0
    @State var frontPointer = -2
    @State var backPointer = 2
    @State var numberOfWeeks = 1
    
    @State var weeks: [WeekDates] = []
    
    @ObservedObject var defaultSettings = DefaultSettings()
    
    @Binding var showCalendar: Bool
    @Binding var profileIsTapped: Bool
    @State var direction = 0
        
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation {
                        profileIsTapped.toggle()
                    }
                }) {
                    VStack(spacing: 2.5) {
                        Rectangle()
                            .frame(width: 20, height: 4)
                            .foregroundColor(Color.primaryColor2)
                        Rectangle()
                            .frame(width: 20, height: 4)
                            .foregroundColor(Color.primaryColor2)
                    }
                }
                
                Spacer()
                
                HStack {
                    Text("\(defaultSettings.getFormattedDateIV(myCalendarItem.month))")
                        .font(.system(size: 20, weight: .semibold))
                        .animation(.none)
                    
                    if showCalendar && defaultSettings.getFormattedDateV(calendarViewModel.month) != defaultSettings.getFormattedDateV(Date()){
                        Text("\(defaultSettings.getFormattedDateV(myCalendarItem.date))")
                            .font(.system(size: 16, weight: .semibold))
                            .animation(.none)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    showCalendar.toggle()
                    
                    // For header title
                    myCalendarItem.month = myCalendarItem.date

                    calendarActionViewModel.updateScope = true
                    myCalendarItem.scope = myCalendarItem.scope == .week ? .month : .week
//                        changeScope = true
                    
                    if myCalendarItem.scope == .week {
                        myCalendarItem.calendarPad = -190
                    }
                    else {
                        myCalendarItem.calendarPad = 7
                    }
                    print("UPDATE SCOPE")
                }) {
                    Image(systemName: myCalendarItem.scope == .month ? "chevron.up" : "chevron.down")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.primaryColor2)
                }
            }
            .frame(width: defaultSettings.frameWidth, height: 30, alignment: .top)
            
            MyCalendar(myCalendarItem: $myCalendarItem, calendarActionViewModel: calendarActionViewModel, changeScope: $changeScope)
                .padding(.top, -2)
                .frame(width: defaultSettings.screenWidth*0.975, height: 270)
        }
        .frame(height: 300)
    }
    
    public func getNextWeek(n: Int) -> [WeekDay] {
        var selectedWeekDate: [WeekDay] = []
        selectedWeekDate = Date().getSelectedWeekDays(n: n)
        return selectedWeekDate
    }
}

struct CalendarView: View {
    @StateObject var calendar: CalendarViewModel
    @StateObject var calendarListViewModel: CalendarListViewModel
    
    var body: some View {
        VStack {
            calendar
        }
    }
}

import UIKit
import Combine

public final class MyCalendarState: ObservableObject {
    @Published var date = Date()
    @Published var month = Date()
    @Published var isSwipe = false
    @Published var dateIsTapped = false
    @Published var scope = FSCalendarScope.week
    
    @State public static var shared = MyCalendarState()
}

struct MyCalendarItem: Hashable {
    var date: Date
    var month: Date
    var isSwipe: Bool
    var dateIsTapped: Bool
    var calendarPad: CGFloat
    var scope: FSCalendarScope
//    var calendar: FSCalendar
}

public class CalendarActionViewModel: ObservableObject {
    @Published public var updateScope: Bool = false
    @Published public var selectDate: Bool = false
    @Published public var date: Date = Date()
}

struct MyCalendar: UIViewControllerRepresentable {
    @Binding var myCalendarItem: MyCalendarItem
    private let viewController: MyCalendarController
    @Binding var changeScope: Bool
    @ObservedObject var calendarActionViewModel: CalendarActionViewModel
    
    @State var firstLaunch = true
    
    init(
        myCalendarItem: Binding<MyCalendarItem>,
        calendarActionViewModel: CalendarActionViewModel,
        changeScope: Binding<Bool>
    ) {
        self._myCalendarItem = myCalendarItem
        self.calendarActionViewModel = calendarActionViewModel
        self._changeScope = changeScope
        self.viewController = MyCalendarController(myCalendarItem: myCalendarItem, changeScope: changeScope, calendarActionViewModel: calendarActionViewModel)
    }
    
    func makeCoordinator() -> MyCalendar.Coordinator {
        Coordinator()
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MyCalendar>) -> MyCalendarController {
        let calendar = viewController
        return calendar
    }

    func updateUIViewController(_ calendar: MyCalendarController, context: UIViewControllerRepresentableContext<MyCalendar>) {
        if calendar.calendar != nil {
            if calendarActionViewModel.updateScope {
                print("Updating scope")
                calendar.setScope()
            }
            else if calendarActionViewModel.selectDate {
                print("Selecting date")
                calendar.calendar.select(calendarActionViewModel.date)
                calendarActionViewModel.selectDate = false
            }
        }
    }
    
    class Coordinator : NSObject {}
}

final class MyCalendarController: UIViewController, ObservableObject, FSCalendarDelegateAppearance {
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Binding private var myCalendarItem: MyCalendarItem
    @Binding var changeScope: Bool
    var calendarActionViewModel: CalendarActionViewModel
    
    var calendar: FSCalendar!
    private var cancellable: AnyCancellable!
    
    init(
        myCalendarItem: Binding<MyCalendarItem>,
        changeScope: Binding<Bool>,
        calendarActionViewModel: CalendarActionViewModel
    ) {
        self._myCalendarItem = myCalendarItem
        self._changeScope = changeScope
        self.calendarActionViewModel = calendarActionViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setScope() {
        if calendar.scope == .week {
            calendar.scope = .month
            calendarActionViewModel.updateScope = false
        }
        else {
            calendar.scope = .week
            calendarActionViewModel.updateScope = false
        }
    }
    
    override func loadView() {
        let width: CGFloat = UIScreen.main.bounds.width * 0.975
        let frame: CGRect  = .init(x: 0, y: 0, width: width, height: 270)
        let view:  UIView  = .init(frame: frame)
        self.view = view
        
        let defaultSettings = DefaultSettings()
        
        let calendar: FSCalendar = .init(frame: frame)
        calendar.allowsMultipleSelection = false
        calendar.dataSource = self
        calendar.delegate = self
        
        view.addSubview(calendar)
        self.calendar = calendar
        calendar.firstWeekday = 2
        
        calendar.appearance.headerDateFormat = "MMMM"
        calendar.calendarHeaderView.isHidden = true
        calendar.headerHeight = 0
        
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 13)
        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 13)
        calendar.appearance.weekdayTextColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        calendar.appearance.caseOptions = .weekdayUsesSingleUpperCase
        
        calendar.appearance.titleDefaultColor = isDarkMode ? .white : .black
        calendar.appearance.todayColor = Color.taskColorsUI[defaultSettings.defaultValues.integer(forKey: "tone")]
        calendar.appearance.selectionColor = Color.taskColorsUI[defaultSettings.defaultValues.integer(forKey: "tone")]
//        calendar.adjustMonthPosition()

        calendar.swipeToChooseGesture.isEnabled = true
        let scopeGesture = UIPanGestureRecognizer(target: calendar, action: #selector(calendar.handleScopeGesture(_:)));
        scopeGesture.delegate = self
        calendar.addGestureRecognizer(scopeGesture)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendar.scope = .week
        self.calendar.select(myCalendarItem.date)
        self.calendar.accessibilityIdentifier = "calendar"
    }
}

extension MyCalendarController: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        myCalendarItem.date = date
        myCalendarItem.dateIsTapped.toggle()
        
        print("Day selected: \(dateFormatter.string(from: myCalendarItem.date))")
        
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let currentMonth = calendar.currentPage
        myCalendarItem.month = currentMonth
        
        if calendar.scope == .week {
            let todayWeekIndex = Date().getWeekDay(date: Date())
            myCalendarItem.date = currentMonth.getNextDay(date: currentMonth, todayWeekIndex)
            calendar.select(myCalendarItem.date)
        }
        
        myCalendarItem.isSwipe.toggle()
        print("Current date: \(myCalendarItem.date)")
    }
}

extension MyCalendarController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendar.frame.size.height = bounds.height
        self.calendar.frame.size.height = bounds.height
        
        myCalendarItem.calendarPad = CGFloat(Int(-(270-bounds.height) + 7))
        
        print("CALENDAR HEIGHT: \(self.calendar.frame.size.height)")
        
        if self.calendar.frame.size.height >= 270 {
            myCalendarItem.scope = .month
        }
        else {
            myCalendarItem.scope = .week
        }
        
        print("PAD: \(myCalendarItem.calendarPad)")
        self.view.layoutIfNeeded()
    }
}

extension MyCalendarController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        debugPrint("UIGestureRecognizer")
        
        return true
    }
}

extension UIColor {
    static func parse(_ hex: UInt32, alpha: Double = 1.0) -> UIColor {
        let red   = CGFloat((hex & 0xFF0000) >> 16)/256.0
        let green = CGFloat((hex & 0xFF00) >> 8)/256.0
        let blue  = CGFloat(hex & 0xFF)/256.0
        return UIColor(red: red, green: green, blue: blue, alpha: CGFloat(alpha))
    }
}



class CalendarListViewModel: ObservableObject {
    @Published var daySelected: Int
    @Published var defaultDayIsSelected: Bool
    @Published var date = Date()
    
    @Published var currentIdx = 0

    lazy var thisWeekDays = Date().getThisWeekDays()
    
    init() {
        daySelected = Date().getWeekDay(date: Date())
        defaultDayIsSelected = true
    }
    
    func selectDay(_ dateIndex: Int) {
        defaultDayIsSelected = defaultDaySelected()
        daySelected = dateIndex
    }
    
    func dayIsSelected(_ dayIndex: Int) -> Bool {
        return daySelected == dayIndex
    }
    
    func defaultDaySelected() -> Bool {
        let todayIndex = Date().getWeekDay(date: Date())
        return daySelected == todayIndex
    }
}


struct WeekDates: Identifiable {
    let id: Int
    let weekDays: [WeekDay]
}








final class CalendarViewModel: NSObject, UIViewRepresentable, FSCalendarDelegate, ObservableObject, UIGestureRecognizerDelegate, FSCalendarDataSource {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Published var date = Date()
    @Published var month = Date()
    @Published var isSwipe = false
    @Published var dateIsTapped = false
    @Published var calendarPad: CGFloat = -230
    @Published var showCalendar = false
    @Published var scope: FSCalendarScope = .week
    
    var calendar: FSCalendar!
    
    func makeUIView(context: Context) -> UIView {
        let width: CGFloat = UIScreen.main.bounds.width - 40
        let frame: CGRect  = .init(x: 0, y: 0, width: width, height: 300)
                
        calendar = .init(frame: frame)
        self.calendar.dataSource = self
        self.calendar.delegate = self
        
        self.calendar.allowsMultipleSelection = false
        self.calendar.accessibilityIdentifier = "calendar"
        
        self.calendar.scope = .week
        calendar.firstWeekday = 2
        
        calendar.appearance.headerDateFormat = "MMMM"
        calendar.calendarHeaderView.isHidden = true
        calendar.headerHeight = 0
        
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 13)
        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 13)
        calendar.appearance.weekdayTextColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        calendar.appearance.caseOptions = .weekdayUsesSingleUpperCase
        
        calendar.appearance.titleDefaultColor = isDarkMode ? .white : .black
        calendar.appearance.todayColor = #colorLiteral(red: 1, green: 0.631372549, blue: 0.2901960784, alpha: 0.6461444405)
        calendar.appearance.selectionColor = #colorLiteral(red: 1, green: 0.631372549, blue: 0.2901960784, alpha: 1)
//        calendar.adjustMonthPosition()
        
//        calendar.scopeGesture.isEnabled = true
        calendar.swipeToChooseGesture.isEnabled = true
        let scopeGesture = UIPanGestureRecognizer(target: calendar, action: #selector(calendar.handleScopeGesture(_:)));
        scopeGesture.delegate = self
        calendar.addGestureRecognizer(scopeGesture)
        
        return calendar
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let currentMonth = calendar.currentPage
        self.month = currentMonth
        
        if calendar.scope == .week {
            let todayWeekIndex = Date().getWeekDay(date: Date())
            self.date = currentMonth.getNextDay(date: currentMonth, todayWeekIndex)
            calendar.select(self.date)
        }
        self.isSwipe.toggle()
        print("Current date: \(self.date)")
    }
        
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        self.date = date
        self.dateIsTapped.toggle()
        
        print("Day selected: \(dateFormatter.string(from: self.date))")
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

extension CalendarViewModel {
    
    func calendar(_ calendar: FSCalendar, _ calendarCurrentScopeWillChange: FSCalendarScope, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendar.frame.size.height = bounds.height
        self.calendarPad = -(270-bounds.height) + 10
        self.calendar.layoutIfNeeded()
        
        print("HEIGHT: \(calendar.frame.size.height)")
        print("FRAME: \(calendar.frame)")
        print("PAD: \(calendarPad)")
        print()
    }
}

extension CalendarViewModel {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        debugPrint("UIGestureRecognizer")
        
        return true
    }
}

