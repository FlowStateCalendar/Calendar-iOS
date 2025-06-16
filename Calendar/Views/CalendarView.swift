import SwiftUI

// MARK: - Main Container View
struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            monthHeader
            
            Picker("Calendar Scope", selection: $viewModel.scope.animation()) {
                ForEach(CalendarScope.allCases, id: \.self) { scope in
                    Text(scope.rawValue).tag(scope)
                }
            }
            .pickerStyle(.segmented)
            
            // Switch between the different calendar views
            switch viewModel.scope {
            case .day:
                DayView(viewModel: viewModel)
            case .week:
                WeekView(viewModel: viewModel)
            case .month:
                MonthView(viewModel: viewModel)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    /// The header view that displays the current title and navigation buttons.
    private var monthHeader: some View {
        HStack {
            Button(action: viewModel.goToPrevious) {
                Image(systemName: "chevron.left")
                    .font(.headline)
            }
            Spacer()
            Text(viewModel.currentTitle)
                .font(.title2)
                .fontWeight(.semibold)
                .transition(.opacity.combined(with: .move(edge: .top)))
            Spacer()
            Button(action: viewModel.goToNext) {
                Image(systemName: "chevron.right")
                    .font(.headline)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Month View
struct MonthView: View {
    @ObservedObject var viewModel: CalendarViewModel
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack {
            HStack {
                ForEach(viewModel.weekDaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .frame(maxWidth: .infinity)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(viewModel.generateMonthDays()) { day in
                    dayCell(for: day)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 8)
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
    
    @ViewBuilder
    private func dayCell(for day: CalendarDay) -> some View {
        Text("\(Calendar.current.component(.day, from: day.date))")
            .frame(maxWidth: .infinity, minHeight: 36)
            .padding(.vertical, 4)
            .background(
                Calendar.current.isDateInToday(day.date) ?
                Circle().fill(Color.red.opacity(0.8)) :
                Calendar.current.isDate(day.date, inSameDayAs: viewModel.currentDate) ?
                Circle().fill(Color.blue.opacity(0.3)) : Circle().fill(Color.clear)
            )
            .foregroundColor(
                Calendar.current.isDateInToday(day.date) ? .white :
                day.isInCurrentMonth ? .primary : .secondary
            )
            .fontWeight(Calendar.current.isDateInToday(day.date) ? .bold : .regular)
            .onTapGesture {
                viewModel.currentDate = day.date
            }
    }
}

// MARK: - Week View
struct WeekView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                ForEach(viewModel.generateWeekDays()) { day in
                    VStack {
                        Text(day.date.formatted(.dateTime.weekday(.short)))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(day.date.formatted(.dateTime.day()))
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .frame(width: 36, height: 36)
                            .background(
                                Calendar.current.isDateInToday(day.date) ?
                                Circle().fill(Color.red.opacity(0.8)) :
                                Calendar.current.isDate(day.date, inSameDayAs: viewModel.currentDate) ?
                                Circle().fill(Color.blue.opacity(0.3)) : Circle().fill(Color.clear)
                            )
                            .foregroundColor(Calendar.current.isDateInToday(day.date) ? .white : .primary)
                    }
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        viewModel.currentDate = day.date
                    }
                }
            }
            
            // Placeholder for events in the week
            List {
                Text("Events for this week...")
                    .foregroundColor(.secondary)
            }
            .listStyle(.plain)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 8)
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
}

// MARK: - Day View
struct DayView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        List(viewModel.fetchEventsForCurrentDate()) { event in
            HStack {
                Circle()
                    .fill(event.color)
                    .frame(width: 10, height: 10)
                Text(event.title)
                Spacer()
                Text(event.date, style: .time)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .listStyle(.plain)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 8)
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
}

// MARK: - Preview
#Preview {
    CalendarView()
}
