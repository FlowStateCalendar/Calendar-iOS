//
//  CalendarViewModel.swift
//  Calendar
//
//  Created by Rhyse Summers on 10/06/2025.
//

import Foundation
import SwiftUI

class CalendarViewModel: ObservableObject {
    private let calendar = Calendar(identifier: .gregorian)
    private let sampleEvents = Event.sampleEvents
    
    @Published var currentDate = Date()
    @Published var scope: CalendarScope = .month
    
    // MARK: - Computed Properties for Titles
    
    var currentTitle: String {
        switch scope {
        case .day:
            return currentDate.formatted(.dateTime.weekday(.wide).day().month(.wide))
        case .week:
            let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: currentDate)!
            let startDate = weekInterval.start
            let endDate = weekInterval.end
            if calendar.isDate(startDate, equalTo: endDate, toGranularity: .month) {
                return "\(startDate.formatted(.dateTime.month(.wide)))"
            } else {
                return "\(startDate.formatted(.dateTime.month(.abbreviated))) - \(endDate.formatted(.dateTime.month(.abbreviated)))"
            }
        case .month:
            return currentDate.formatted(.dateTime.year().month(.wide))
        }
    }
    
    var weekDaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let firstDayIndex = calendar.firstWeekday - 1
        return Array(symbols[firstDayIndex...] + symbols[..<firstDayIndex])
    }
    
    // MARK: - Navigation
    
    func goToPrevious() {
        switch scope {
        case .day:
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        case .week:
            currentDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
        case .month:
            currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        }
    }
    
    func goToNext() {
        switch scope {
        case .day:
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        case .week:
            currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
        case .month:
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
        }
    }
    
    // MARK: - Data Generation
    
    func generateMonthDays() -> [CalendarDay] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: currentDate),
            let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)),
            let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth)
        else { return [] }

        // Find the first day of the week containing the first of the month
        let firstVisibleDay = calendar.dateInterval(of: .weekOfMonth, for: firstDayOfMonth)?.start ?? firstDayOfMonth
        // Find the last day of the week containing the last of the month
        let lastVisibleDay = calendar.dateInterval(of: .weekOfMonth, for: lastDayOfMonth)?.end ?? lastDayOfMonth

        var days: [CalendarDay] = []
        var date = firstVisibleDay
        while date < lastVisibleDay {
            let isInCurrentMonth = calendar.isDate(date, equalTo: currentDate, toGranularity: .month)
            days.append(CalendarDay(date: date, isInCurrentMonth: isInCurrentMonth))
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }
        return days
    }
    
    func generateWeekDays() -> [CalendarDay] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: currentDate) else { return [] }
        var days: [CalendarDay] = []
        calendar.enumerateDates(startingAfter: weekInterval.start, matching: DateComponents(hour: 0), matchingPolicy: .nextTime) { date, _, stop in
            guard let date = date else { return }
            if date >= weekInterval.end {
                stop = true
                return
            }
            days.append(CalendarDay(date: date, isInCurrentMonth: true))
        }
        return days
    }
    
    func fetchEventsForCurrentDate() -> [Event] {
        sampleEvents.filter { event in
            calendar.isDate(event.date, inSameDayAs: currentDate)
        }
    }
}
