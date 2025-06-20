//
//  CalendarModel.swift
//  Calendar
//
//  Created by Rhyse Summers on 10/06/2025.
//

import SwiftUI
import Foundation

/// A type-safe representation of the different calendar views.
/// CaseIterable allows us to easily use it in a Picker.
enum CalendarScope: String, CaseIterable {
    case month = "Month"
    case week = "Week"
    case day = "Day"
}

/// Represents a single day in the calendar grid.
struct CalendarDay: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let isInCurrentMonth: Bool
}
