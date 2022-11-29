//
//  StatsViewModel.swift
//  TaskDo
//
//  Created by Philippe Yong on 30/01/2021.
//

import Foundation
import SwiftUI
import Combine

final class StatsViewModel: ObservableObject {
    private let userService: UserServiceProtocol
    private let statsService: StatsServiceProtocol
    private var cancellables: [AnyCancellable] = []
    
    private let today = Date()
    
    @Published var error: TaskDoError?
    @Published var statsListViewModels: [StatsItemViewModel] = []
    
    @Published var isLoading = true
    @Published var totalFocusTimeList = [0, 0, 0]
    @Published var graphBarDataList: [[Int]] = [[],[],[]]
    @Published var graphLineDataList: [[Int]] = [[3, 2, 1, 0], [3, 2, 1, 0], [3, 2, 1, 0]]
    @Published var maxFocusTimeList: [Int] = [0, 0, 0]
    @Published var lineUnit: [String] = ["m", "m", "m"]
    @Published var timeDistributionList: [[Int]] = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
    @Published var focusedTaskList: [FocusedTaskItems] = []
    @Published var selectedDataIndex = 0
    @Published var focusTimeAvr = 0
    @Published var monFocusTimeAvr = 0
        
    @Published var currentDate = Date()
    @Published var weekFocusTimeCompare = 0
    @Published var weekFocusTimeCompareBool = true
    @Published var weekFocusTimeComparePrecentage = 0
    
    @Published var monthFocusTimeCompare = 0
    @Published var monthFocusTimeCompareBool = true
    @Published var monthFocusTimeComparePercentage = 0
    
    @Published var weekGraphBarData: [WeekGraphData] = []
    @ObservedObject var statsDataViewModel = StatsDataViewModel()
    
    @Published var weekPointer = 0
    @Published var selectedWeekDates: [Date] = Date().getThisWeekDates()
    @Published var monthPointer = 0
        
    let tagOptions: [Tags] = [
        Tags(title: "Study", imageName: "book.fill", color: Color(#colorLiteral(red: 0.9803921569, green: 0.3921568627, blue: 0.262745098, alpha: 1)), type: .study),
        Tags(title: "Work", imageName: "desktopcomputer", color: Color(#colorLiteral(red: 0.262745098, green: 0.7215686275, blue: 0.9803921569, alpha: 1)), type: .work),
        Tags(title: "Exercise", imageName: "exercise", color: Color(#colorLiteral(red: 0.9803921569, green: 0.5215686275, blue: 0.262745098, alpha: 1)), type: .exercise),
        Tags(title: "Fun", imageName: "gamecontroller.fill", color: Color(#colorLiteral(red: 0.9803921569, green: 0.8196078431, blue: 0.262745098, alpha: 1)), type: .fun),
        Tags(title: "Productivity", imageName: "bookmark.fill", color: Color(#colorLiteral(red: 0.09411764706, green: 0.937254902, blue: 0.7843137255, alpha: 1)), type: .productivity),
        Tags(title: "Others", imageName: "circle", color: Color(#colorLiteral(red: 0.8196078431, green: 0.5411764706, blue: 0.9921568627, alpha: 1)), type: .others)
    ]
    
    let dataOptions = ["D", "W", "M"]
    
    init(
        userService: UserServiceProtocol = UserService(),
        statsService: StatsServiceProtocol = StatsService()
    ) {
        self.userService = userService
        self.statsService = statsService
        self.statsListViewModels = []
        self.monthPointer = Int(self.getFormattedDateX(Date())) ?? 0
        
        print("STATS VIEW MODEL IS INIT")
        

        observeStats { completion in
            print("Observing stats")
            
            if completion {
                self.getRecord()
                self.focusedTaskList.sort { $0.date < $1.date }
                self.getTotalFocusTime()
                
                var weekday = Calendar.current.component(.weekday, from: Date())
                weekday = Date().getWeekDateIndex(weekday) + 1
                self.getFocusTimeAvr(weekday)
                
                self.getWeekFocusTimeCompare()
                self.getMonFocusTimeAvr()
                self.getMonFocusTimeCompare()
                
                for i in 0..<3 {
                    self.getGraphLineDataList(i)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.isLoading = false
                }
            }
        }
    }
    
    enum Selection {
        case day
        case week
        case month
    }
    
    func send(_ selection: Selection) {
        switch selection {
        case .day:
            selectData(0)
        case .week:
            selectData(1)
        case .month:
            selectData(2)
        }
    }
    
    private func observeStats(completion: @escaping (Bool) -> Void) {
        userService.currentUserPublisher()
            .compactMap { $0?.uid }
            .flatMap { [weak self] userId -> AnyPublisher<[Stats], TaskDoError> in
                guard let self = self else { return Fail(error: .default()).eraseToAnyPublisher() }
                return self.statsService.observeChallenges(userId: userId)
            }
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case let .failure(error):
                    self.error = error
                case .finished:
                    self.statsListViewModels = []
                    print("finished")
                }
            } receiveValue: { [weak self] stats in
                guard let self = self else { return }
                self.error = nil
                self.statsListViewModels = []
//                let ar = stats.map { $0 }
                print("OBSERVING STATS")
//                for x in ar {
//                    print(x)
//                    print()
//                }
                print("Stats list count before: \(self.statsListViewModels.count)")
                self.statsListViewModels = stats.map { statsItem in
                    .init(statsItem)
                }
                print("Stats list count after: \(self.statsListViewModels.count)")
                completion(true)
            }.store(in: &cancellables)
    }
}

extension StatsViewModel {
    private func getTotalFocusTime() {
        totalFocusTimeList[0] = graphBarDataList[0].reduce(0, +)
        totalFocusTimeList[1] = graphBarDataList[1].reduce(0, +)
        totalFocusTimeList[2] = weekGraphBarData.map { $0.focusTime }.reduce(0, +)
    }
    
    private func getRecord() {
        for _ in 0..<24 {
            graphBarDataList[0].append(0)
        }
        
        for _ in 0..<7 {
            graphBarDataList[1].append(0)
        }
        
        for date in Date().getThisMonthDates() {
            weekGraphBarData.append(WeekGraphData(date: date, focusTime: 0))
        }
                
        for stats in statsListViewModels {
            for index in stats.record.indices {
                var taskStartDate = Date()
                if stats.record[index].focusRecord.count > 0 {
                taskStartDate = stats.record[index].focusRecord[0].date
                }
                let focusRecord = stats.record[index].focusRecord
                let focusTime = stats.record[index].focusRecord.map { $0.focusTime }.reduce(0, +)
                
                // day
                if getFormattedDateII(taskStartDate) == getFormattedDateII(today) {
                    for record in focusRecord {
                        let focusTime = record.focusTime
                        let hrIndex = Int(getFormattedDate(record.date))!
                        let timeMin = Int(getFormattedDateVIII(record.date))!*60
                        var j = hrIndex
                        
                        if (timeMin+focusTime > 3600) {
                            let total = timeMin + focusTime
                            let hi = timeMin + focusTime - 3600
                            let wi = total - timeMin - hi
                            graphBarDataList[0][j] += wi
                            var extraTime = hi
                            j = j+1
                            
                            while extraTime > 0 && (j<=22 && j>1) {
                                print("DATA AT HR INDEX: \(j): \(graphBarDataList[0][j])")
                                graphBarDataList[0][j] += extraTime
                                if graphBarDataList[0][j] > 3600 {
                                    extraTime = graphBarDataList[0][j] - 3600
                                    graphBarDataList[0][j] = 3600
                                    j += 1
                                    continue
                                }
                                else {
                                    break
                                }
                            }
                        }
                        else {
                            graphBarDataList[0][j] += focusTime
                        }
                    }
                    
                    focusedTaskList.append(FocusedTaskItems(taskTitle: stats.taskTitle, taskColorIndex: stats.taskColorIndex, date: taskStartDate, focusTime: focusTime))
                    timeDistributionList[0][stats.record[index].selectedTagIndex] += focusTime
                }
                
                // week
                let weekDates = self.selectedWeekDates.map { getFormattedDateII($0) }
                var weekday = Calendar.current.component(.weekday, from: taskStartDate)
                weekday = Date().getWeekDateIndex(weekday)
                if weekDates.contains(getFormattedDateII(taskStartDate)) {
                    graphBarDataList[1][weekday] += focusTime
                    timeDistributionList[1][stats.record[index].selectedTagIndex] += focusTime
                }
                
                // month
                let monthDate = getFormaattedDateIV(Date())
                if getFormaattedDateIV(taskStartDate) == monthDate {
                    weekGraphBarData[Int(getFormaattedDateV(taskStartDate))!-1].focusTime += focusTime
                    timeDistributionList[2][stats.record[index].selectedTagIndex] += focusTime
                }
            }
        }
        
        for i in 0..<2 {
            maxFocusTimeList[i] = graphBarDataList[i].max()!
        }
        maxFocusTimeList[2] = weekGraphBarData.map{ $0.focusTime }.max()!
    }
    
    private func getGraphLineDataList(_ index: Int) {
        if maxFocusTimeList[index] > 180 {
            graphLineDataList[index] = [60, 40, 20, 0]
            lineUnit[index] = "m"
        }
    }
    
    private func getFocusTimeAvr(_ n: Int) {
        let weekFocusTime = graphBarDataList[1].reduce(0, +)
        let avr = Double(weekFocusTime) / Double(n)
        focusTimeAvr = Int(avr)
    }
    
    private func getMonFocusTimeAvr() {
        let monFocusTime = totalFocusTimeList[2]
        let monthDay = getFormaattedDateV(Date())
        let selectedMonth = getFormattedDateX(Date())
        var monthDayIndex = 0
        print("month pointer: \(monthPointer), \(monthDay)")
        if "\(monthPointer<10 ? "0\(monthPointer)" : "\(monthPointer)")" == selectedMonth {
            monthDayIndex = Int(monthDay) ?? 1 - 1
        }
        else {
            monthDayIndex = weekGraphBarData.count
        }
        if monthDayIndex > 0 {
            let avr = Double(monFocusTime) / Double(monthDayIndex)
            monFocusTimeAvr = Int(avr)
        }
        else {
            monFocusTimeAvr = 0
        }
    }
    
    public func getSelectedDayData() {
        graphBarDataList[0] = []
        for _ in 0..<24 {
            graphBarDataList[0].append(0)
        }
        focusedTaskList = []
        timeDistributionList[0] = [0, 0, 0, 0, 0, 0]
        
        for stats in statsListViewModels {
            for index in stats.record.indices {
                var taskStartDate = Date()
                if stats.record[index].focusRecord.count > 0 {
                taskStartDate = stats.record[index].focusRecord[0].date
                }
                let focusRecord = stats.record[index].focusRecord
                let focusTime = stats.record[index].focusRecord.map { $0.focusTime }.reduce(0, +)
                
                if getFormattedDateII(taskStartDate) == getFormattedDateII(currentDate) {
                    for record in focusRecord {
                        let focusTime = record.focusTime
                        let hrIndex = Int(getFormattedDate(record.date))!
                        let timeMin = Int(getFormattedDateVIII(record.date))!*60
                        var j = hrIndex
                        var extraTime = focusTime

                        if (graphBarDataList[0][j]+focusTime > 3600) || (focusTime > 3600) {
                            graphBarDataList[0][j] += focusTime
                            while ((graphBarDataList[0][j]+extraTime > 3600) || (extraTime > 3600)) && (j<=22 && j>1) {
                                if extraTime + timeMin > 3600 {
                                    graphBarDataList[0][j] -= (3600 - timeMin)
                                    extraTime = extraTime - (3600 - timeMin)
                                    j += 1
                                    graphBarDataList[0][j] += extraTime
                                }
                                else {
                                    extraTime = graphBarDataList[0][j] - 3600
                                    graphBarDataList[0][j] -= extraTime
                                    j += 1
                                    graphBarDataList[0][j] += extraTime
                                }
                            }
                        }
                        else {
                            graphBarDataList[0][j] += focusTime
                        }
                    }
                    
                    focusedTaskList.append(FocusedTaskItems(taskTitle: stats.taskTitle, taskColorIndex: stats.taskColorIndex, date: taskStartDate, focusTime: focusTime))
                    timeDistributionList[0][stats.record[index].selectedTagIndex] += focusTime
                }
            }
        }
        totalFocusTimeList[0] = graphBarDataList[0].reduce(0, +)
        maxFocusTimeList[0] = graphBarDataList[0].max()!
        getGraphLineDataList(0)
    }
    
    public func getSelectedWeekData() {
        graphBarDataList[1] = []
        for _ in 0..<7 {
            graphBarDataList[1].append(0)
        }
        timeDistributionList[1] = [0, 0, 0, 0, 0, 0]
        
        self.selectedWeekDates = Date().getSelectedWeekDates(n: self.weekPointer)
        let weekDates = self.selectedWeekDates.map { getFormattedDateII($0) }
        
        for stats in statsListViewModels {
            for index in stats.record.indices {
                var taskStartDate = Date()
                if stats.record[index].focusRecord.count > 0 {
                taskStartDate = stats.record[index].focusRecord[0].date
                }
                let focusTime = stats.record[index].focusRecord.map { $0.focusTime }.reduce(0, +)
                var weekday = Calendar.current.component(.weekday, from: taskStartDate)
                weekday = Date().getWeekDateIndex(weekday)
                if weekDates.contains(getFormattedDateII(taskStartDate)) {
                    graphBarDataList[1][weekday] += focusTime
                    timeDistributionList[1][stats.record[index].selectedTagIndex] += focusTime
                }
            }
        }
        totalFocusTimeList[1] = graphBarDataList[1].reduce(0, +)
        maxFocusTimeList[1] = graphBarDataList[1].max()!
        getGraphLineDataList(1)
        getFocusTimeAvr(7)
        getWeekFocusTimeCompare()
    }
    
    public func getSelectedMonth(_ n: Int) {
        self.monthPointer += n
        self.monthPointer%=12
    }

    public func getSelectedMonthData() {
        func getDateFromFormatted(_ str: String) -> Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM"
            let date = dateFormatter.date(from: str)
            return date ?? Date()
        }
        weekGraphBarData = []
        
        let yearDate = getFormattedDateXI(Date())
        let monthDate = "\(monthPointer<10 ? "0\(monthPointer)" : "\(monthPointer)") \(yearDate)"
        for date in 1..<Date().getSelectedMonthDates(monthPointer, Int(yearDate)!)+1 {
            let strDate = "\(date < 10 ? "0\(date)" : "\(date)")/\(monthPointer<10 ? "0\(monthPointer)" : "\(monthPointer)")"
            weekGraphBarData.append(WeekGraphData(date: getDateFromFormatted(strDate), focusTime: 0))
        }
        timeDistributionList[2] = [0, 0, 0, 0, 0, 0]
        
        print("THIS MONTH: \(monthDate)")
        
        for stats in statsListViewModels {
            for index in stats.record.indices {
                var taskStartDate = Date()
                if stats.record[index].focusRecord.count > 0 {
                taskStartDate = stats.record[index].focusRecord[0].date
                }
                let focusTime = stats.record[index].focusRecord.map { $0.focusTime }.reduce(0, +)
                print(getFormaattedDateXII(taskStartDate))
                if getFormaattedDateXII(taskStartDate) == monthDate {
                    // error here
                    weekGraphBarData[Int(getFormaattedDateV(taskStartDate))!-1].focusTime += focusTime
                    timeDistributionList[2][stats.record[index].selectedTagIndex] += focusTime
                }
            }
        }
        
        maxFocusTimeList[2] = weekGraphBarData.map{ $0.focusTime }.max()!
        totalFocusTimeList[2] = weekGraphBarData.map { $0.focusTime }.reduce(0, +)
        
        // TODO: Insert monthPointer to focus time avr func
        getMonFocusTimeAvr()
        
        if "\(monthPointer < 10 ? "0\(monthPointer)" : "\(monthPointer)")" == getFormattedDateX(Date()) {
            getMonFocusTimeCompare()
        }
        else {
            getSelectedMonFocusTimeCompare()
        }
    }
    
    private func getWeekFocusTimeCompare() {
        var weekday = Calendar.current.component(.weekday, from: Date())
        weekday = Date().getWeekDateIndex(weekday)
        
        let startOfWeek = self.selectedWeekDates[0]
        let lastSunday = Date().getNextDay(date: startOfWeek, -1)
        let lastWeekDates = Date().getWeekDates(lastSunday)
        var lastWeekDatesAr: [Date] = []
        
        if weekPointer == 0 {
            for i in 0..<weekday+1 {
                lastWeekDatesAr.append(lastWeekDates[i])
            }
        }
        else {
            for i in 0..<7 {
                lastWeekDatesAr.append(lastWeekDates[i])
            }
        }
        
        let lastWeekDatesStr = lastWeekDatesAr.map { getFormattedDateII($0) }
        
        print("LAST WEEK DATES: \(lastWeekDatesStr)")
        
        let thisWeekFocusTime = totalFocusTimeList[1]
        var lastWeekFocusTime = 0
        
        for stats in statsListViewModels {
            for index in stats.record.indices {
                var taskStartDate = Date()
                if stats.record[index].focusRecord.count > 0 {
                    taskStartDate = stats.record[index].focusRecord[0].date
                    if lastWeekDatesStr.contains(getFormattedDateII(taskStartDate)) {
                        let focusTime = stats.record[index].focusRecord.map { $0.focusTime }.reduce(0, +)
                        lastWeekFocusTime += focusTime
                    }
                }
            }
        }
        
        print("LAST WEEK FOCUS TIME: \(lastWeekFocusTime)")
        print("THIS WEEK FOCUS TIME: \(thisWeekFocusTime)")
        
        if thisWeekFocusTime < lastWeekFocusTime {
            weekFocusTimeCompareBool = false
        }
        else {
            weekFocusTimeCompareBool = true
        }
        weekFocusTimeCompare = abs(thisWeekFocusTime - lastWeekFocusTime)
        print()
        print("Week compare ====")
        print(weekFocusTimeCompare, thisWeekFocusTime)
        print(Double(weekFocusTimeCompare)/Double(lastWeekFocusTime))
        if lastWeekFocusTime > 0 {
            weekFocusTimeComparePrecentage = Int(Double(weekFocusTimeCompare)/Double(lastWeekFocusTime)*100)
        }
        else {
            weekFocusTimeComparePrecentage = 100
        }
    }
        
    private func getMonFocusTimeCompare() {
        let monthDay = getFormaattedDateV(Date())
        let monthDayIndex = Int(monthDay) ?? 1 - 1
        print("MONTH DAY INDEX: \(monthDayIndex)")
        
        let thisMonth = getFormattedDateX(Date())
        let lastMonth = Int(thisMonth)! - 1
        var lastMonthFormattedAr: [String] = []
        
        for i in 1..<monthDayIndex+1 {
            var day = "\(i)"
            if i < 10 {
                day = "0\(i)"
            }
            var month = "\(lastMonth)"
            if lastMonth < 10 {
                month = "0\(lastMonth)"
            }
            let date = "\(day).\(month).\(getFormattedDateXI(Date()))"
            lastMonthFormattedAr.append(date)
        }
        
        let thisMonthFocusTime = totalFocusTimeList[2]
        var lastMonthFocusTime = 0
        
        print("COMPARE MONTH DATES: \(lastMonthFormattedAr)")
        
        for stats in statsListViewModels {
            for index in stats.record.indices {
                var taskStartDate = Date()
                if stats.record[index].focusRecord.count > 0 {
                    taskStartDate = stats.record[index].focusRecord[0].date
                }
                let focusTime = stats.record[index].focusRecord.map { $0.focusTime }.reduce(0, +)
                if lastMonthFormattedAr.contains(getFormattedDateII(taskStartDate)) {
                    lastMonthFocusTime += focusTime
                }
            }
        }
        
        print("LAST WEEK FOCUS TIME: \(lastMonthFocusTime)")
        print("THIS WEEK FOCUS TIME: \(thisMonthFocusTime)")
        
        if thisMonthFocusTime < lastMonthFocusTime {
            monthFocusTimeCompareBool = false
        }
        
        print("Month comparison =========")
        print(thisMonth, thisMonthFocusTime)
        print(lastMonth, lastMonthFocusTime)
        
        monthFocusTimeCompare = abs(thisMonthFocusTime - lastMonthFocusTime)
        if lastMonthFocusTime > 0{
            monthFocusTimeComparePercentage = Int(Double(monthFocusTimeCompare)/Double(lastMonthFocusTime)*100)
        }
        else {
            monthFocusTimeComparePercentage = 100
        }
        print((monthFocusTimeCompare))
    }
    
    private func getSelectedMonFocusTimeCompare() {
        let yearDate = getFormattedDateXI(Date())
        let selectedMonthDate = "\(monthPointer < 10 ? "0\(monthPointer)" : "\(monthPointer)") \(yearDate)"
        let lastSelectedMonthDate = "\(monthPointer-1 < 10 ? "0\(monthPointer-1)" : "\(monthPointer-1)") \(yearDate)"
        
        var selectedMonthFocusTime = 0
        var lastSelectedMonthFocusTime = 0
        
        for stats in statsListViewModels {
            for index in stats.record.indices {
                var taskStartDate = Date()
                if stats.record[index].focusRecord.count > 0 {
                    taskStartDate = stats.record[index].focusRecord[0].date
                }
                if getFormaattedDateXII(taskStartDate) == selectedMonthDate {
                    let focusTime = stats.record[index].focusRecord.map { $0.focusTime }.reduce(0, +)
                    selectedMonthFocusTime += focusTime
                }
                else if getFormaattedDateXII(taskStartDate) == lastSelectedMonthDate {
                    let focusTime = stats.record[index].focusRecord.map { $0.focusTime }.reduce(0, +)
                    lastSelectedMonthFocusTime += focusTime
                }
            }
        }
        
        if selectedMonthFocusTime < lastSelectedMonthFocusTime {
            monthFocusTimeCompareBool = false
        }
        
        print()
        print("Month comparison =========")
        print(selectedMonthDate, selectedMonthFocusTime)
        print(lastSelectedMonthDate, lastSelectedMonthFocusTime)
        
        monthFocusTimeCompare = abs(selectedMonthFocusTime - lastSelectedMonthFocusTime)
        if lastSelectedMonthFocusTime > 0 && selectedMonthFocusTime > 0 {
            monthFocusTimeComparePercentage = Int(Double(monthFocusTimeCompare)/Double(selectedMonthFocusTime)*100)
        }
        else {
            monthFocusTimeComparePercentage = 100
        }
        print(monthFocusTimeCompare)
    }
}

extension StatsViewModel {
    public func getFormattedTime(_ sec: Int) -> String {
        var hour = 0
        var min = sec/60
        
        while min >= 60 {
            min -= 60
            hour += 1
        }
        
        var str = ""
        
        if hour > 0 {
            str = "\(hour) hr \(min) min"
        }
        else {
            str = "\(min) min"
        }
                
        return str
    }
    
    public func getFormattedTimeII(_ sec: Int) -> String {
        var hour = 0
        var min = sec/60
        
        while min >= 60 {
            min -= 60
            hour += 1
        }
        
        var str = ""
        
        if hour > 0 {
            str = "\(hour) h"
        }
        else {
            str = "\(min) m"
        }
                
        return str
    }
    
    public func getPercentage(_ dataIndex: Int, _ upperBound: Int, sec: Int) -> Int {
        if upperBound > 0 && totalFocusTimeList[dataIndex] > 0 {
            return Int((Double(sec)/Double(totalFocusTimeList[dataIndex])*100).rounded(.toNearestOrAwayFromZero))
        }
        else {
            return 0
        }
    }
    
    private func getFormattedDate(_ date: Date) -> String {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = "H"
        
        return formattedDate.string(from: date)
    }
    
    public func getFormattedDateII(_ date: Date) -> String {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = "dd.MM.yyyy"
        
        return formattedDate.string(from: date)
    }
    
    public func getFormattedDateIII(_ date: Date) -> String {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = "h:mm a"
        
        return formattedDate.string(from: date)
    }
    
    public func getFormaattedDateIV(_ date: Date) -> String {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = "MMMM yyyy"
        
        return formattedDate.string(from: date)
    }
    
    public func getFormaattedDateV(_ date: Date) -> String {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = "dd"
        
        return formattedDate.string(from: date)
    }
    
    public func getFormattedDateVI(_ date: Date) -> String {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = "hh:mm"
        
        return formattedDate.string(from: date)
    }

    public func getFormattedDateVII(_ date: Date) -> String {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = "dd.MM"
        
        return formattedDate.string(from: date)
    }
    
    public func getFormattedDateVIII(_ date: Date) -> String {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = "mm"
        
        return formattedDate.string(from: date)
    }

    public func getFormattedDateIX(_ n: Int) -> String {
        var str = ""
        let month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        if n%12 == 0 {
            str = month[11]
        }
        else if (n%12)-1 < 0 {
            str = month[0]
        }
        else {
            str = month[(n%12)-1]
        }
        return str
    }
    
    public func getFormattedDateX(_ date: Date) -> String {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = "MM"
        
        return formattedDate.string(from: date)
    }
    
    public func getFormattedDateXI(_ date: Date) -> String {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = "yyyy"
        
        return formattedDate.string(from: date)
    }
    
    public func getFormaattedDateXII(_ date: Date) -> String {
        let formattedDate = DateFormatter()
        formattedDate.dateFormat = "MM yyyy"
        
        return formattedDate.string(from: date)
    }

        
    public func getFormattedTaskFocusTime(_ sec: Int) -> Int {
        return Int(Double(sec)/60)
    }
    
    public func getWeekDay(_ idx: Int) -> String {
        return Date.weekdays[idx].uppercased()
    }
}

extension StatsViewModel {
    public func selectData(_ index: Int) {
        selectedDataIndex = index
    }
}

extension StatsViewModel {
    public func getDayBarHeight(_ sec: Int) -> CGFloat {
        var res: CGFloat = 0
        // Prevent error
        if sec>3600 {
            res = 170
        }
        else {
            res = CGFloat(Double(sec)/Double(graphLineDataList[0][0]*60)*170)
        }
        return res
    }
    
    public func getWeekBarHeight(_ sec: Int) -> CGFloat {
        return CGFloat(Double(sec)/Double(maxFocusTimeList[1])*170)
    }
    
    public func getMonthBarHeight(_ sec: Int) -> CGFloat {
        return CGFloat(Double(sec)/Double(maxFocusTimeList[2])*180)
    }
}

struct FocusedTaskItems: Hashable {
    var taskTitle: String
    var taskColorIndex: Int
    var date: Date
    var focusTime: Int
}

struct WeekGraphData: Hashable {
    var date: Date
    var focusTime: Int
}
