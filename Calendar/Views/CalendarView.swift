import SwiftUI

// MARK: - Day Model
struct CalendarDay: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let isInCurrentMonth: Bool
}

struct CalendarView: View {
    private let calendar = Calendar(identifier: .gregorian)
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    @State private var currentDate = Date()

    var body: some View {
        VStack(spacing: 16) {
            UserBar()
            // Month Title
            Text(currentDate.formatted(.dateTime.year().month()))
                .font(.title2)
                .bold()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(0..<20, id: \.self) { index in
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text("\(index + 1)")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            )
                    }
                }
                .padding(.horizontal)
            }
            
            HStack{
                Button("Day") {
                    print("Day press")
                }
                Spacer()
                Button("Week") {
                    print("Week press")
                }
                Spacer()
                Button("Month") {
                    print("Month press")
                }
            }
            .padding()
            
            // Day Labels
            let days = ["M", "T", "W", "T", "F", "S", "S"]
            VStack{
                HStack {
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.gray)
                    }
                }
                
                // Calendar Grid
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(generateDays(for: currentDate)) { day in
                        Text("\(calendar.component(.day, from: day.date))")
                            .frame(maxWidth: .infinity, minHeight: 36)
                            .padding(6)
                            .background(calendar.isDateInToday(day.date) ? Color.blue.opacity(0.2) : Color.clear)
                            .clipShape(Circle())
                            .foregroundColor(day.isInCurrentMonth ? .primary : .gray)
                    }
                }
                
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            
            AddTaskButton()
            
            Spacer()
        }
        .padding()
        .background(Color(.teal))
    }

    // MARK: - Generate Calendar Days
    private func generateDays(for date: Date) -> [CalendarDay] {
        guard
            let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
            let monthRange = calendar.range(of: .day, in: .month, for: firstOfMonth)
        else { return [] }

        var days: [CalendarDay] = []

        // Determine the weekday of the first day (adjusted for Monday start)
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingEmptyDays = (weekday + 5) % 7

        // Previous month days
        if let previousMonth = calendar.date(byAdding: .month, value: -1, to: firstOfMonth),
           let previousRange = calendar.range(of: .day, in: .month, for: previousMonth),
           let start = calendar.date(from: calendar.dateComponents([.year, .month], from: previousMonth)) {
            let prevDays = previousRange.count
            for i in (prevDays - leadingEmptyDays + 1)...prevDays {
                if let day = calendar.date(byAdding: .day, value: i - 1, to: start) {
                    days.append(CalendarDay(date: day, isInCurrentMonth: false))
                }
            }
        }

        // Current month days
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(CalendarDay(date: date, isInCurrentMonth: true))
            }
        }

        // Next month days to fill 42 slots
        let remaining = 42 - days.count
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstOfMonth),
           let start = calendar.date(from: calendar.dateComponents([.year, .month], from: nextMonth)) {
            for i in 0..<remaining {
                if let date = calendar.date(byAdding: .day, value: i, to: start) {
                    days.append(CalendarDay(date: date, isInCurrentMonth: false))
                }
            }
        }

        return days
    }
}


#Preview {
    CalendarView()
}
