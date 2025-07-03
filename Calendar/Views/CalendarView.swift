//
//  CalendarView.swift
//  Calendar
//
//  Created by Rhyse Summers on 10/06/2025.
//
//  Needs refactoring

import SwiftUI

// MARK: - Main Container View
struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @Namespace private var tabBarNamespace
    @EnvironmentObject var user: UserModel
    @State private var hasInitializedDate = false
    
    var body: some View {
        VStack {
            UserBar()
            switch viewModel.scope {
            case .month:
                HorizontalDateSelector(
                    mode: .month,
                    items: generateMonthItems(),
                    selected: generateMonthItems().first(where: { Calendar.current.isDate($0.date, equalTo: viewModel.currentDate, toGranularity: .month) }) ?? generateMonthItems()[12],
                    onSelect: { item in viewModel.currentDate = item.date },
                    onToday: { viewModel.currentDate = Date() }
                )
                .id(viewModel.currentDate)
            case .week:
                HorizontalDateSelector(
                    mode: .week,
                    items: generateWeekItems(),
                    selected: generateWeekItems().first(where: { Calendar.current.isDate($0.date, equalTo: viewModel.currentDate, toGranularity: .weekOfYear) }) ?? generateWeekItems()[52],
                    onSelect: { item in viewModel.currentDate = item.date },
                    onToday: { viewModel.currentDate = Date() }
                )
                .id(viewModel.currentDate)
            case .day:
                HorizontalDateSelector(
                    mode: .day,
                    items: generateDayItems(),
                    selected: generateDayItems().first(where: { Calendar.current.isDate($0.date, inSameDayAs: viewModel.currentDate) }) ?? generateDayItems()[15],
                    onSelect: { item in viewModel.currentDate = item.date },
                    onToday: { viewModel.currentDate = Date() }
                )
                .id(viewModel.currentDate)
            }
            
            // Custom tab bar for calendar scope
            HStack(spacing: 32) {
                ForEach(CalendarScope.allCases, id: \ .self) { scope in
                    Button(action: {
                        viewModel.scope = scope
                    }) {
                        VStack(spacing: 4) {
                            Text(scope.rawValue)
                                .font(.headline)
                                .fontWeight(viewModel.scope == scope ? .bold : .regular)
                                .foregroundColor(viewModel.scope == scope ? Color.accentColor : .secondary)
                            if viewModel.scope == scope {
                                Capsule()
                                    .fill(Color.accentColor)
                                    .frame(height: 3)
                                    .matchedGeometryEffect(id: "underline", in: tabBarNamespace)
                            } else {
                                Capsule()
                                    .fill(Color.clear)
                                    .frame(height: 3)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical, 8)
            
            // Switch between the different calendar views
            switch viewModel.scope {
            case .day:
                DayView(viewModel: viewModel)
            case .week:
                WeekView(viewModel: viewModel)
            case .month:
                MonthView(viewModel: viewModel)
            }
            
            AddTaskButton()
            
            Spacer()
        }
        .padding()
        .background(Image("fishBackground").resizable().edgesIgnoringSafeArea(.all))
        .onAppear {
            if !hasInitializedDate {
                viewModel.currentDate = Date()
                hasInitializedDate = true
            }
        }
    }
    
    // Generate 25 months (12 before, current, 12 after)
    private func generateMonthItems() -> [MonthItem] {
        let calendar = Calendar.current
        let current = calendar.date(from: calendar.dateComponents([.year, .month], from: viewModel.currentDate)) ?? Date()
        return (-12...12).map { offset in
            let date = calendar.date(byAdding: .month, value: offset, to: current) ?? current
            let label = DateFormatter().apply { $0.dateFormat = "MMM\nyyyy" }.string(from: date)
            return MonthItem(date: date, label: label, isToday: calendar.isDate(date, equalTo: Date(), toGranularity: .month))
        }
    }
    // Generate 105 weeks (52 before, current, 52 after)
    private func generateWeekItems() -> [WeekItem] {
        let calendar = Calendar.current
        let current = calendar.dateInterval(of: .weekOfYear, for: viewModel.currentDate)?.start ?? Date()
        return (-52...52).map { offset in
            let date = calendar.date(byAdding: .weekOfYear, value: offset, to: current) ?? current
            let weekOfYear = calendar.component(.weekOfYear, from: date)
            let year = calendar.component(.yearForWeekOfYear, from: date)
            let label = "W\(weekOfYear)\n\(year)"
            return WeekItem(date: date, label: label, isToday: calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear))
        }
    }
    // Generate 61 days (30 before, current, 30 after)
    private func generateDayItems() -> [DayItem] {
        let calendar = Calendar.current
        let current = calendar.startOfDay(for: viewModel.currentDate)
        return (-30...30).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: current) ?? current
            let label = DateFormatter().apply { $0.dateFormat = "d\nEEE" }.string(from: date)
            return DayItem(date: date, label: label, isToday: calendar.isDateInToday(date))
        }
    }
}

// MARK: - Month View
struct MonthView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @EnvironmentObject var user: UserModel
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    // State for long-press event editing
    @State private var longPressedDate: Date? = nil
    @State private var showEventSheet: Bool = false
    @State private var selectedEventModel: EventModel? = nil
    @State private var showEditPopup: Bool = false
    
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
        // ActionSheet for events on long-pressed date
        .actionSheet(isPresented: $showEventSheet) {
            let events = longPressedDate.map { viewModel.getEventsForDate($0, from: user) } ?? []
            return ActionSheet(
                title: Text("Edit Event"),
                buttons: events.map { event in
                    .default(Text(event.taskName)) {
                        selectedEventModel = event
                        showEditPopup = true
                    }
                } + [.cancel()]
            )
        }
        // Edit popup for selected event
        .sheet(item: $selectedEventModel) { event in
            EditEventModelPopup(event: event, onDismiss: { selectedEventModel = nil })
        }
    }
    
    @ViewBuilder
    private func dayCell(for day: CalendarDay) -> some View {
        let isToday = Calendar.current.isDateInToday(day.date)
        let isSelected = Calendar.current.isDate(day.date, inSameDayAs: viewModel.currentDate)
        let isInCurrentMonth = day.isInCurrentMonth
        let dayEvents = viewModel.getEventsForDate(day.date, from: user)
        
        VStack(spacing: 2) {
            Text("\(Calendar.current.component(.day, from: day.date))")
                .frame(maxWidth: .infinity, minHeight: 36)
                .padding(.vertical, 4)
                .background(
                    isToday ?
                    Circle().fill(Color.red.opacity(0.8)) :
                    isSelected ?
                    Circle().fill(Color.blue.opacity(0.3)) : Circle().fill(Color.clear)
                )
                .foregroundColor(
                    isToday ? .white :
                    isInCurrentMonth ? .primary : Color.secondary.opacity(0.5)
                )
                .fontWeight(isToday ? .bold : .regular)
                .opacity(isInCurrentMonth ? 1.0 : 0.5)
            
            // Event indicators
            if isInCurrentMonth && !dayEvents.isEmpty {
                HStack(spacing: 2) {
                    ForEach(0..<min(dayEvents.count, 3), id: \.self) { _ in
                        Circle()
                            .fill(Color.green)
                            .frame(width: 4, height: 4)
                    }
                }
                .padding(.top, 2)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.currentDate = day.date
        }
        .onLongPressGesture {
            if isInCurrentMonth && !dayEvents.isEmpty {
                longPressedDate = day.date
                showEventSheet = true
            }
        }
    }
}

// MARK: - Week View
struct WeekView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @EnvironmentObject var user: UserModel
    
    var body: some View {
        let weekEvents = viewModel.fetchEventsForWeek(from: user)
        
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
                        viewModel.scope = .day
                    }
                }
            }
            
            // Events for the week
            if weekEvents.isEmpty {
                VStack {
                    Text("No events this week")
                        .foregroundColor(.secondary)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(weekEvents) { event in
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 10, height: 10)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.taskName)
                                .font(.headline)
                            HStack {
                                Text(event.scheduledDate, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(event.scheduledDate, style: .time)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Text(formatDuration(event.length))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 8)
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Day View
struct DayView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @EnvironmentObject var user: UserModel
    
    var body: some View {
        let events = viewModel.fetchEventsForCurrentDate(from: user)
        
        if events.isEmpty {
            VStack {
                Text("No events scheduled")
                    .foregroundColor(.secondary)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.2), radius: 8)
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        } else {
            List(events) { event in
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.taskName)
                            .font(.headline)
                        Text(event.scheduledDate, style: .time)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(formatDuration(event.length))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .listStyle(.plain)
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.2), radius: 8)
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Preview
#Preview {
    CalendarView()
        .environmentObject(UserModel(name: "Test User", email: "test@example.com"))
}

// Add this View extension at the bottom of the file for conditional modifiers
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// DateFormatter extension for inline configuration
extension DateFormatter {
    func apply(_ block: (DateFormatter) -> Void) -> DateFormatter {
        block(self)
        return self
    }
}

// MARK: - Edit EventModel Popup
struct EditEventModelPopup: View {
    @Environment(\.dismiss) private var dismiss
    @State var event: EventModel
    var onDismiss: () -> Void

    @State private var isEditing = false
    @State private var editingAspect: EditingAspect = .date
    @State private var editingDate: Date = Date()
    @State private var editingLength: TimeInterval = 0
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var showDatePicker = false
    @State private var showTimePicker = false

    enum EditingAspect {
        case date, length
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                // Header with close button
                HStack {
                    Spacer()
                    Button(action: { dismiss(); onDismiss() }) {
                        Circle()
                            .fill(Color.gray.opacity(0.80))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                VStack(spacing: 20) {
                    Text("Edit Event")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 10)

                    if isEditing {
                        VStack(spacing: 20) {
                            eventHeader
                            VStack(spacing: 20) {
                                Text("Edit \(editingAspectTitle)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                EditingInterfaceView(
                                    editingAspect: editingAspect,
                                    editingDate: $editingDate,
                                    editingLength: $editingLength,
                                    showDatePicker: $showDatePicker,
                                    showTimePicker: $showTimePicker
                                )
                                Button(action: {
                                    saveChanges()
                                    isEditing = false
                                }) {
                                    HStack {
                                        Image(systemName: "checkmark")
                                        Text("Save")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentColor)
                                    .cornerRadius(12)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                eventHeader
                                // Date
                                DetailCard(title: "Date & Time", value: event.scheduledDate.formatted(date: .abbreviated, time: .shortened), icon: "calendar")
                                    .onTapGesture {
                                        isEditing = true
                                        editingAspect = .date
                                        editingDate = event.scheduledDate
                                    }
                                // Length
                                let hours = Int(event.length) / 3600
                                let mins = (Int(event.length) % 3600) / 60
                                DetailCard(title: "Length", value: "\(hours)h \(mins)m", icon: "clock")
                                    .onTapGesture {
                                        isEditing = true
                                        editingAspect = .length
                                        editingLength = event.length
                                    }
                            }
                            .padding(.horizontal, 10)
                        }
                    }

                    Spacer()

                    // Update button
                    Button(action: updateEvent) {
                        Text("Update Event")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(12)
                    }
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 20)
            }
        }
        .alert(isPresented: $showValidationAlert) {
            Alert(title: Text("Invalid Event"), message: Text(validationMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showDatePicker) {
            datePickerSheet
        }
        .sheet(isPresented: $showTimePicker) {
            timePickerSheet
        }
    }

    // MARK: - Event Header
    private var eventHeader: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: event.taskCategory.filledIconName)
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor)
                Spacer()
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: i <= event.energy ? "bolt.fill" : "bolt")
                            .foregroundColor(i <= event.energy ? .yellow : .gray)
                            .font(.system(size: 24))
                    }
                }
            }
            Text(event.taskName.isEmpty ? "Event" : event.taskName)
                .font(.title)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }

    private var editingAspectTitle: String {
        switch editingAspect {
        case .date: return "Date & Time"
        case .length: return "Event Length"
        }
    }

    private func saveChanges() {
        switch editingAspect {
        case .date:
            event.scheduledDate = editingDate
        case .length:
            event.length = editingLength
        }
    }

    private func updateEvent() {
        // Validate
        if event.taskName.trimmingCharacters(in: .whitespaces).isEmpty {
            validationMessage = "Event name cannot be empty."
            showValidationAlert = true
            return
        }
        // Save changes to the event (in-memory only for now)
        dismiss()
        onDismiss()
    }

    private var datePickerSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Date")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                DatePicker("Event Date", selection: $editingDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
                    .padding()
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    showDatePicker = false
                },
                trailing: Button("Done") {
                    showDatePicker = false
                }
            )
        }
        .presentationDetents([.medium])
    }

    private var timePickerSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Time")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                DatePicker("Event Time", selection: $editingDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding()
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    showTimePicker = false
                },
                trailing: Button("Done") {
                    showTimePicker = false
                }
            )
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Editing Interface View
struct EditingInterfaceView: View {
    let editingAspect: EditEventModelPopup.EditingAspect
    @Binding var editingDate: Date
    @Binding var editingLength: TimeInterval
    @Binding var showDatePicker: Bool
    @Binding var showTimePicker: Bool
    
    var body: some View {
        switch editingAspect {
        case .date:
            DateEditingView(
                editingDate: $editingDate,
                showDatePicker: $showDatePicker,
                showTimePicker: $showTimePicker
            )
        case .length:
            LengthEditingView(editingLength: $editingLength)
        }
    }
}

// MARK: - Date Editing View
struct DateEditingView: View {
    @Binding var editingDate: Date
    @Binding var showDatePicker: Bool
    @Binding var showTimePicker: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Select Date & Time")
                .font(.headline)
            VStack(spacing: 20) {
                Button(action: { showDatePicker = true }) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Date")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(editingDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                Button(action: { showTimePicker = true }) {
                    HStack {
                        Image(systemName: "clock")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Time")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(editingDate.formatted(date: .omitted, time: .shortened))
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
    }
}

// MARK: - Length Editing View
struct LengthEditingView: View {
    @Binding var editingLength: TimeInterval
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Set Event Length")
                .font(.headline)
            HStack {
                Picker("Hours", selection: editingLengthHours) {
                    ForEach(0..<13) { hour in
                        Text("\(hour) hr").tag(hour)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 100)
                Picker("Minutes", selection: editingLengthMinutes) {
                    ForEach([0, 15, 30, 45], id: \.self) { min in
                        Text("\(min) min").tag(min)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 100)
            }
        }
    }
    
    private var editingLengthHours: Binding<Int> {
        Binding(
            get: { Int(editingLength) / 3600 },
            set: { editingLength = TimeInterval($0 * 3600 + (Int(editingLength) % 3600)) }
        )
    }

    private var editingLengthMinutes: Binding<Int> {
        Binding(
            get: { (Int(editingLength) % 3600) / 60 },
            set: { editingLength = TimeInterval((Int(editingLength) / 3600) * 3600 + $0 * 60) }
        )
    }
}
