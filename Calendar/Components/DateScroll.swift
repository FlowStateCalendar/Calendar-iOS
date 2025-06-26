//
//  DateScroll.swift
//  Calendar
//
//  Created by Rhyse Summers on 10/06/2025.
//

import SwiftUI

/// Enum for selector mode
enum DateSelectorMode {
    case month, week, day
}

/// Protocol for selectable date items
protocol DateSelectable: Hashable, Identifiable {
    var label: String { get }
    var isToday: Bool { get }
    var date: Date { get }
}

/// Example implementation for month, week, day items
struct MonthItem: DateSelectable {
    let id = UUID()
    let date: Date
    let label: String
    let isToday: Bool
}
struct WeekItem: DateSelectable {
    let id = UUID()
    let date: Date
    let label: String
    let isToday: Bool
}
struct DayItem: DateSelectable {
    let id = UUID()
    let date: Date
    let label: String
    let isToday: Bool
}

struct HorizontalDateSelector<Item: DateSelectable>: View {
    let mode: DateSelectorMode
    let items: [Item]
    let selected: Item
    let onSelect: (Item) -> Void
    let onToday: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(items) { item in
                            Button(action: {
                                onSelect(item)
                            }) {
                                VStack {
                                    Circle()
                                        .fill(item.isToday ? Color.red.opacity(0.8) : (item == selected ? Color.accentColor : Color(.systemGray5)))
                                        .frame(width: 48, height: 48)
                                        .overlay(
                                            Text(item.label)
                                                .foregroundColor(item.isToday || item == selected ? .white : .primary)
                                                .font(.headline)
                                        )
                                    if item.isToday {
                                        Text("Today")
                                            .font(.caption2)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .id(item.id)
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    // Scroll to selected on appear
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo(selected.id, anchor: .center)
                    }
                }
                .onChange(of: selected.id) {
                    // Scroll to selected when changed
                    withAnimation {
                        proxy.scrollTo(selected.id, anchor: .center)
                    }
                }
            }
            Button(action: onToday) {
                Text("Today")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.accentColor))
                    .foregroundColor(.white)
            }
            .padding(.top, 4)
        }
    }
}

// Example preview for days
#Preview {
    let today = Date()
    let calendar = Calendar.current
    let days = (0..<31).map { offset -> DayItem in
        let date = calendar.date(byAdding: .day, value: offset - 15, to: today)!
        return DayItem(date: date, label: DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .none), isToday: calendar.isDateInToday(date))
    }
    return HorizontalDateSelector(mode: .day, items: days, selected: days[15], onSelect: { _ in }, onToday: {})
}
