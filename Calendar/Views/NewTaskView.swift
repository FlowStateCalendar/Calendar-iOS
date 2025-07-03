//
//  NewTaskView.swift
//  Calendar
//
//  Created by Rhyse Summers on 08/06/2025.
//

import SwiftUI
import Combine

// Move these to the top-level, above NewTaskView:
enum NotificationTypeOption: String, CaseIterable, Identifiable {
    case none = "No Reminders"
    case one = "One Reminder"
    case multiple = "Multiple Reminders"
    var id: String { rawValue }
}

struct NotificationTimingConfig: Identifiable, Hashable {
    let id = UUID()
    var minutesBefore: Int = 15
    var sound: NotificationSound = .defaultSound
}

struct NewTaskView: View {
    @EnvironmentObject var user: UserModel
    @Environment(\.dismiss) private var dismiss
    
    // Optional task for editing mode
    let taskToEdit: TaskModel?
    
    // State for task fields - initialize with empty/default values
    @State private var name: String = ""
    @State private var descriptionText: String = ""
    @State private var category: TaskCategory = .other
    @State private var energy: Int = 1
    @State private var length: TimeInterval = 0
    @State private var frequency: TaskFrequency = .none
    @State private var date: Date = Date()
    
    // Editing state
    @State private var isEditing = false
    @State private var editingAspect: EditingAspect = .description
    @State private var editingText: String = ""
    @State private var editingCategory: TaskCategory = .other
    @State private var editingEnergy: Int = 1
    @State private var editingLength: TimeInterval = 0
    @State private var editingFrequency: TaskFrequency = .none
    @State private var editingDate: Date = Date()
    
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var showDeleteAlert = false
    
    // Date and time selection popups
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    
    // Add state for notification configuration at the top of NewTaskView:
    @State private var notificationType: NotificationTypeOption = .none
    @State private var notificationTimings: [NotificationTimingConfig] = [NotificationTimingConfig()]
    
    enum EditingAspect {
        case name, description, category, energy, length, frequency, date, notifications
    }
    
    // MARK: - Computed Properties
    private var isEditingMode: Bool {
        taskToEdit != nil
    }
    
    // Real-time reward calculations
    private var calculatedXP: Int {
        RewardCalculator.xp(for: createTaskModel())
    }
    
    private var calculatedCoins: Int {
        RewardCalculator.coins(for: createTaskModel())
    }
    
    // MARK: - Dismiss Action
    private func dismissView() {
        withAnimation(.easeInOut(duration: 0.3)) {
            dismiss()
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                // Header with close button
                HStack {
                    // Delete button (only show when editing an existing task)
                    if isEditingMode {
                        Button(action: { showDeleteAlert = true }) {
                            Circle()
                                .fill(Color.red.opacity(0.80))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Image(systemName: "trash")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { dismissView() }) {
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
                
                // Main content
                VStack(spacing: 20) {
                    // Header
                    Text(isEditingMode ? "View Task" : "Create New Task")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    
                    if isEditing {
                        VStack(spacing: 20) {
                            // Header always visible
                            taskHeader
                            VStack(spacing: 20) {
                                Text("Edit \(editingAspectTitle)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                editingInterface
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
                                taskHeader
                                // Name
                                DetailCard(title: "Name", value: name.isEmpty ? "Tap to enter name" : name, icon: "textformat")
                                    .onTapGesture {
                                        isEditing = true
                                        editingAspect = .name
                                        editingText = name
                                    }
                                // Description
                                DetailCard(title: "Description", value: descriptionText.isEmpty ? "Tap to enter description" : descriptionText, icon: "doc.text")
                                    .onTapGesture {
                                        isEditing = true
                                        editingAspect = .description
                                        editingText = descriptionText
                                    }
                                // Category
                                DetailCard(title: "Category", value: category.displayName, icon: category.filledIconName)
                                    .onTapGesture {
                                        isEditing = true
                                        editingAspect = .category
                                        editingCategory = category
                                    }
                                // Energy
                                DetailCard(title: "Energy", value: energyDescription, icon: "bolt.fill")
                                    .onTapGesture {
                                        isEditing = true
                                        editingAspect = .energy
                                        editingEnergy = energy
                                    }
                                // Length
                                let hours = Int(length) / 3600
                                let mins = (Int(length) % 3600) / 60
                                DetailCard(title: "Length", value: "\(hours)h \(mins)m", icon: "clock")
                                    .onTapGesture {
                                        isEditing = true
                                        editingAspect = .length
                                        editingLength = length
                                    }
                                // Frequency
                                DetailCard(title: "Frequency", value: frequency.rawValue.capitalized, icon: "repeat")
                                    .onTapGesture {
                                        isEditing = true
                                        editingAspect = .frequency
                                        editingFrequency = frequency
                                    }
                                // Date
                                DetailCard(title: "Date & Time", value: date.formatted(date: .abbreviated, time: .shortened), icon: "calendar")
                                    .onTapGesture {
                                        isEditing = true
                                        editingAspect = .date
                                        editingDate = date
                                    }
                                // Notifications
                                DetailCard(title: "Notifications", value: "Tap to configure", icon: "bell")
                                    .onTapGesture {
                                        isEditing = true
                                        editingAspect = .notifications
                                    }
                            }
                            .padding(.horizontal, 10)
                        }
                    }
                    
                    Spacer()
                    
                    // Create/Update button
                    Button(action: createTask) {
                        Text(isEditingMode ? "Update Task" : "Create Task")
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
            Alert(title: Text("Invalid Task"), message: Text(validationMessage), dismissButton: .default(Text("OK")))
        }
        .alert("Delete Task", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteTask()
            }
        } message: {
            Text("Are you sure you want to delete this task? This action cannot be undone.")
        }
        .sheet(isPresented: $showDatePicker) {
            datePickerSheet
        }
        .sheet(isPresented: $showTimePicker) {
            timePickerSheet
        }
        .onAppear {
            // Load task data if editing
            if let task = taskToEdit {
                name = task.name
                descriptionText = task.taskDescription
                category = task.category
                energy = task.energy
                length = task.lengthMins
                frequency = task.frequency
                date = task.taskDate
            }
        }
    }
    
    // MARK: - Task Header
    private var taskHeader: some View {
        VStack(spacing: 16) {
            HStack {
                // Left side: Category and Energy
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: category.filledIconName)
                            .font(.system(size: 24))
                            .foregroundColor(.accentColor)
                        Text(category.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: i <= energy ? "bolt.fill" : "bolt")
                                .foregroundColor(i <= energy ? .yellow : .gray)
                                .font(.system(size: 16))
                        }
                    }
                }
                
                Spacer()
                
                // Right side: XP and Coins
                VStack(alignment: .trailing, spacing: 8) {
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.orange)
                        Text("\(calculatedXP)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Image(systemName: "dollarsign.ring")
                            .font(.system(size: 16))
                            .foregroundColor(.yellow)
                        Text("\(calculatedCoins)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
            
            Text(name.isEmpty ? "Task Name" : name)
                .font(.title)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    // Helper function to create a temporary task model for reward calculation
    private func createTaskModel() -> TaskModel {
        return TaskModel(
            name: name.isEmpty ? "Task" : name,
            description: descriptionText,
            lengthMins: length,
            frequency: frequency,
            category: category,
            energy: energy,
            taskDate: date
        )
    }
    
    // MARK: - Editing Interface
    @ViewBuilder
    private var editingInterface: some View {
        switch editingAspect {
        case .name:
            nameEditingView
        case .description:
            descriptionEditingView
        case .category:
            categoryEditingView
        case .energy:
            energyEditingView
        case .length:
            lengthEditingView
        case .frequency:
            frequencyEditingView
        case .date:
            dateEditingView
        case .notifications:
            notificationsEditingView
        }
    }
    
    @ViewBuilder
    private var nameEditingView: some View {
        TextField("Task Name", text: $editingText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }
    
    @ViewBuilder
    private var descriptionEditingView: some View {
        TextEditor(text: $editingText)
            .padding(8)
            .frame(minHeight: 120, maxHeight: 200)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 1)
            )
    }
    
    @ViewBuilder
    private var categoryEditingView: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(TaskCategory.allCases, id: \.self) { cat in
                Button(action: { editingCategory = cat }) {
                    VStack(spacing: 8) {
                        Image(systemName: editingCategory == cat ? cat.filledIconName : cat.iconName)
                            .font(.title)
                            .foregroundColor(editingCategory == cat ? .accentColor : .primary)
                        Text(cat.displayName)
                            .font(.caption)
                            .foregroundColor(editingCategory == cat ? .accentColor : .primary)
                    }
                    .padding()
                    .background(editingCategory == cat ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
        }
    }
    
    @ViewBuilder
    private var energyEditingView: some View {
        VStack(spacing: 16) {
            Text("Select Energy Level")
                .font(.headline)
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { level in
                    Button(action: { editingEnergy = level }) {
                        VStack(spacing: 4) {
                            Image(systemName: level <= editingEnergy ? "bolt.fill" : "bolt")
                                .font(.title)
                                .foregroundColor(level <= editingEnergy ? .yellow : .gray)
                            Text("\(level)")
                                .font(.caption)
                                .foregroundColor(level <= editingEnergy ? .primary : .secondary)
                        }
                        .padding()
                        .background(level <= editingEnergy ? Color.yellow.opacity(0.2) : Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var lengthEditingView: some View {
        VStack(spacing: 16) {
            Text("Set Task Length")
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
    
    @ViewBuilder
    private var frequencyEditingView: some View {
        VStack(spacing: 16) {
            Text("Select Frequency")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                ForEach(TaskFrequency.allCases, id: \.self) { freq in
                    Button(action: { editingFrequency = freq }) {
                        HStack {
                            Text(freq.rawValue.capitalized)
                                .foregroundColor(editingFrequency == freq ? .white : .primary)
                            Spacer()
                            if editingFrequency == freq {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(editingFrequency == freq ? Color.accentColor : Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var dateEditingView: some View {
        VStack(spacing: 16) {
            Text("Select Date & Time")
                .font(.headline)
            
            VStack(spacing: 20) {
                // Date selection button
                Button(action: {
                    showDatePicker = true
                }) {
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
                
                // Time selection button
                Button(action: {
                    showTimePicker = true
                }) {
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
    
    @ViewBuilder
    private var notificationsEditingView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Notifications")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top)

            // Picker for notification type with label
            HStack {
                Text("Reminder Frequency:")
                    .font(.headline)
                Picker("Type", selection: $notificationType) {
                    ForEach(NotificationTypeOption.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .onChange(of: notificationType) {
                switch notificationType {
                case .none:
                    notificationTimings = []
                case .one:
                    if notificationTimings.isEmpty {
                        notificationTimings = [NotificationTimingConfig()]
                    } else if notificationTimings.count > 1 {
                        notificationTimings = [notificationTimings.first!]
                    }
                case .multiple:
                    if notificationTimings.isEmpty {
                        notificationTimings = [NotificationTimingConfig()]
                    }
                }
            }
            .padding(.bottom, 4)

            if notificationType == .none {
                Text("No reminders will be sent for this task.")
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach($notificationTimings) { $timing in
                        NotificationTimingRow(
                            timing: $timing,
                            canDelete: notificationTimings.count > 1,
                            onDelete: {
                                if let idx = notificationTimings.firstIndex(of: timing) {
                                    notificationTimings.remove(at: idx)
                                    // If user deletes all, revert to none
                                    if notificationTimings.isEmpty {
                                        notificationType = .none
                                    } else if notificationTimings.count == 1 {
                                        notificationType = .one
                                    } else {
                                        notificationType = .multiple
                                    }
                                }
                            }
                        )
                    }
                    if notificationTimings.count < 5 {
                        Button(action: {
                            notificationTimings.append(NotificationTimingConfig())
                            if notificationTimings.count == 2 {
                                notificationType = .multiple
                            } else if notificationTimings.count == 1 {
                                notificationType = .one
                            }
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Reminder")
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .padding()
    }
    
    private var editingAspectTitle: String {
        switch editingAspect {
        case .name: return "Name"
        case .description: return "Description"
        case .category: return "Category"
        case .energy: return "Energy Level"
        case .length: return "Task Length"
        case .frequency: return "Frequency"
        case .date: return "Date & Time"
        case .notifications: return "Notifications"
        }
    }
    
    private var energyDescription: String {
        switch energy {
        case 1: return "Very Low"
        case 2: return "Low"
        case 3: return "Medium"
        case 4: return "High"
        case 5: return "Very High"
        default: return "Unknown"
        }
    }
    
    private func saveChanges() {
        switch editingAspect {
        case .name:
            name = editingText
        case .description:
            descriptionText = editingText
        case .category:
            category = editingCategory
        case .energy:
            energy = editingEnergy
        case .length:
            length = editingLength
        case .frequency:
            frequency = editingFrequency
        case .date:
            date = editingDate
        case .notifications:
            // Notifications editing is not implemented in the current version
            break
        }
    }
    
    private func createTask() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            validationMessage = "Task name cannot be empty."
            showValidationAlert = true
            return
        }
        guard !descriptionText.trimmingCharacters(in: .whitespaces).isEmpty else {
            validationMessage = "Task description cannot be empty."
            showValidationAlert = true
            return
        }
        
        // Build NotificationModel from UI state
        let notificationModel: NotificationModel = {
            switch notificationType {
            case .none:
                return NotificationModel(frequency: .none, type: .local, sound: .defaultSound, content: "", timings: [])
            case .one:
                let timing = notificationTimings.first ?? NotificationTimingConfig()
                return NotificationModel(
                    frequency: .once,
                    type: .local,
                    sound: timing.sound,
                    content: "",
                    timings: [NotificationTiming(minutesBeforeEvent: timing.minutesBefore)]
                )
            case .multiple:
                let timings = notificationTimings.prefix(5).map { NotificationTiming(minutesBeforeEvent: $0.minutesBefore) }
                // Use the first sound for the model (NotificationModel supports only one sound, but each timing can have its own in the UI)
                let sound = notificationTimings.first?.sound ?? .defaultSound
                return NotificationModel(
                    frequency: .custom,
                    type: .local,
                    sound: sound,
                    content: "",
                    timings: timings
                )
            }
        }()

        if let existingTask = taskToEdit {
            // Update existing task
            existingTask.name = name
            existingTask.taskDescription = descriptionText
            existingTask.category = category
            existingTask.energy = energy
            existingTask.lengthMins = length
            existingTask.frequency = frequency
            existingTask.taskDate = date
            existingTask.notification = notificationModel
            
            // Update the task in the user model to trigger notification updates
            user.updateTask(existingTask)
        } else {
            // Create new task
            let newTask = TaskModel(
                name: name,
                description: descriptionText,
                lengthMins: length,
                frequency: frequency,
                category: category,
                energy: energy,
                taskDate: date,
                notification: notificationModel
            )
            user.addTask(newTask)
        }
        
        dismiss()
    }
    
    private func deleteTask() {
        if let existingTask = taskToEdit {
            user.removeTask(existingTask)
            dismiss()
        }
    }
    
    // MARK: - Date and Time Picker Sheets
    private var datePickerSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Date")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                DatePicker("Task Date", selection: $editingDate, displayedComponents: .date)
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
                
                DatePicker("Task Time", selection: $editingDate, displayedComponents: .hourAndMinute)
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

#Preview {
    NewTaskView(taskToEdit: TaskModel.sampleTasks.first)
        .environmentObject(UserModel(name: "Test User", email: "test@example.com"))
}

// Add NotificationTimingRow view at the bottom of the file:
struct NotificationTimingRow: View {
    @Binding var timing: NotificationTimingConfig
    var canDelete: Bool
    var onDelete: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Text("Notify")
            TextField("Minutes", value: $timing.minutesBefore, formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .frame(width: 50)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Text("min before")
            Picker("Sound", selection: $timing.sound) {
                ForEach(NotificationSound.allCases, id: \ .self) { sound in
                    Text(sound.displayName).tag(sound)
                }
            }
            .pickerStyle(MenuPickerStyle())
            if canDelete {
                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
}
