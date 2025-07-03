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
    
    @Published var currentDate = Date()
    @Published var scope: CalendarScope = .month
    
    // MARK: - Event Caching
    private var eventCache: [String: [EventModel]] = [:]
    private var lastCacheUpdate: Date = Date.distantPast
    private let cacheValidityDuration: TimeInterval = 300 // 5 minutes
    
    // MARK: - Smart Date Range Management
    private var lastRequestedDateRange: DateInterval?
    private let maxCacheSize = 50 // Maximum number of cached date ranges
    
    // MARK: - Cache Management
    private func getCacheKey(for dateRange: DateInterval) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(formatter.string(from: dateRange.start))_\(formatter.string(from: dateRange.end))"
    }
    
    private func isCacheValid() -> Bool {
        return Date().timeIntervalSince(lastCacheUpdate) < cacheValidityDuration
    }
    
    private func clearCache() {
        eventCache.removeAll()
        lastCacheUpdate = Date.distantPast
    }
    
    private func updateCache() {
        lastCacheUpdate = Date()
    }
    
    /// Manages cache size by removing oldest entries when limit is reached
    private func manageCacheSize() {
        if eventCache.count > maxCacheSize {
            // Remove oldest cache entries (simple FIFO approach)
            let keysToRemove = Array(eventCache.keys.prefix(eventCache.count - maxCacheSize))
            for key in keysToRemove {
                eventCache.removeValue(forKey: key)
            }
        }
    }
    
    /// Pre-generates events for common date ranges to improve performance
    private func pregenerateCommonRanges(for tasks: [TaskModel]) {
        let calendar = Calendar.current
        let today = Date()
        
        // Pre-generate for current week, next week, current month, next month
        let commonRanges = [
            calendar.dateInterval(of: .weekOfYear, for: today) ?? DateInterval(start: today, duration: 7 * 24 * 3600),
            calendar.dateInterval(of: .weekOfYear, for: calendar.date(byAdding: .weekOfYear, value: 1, to: today) ?? today) ?? DateInterval(start: today, duration: 7 * 24 * 3600),
            calendar.dateInterval(of: .month, for: today) ?? DateInterval(start: today, duration: 30 * 24 * 3600),
            calendar.dateInterval(of: .month, for: calendar.date(byAdding: .month, value: 1, to: today) ?? today) ?? DateInterval(start: today, duration: 30 * 24 * 3600)
        ]
        
        for range in commonRanges {
            let cacheKey = getCacheKey(for: range)
            if eventCache[cacheKey] == nil {
                // Generate events for this range in background
                DispatchQueue.global(qos: .utility).async { [weak self] in
                    let events = self?.generateEventsFromTasksInternal(tasks, for: range) ?? []
                    DispatchQueue.main.async {
                        self?.eventCache[cacheKey] = events
                        self?.manageCacheSize()
                    }
                }
            }
        }
    }
    
    /// Internal method for generating events (without caching logic)
    private func generateEventsFromTasksInternal(_ tasks: [TaskModel], for dateRange: DateInterval) -> [EventModel] {
        var events: [EventModel] = []
        let calendar = Calendar.current
        
        for task in tasks {
            switch task.frequency {
            case .none:
                if dateRange.contains(task.taskDate) {
                    events.append(EventModel(from: task, scheduledDate: task.taskDate))
                }
                
            case .daily:
                var currentDate = dateRange.start
                while currentDate < dateRange.end {
                    if currentDate >= task.taskDate {
                        let eventDate = calendar.date(bySettingHour: calendar.component(.hour, from: task.taskDate),
                                                    minute: calendar.component(.minute, from: task.taskDate),
                                                    second: 0, of: currentDate) ?? currentDate
                        events.append(EventModel(from: task, scheduledDate: eventDate))
                    }
                    currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                }
                
            case .weekly:
                var currentDate = dateRange.start
                while currentDate < dateRange.end {
                    if currentDate >= task.taskDate {
                        let eventDate = calendar.date(bySettingHour: calendar.component(.hour, from: task.taskDate),
                                                    minute: calendar.component(.minute, from: task.taskDate),
                                                    second: 0, of: currentDate) ?? currentDate
                        events.append(EventModel(from: task, scheduledDate: eventDate))
                    }
                    currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) ?? currentDate
                }
                
            case .monthly:
                var currentDate = dateRange.start
                while currentDate < dateRange.end {
                    if currentDate >= task.taskDate {
                        let eventDate = calendar.date(bySettingHour: calendar.component(.hour, from: task.taskDate),
                                                    minute: calendar.component(.minute, from: task.taskDate),
                                                    second: 0, of: currentDate) ?? currentDate
                        events.append(EventModel(from: task, scheduledDate: eventDate))
                    }
                    currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                }
            }
        }
        
        return events.sorted { $0.scheduledDate < $1.scheduledDate }
    }
    
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
            calendar.dateInterval(of: .month, for: currentDate) != nil,
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
    
    // MARK: - Event Filtering Methods
    
    /// Converts tasks to events based on their frequency and generates recurring events
    /// Now with intelligent caching for better performance
    private func generateEventsFromTasks(_ tasks: [TaskModel], for dateRange: DateInterval) -> [EventModel] {
        let cacheKey = getCacheKey(for: dateRange)
        
        // Check if we have valid cached events for this date range
        if let cachedEvents = eventCache[cacheKey], isCacheValid() {
            return cachedEvents
        }
        
        // Generate events using internal method
        let sortedEvents = generateEventsFromTasksInternal(tasks, for: dateRange)
        
        // Cache the results
        eventCache[cacheKey] = sortedEvents
        updateCache()
        manageCacheSize()
        
        return sortedEvents
    }
    
    func fetchEventsForCurrentDate(from user: UserModel) -> [EventModel] {
        let startOfDay = calendar.startOfDay(for: currentDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        let dateRange = DateInterval(start: startOfDay, end: endOfDay)
        
        return generateEventsFromTasks(user.tasks, for: dateRange)
    }
    
    func fetchEventsForWeek(from user: UserModel) -> [EventModel] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: currentDate) else { return [] }
        return generateEventsFromTasks(user.tasks, for: weekInterval)
    }
    
    func fetchEventsForMonth(from user: UserModel) -> [EventModel] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else { return [] }
        return generateEventsFromTasks(user.tasks, for: monthInterval)
    }
    
    func getEventsForDate(_ date: Date, from user: UserModel) -> [EventModel] {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        let dateRange = DateInterval(start: startOfDay, end: endOfDay)
        
        return generateEventsFromTasks(user.tasks, for: dateRange)
    }
    
    // MARK: - Public Methods for Cache Management
    /// Call this when tasks are added, updated, or deleted
    func invalidateEventCache() {
        clearCache()
    }
    
    /// Call this when the user changes date or scope
    func refreshEventsIfNeeded() {
        if !isCacheValid() {
            clearCache()
        }
    }
    
    /// Initialize the calendar with pre-generated events for common ranges
    func initializeWithTasks(_ tasks: [TaskModel]) {
        pregenerateCommonRanges(for: tasks)
    }
}
