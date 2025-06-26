//
//  InspectTaskView.swift
//  Calendar
//
//  Created by Rhyse Summers on 23/06/2025.
//

import SwiftUI

struct InspectTaskView: View {
    @Binding var task: TaskModel
    @Environment(\.dismiss) private var dismiss
    @State private var showEditTaskView = false
    @State private var isEditing = false
    @State private var editingAspect: EditingAspect = .description
    @State private var editingText: String = ""
    @State private var editingCategory: TaskCategory = .other
    @State private var editingEnergy: Int = 1
    @State private var editingLength: TimeInterval = 0
    @State private var editingFrequency: TaskFrequency = .none
    @State private var editingDate: Date = Date()
    
    enum EditingAspect {
        case description, category, energy, length, frequency, date, none
    }
    
    var body: some View {
        VStack {
            UserBar()
            
            ZStack {
                // Close Button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
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
                    Spacer()
                }
                
                VStack {
                    Text("Task Details")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 30)
                    
                    if isEditing {
                        // Focused editing view
                        VStack(spacing: 20) {
                            // Task Header (always visible)
                            VStack(spacing: 16) {
                                HStack {
                                    Image(systemName: task.category.filledIconName)
                                        .font(.system(size: 40))
                                        .foregroundColor(.accentColor)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 4) {
                                        ForEach(1...5, id: \.self) { i in
                                            Image(systemName: i <= task.energy ? "bolt.fill" : "bolt")
                                                .foregroundColor(i <= task.energy ? .yellow : .gray)
                                                .font(.system(size: 24))
                                        }
                                    }
                                }
                                
                                Text(task.name)
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                            
                            // Editing interface
                            VStack(spacing: 20) {
                                Text("Edit \(editingAspectTitle)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                editingInterface
                                
                                // Save Button
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
                        .padding()
                    } else {
                        // Main inspection view
                        ScrollView {
                            VStack(spacing: 20) {
                                // Task Header (Category, Name, Energy)
                                VStack(spacing: 16) {
                                    // Category and Energy
                                    HStack {
                                        Image(systemName: task.category.filledIconName)
                                            .font(.system(size: 40))
                                            .foregroundColor(.accentColor)
                                        
                                        Spacer()
                                        
                                        // Energy bolts
                                        HStack(spacing: 4) {
                                            ForEach(1...5, id: \.self) { i in
                                                Image(systemName: i <= task.energy ? "bolt.fill" : "bolt")
                                                    .foregroundColor(i <= task.energy ? .yellow : .gray)
                                                    .font(.system(size: 24))
                                            }
                                        }
                                    }
                                    
                                    // Task Name
                                    Text(task.name)
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(15)
                                
                                // Task Description
                                if !task.taskDescription.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Description")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        Text(task.taskDescription)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(10)
                                    }
                                    .onTapGesture {
                                        isEditing = true
                                        editingAspect = .description
                                        editingText = task.taskDescription
                                    }
                                }
                                
                                // Task Details Grid
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                    // Category
                                    DetailCard(title: "Category", value: task.category.displayName, icon: task.category.filledIconName)
                                        .onTapGesture {
                                            isEditing = true
                                            editingAspect = .category
                                            editingCategory = task.category
                                        }
                                    
                                    // Energy
                                    DetailCard(title: "Energy", value: task.energyDescription, icon: "bolt.fill")
                                        .onTapGesture {
                                            isEditing = true
                                            editingAspect = .energy
                                            editingEnergy = task.energy
                                        }
                                    
                                    // Length
                                    let hours = Int(task.lengthMins) / 3600
                                    let mins = (Int(task.lengthMins) % 3600) / 60
                                    DetailCard(title: "Length", value: "\(hours)h \(mins)m", icon: "clock")
                                        .onTapGesture {
                                            isEditing = true
                                            editingAspect = .length
                                            editingLength = task.lengthMins
                                        }
                                    
                                    // Frequency
                                    DetailCard(title: "Frequency", value: task.frequency.rawValue.capitalized, icon: "repeat")
                                        .onTapGesture {
                                            isEditing = true
                                            editingAspect = .frequency
                                            editingFrequency = task.frequency
                                        }
                                    
                                    // Date
                                    DetailCard(title: "Date", value: task.taskDate.formatted(date: .abbreviated, time: .omitted), icon: "calendar")
                                        .onTapGesture {
                                            isEditing = true
                                            editingAspect = .date
                                            editingDate = task.taskDate
                                        }
                                    
                                    // Notification Type
                                    DetailCard(title: "Notifications", value: task.notification.type.displayName, icon: "bell")
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .background {
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    topTrailingRadius: 20
                )
                .fill(.gray)
                .ignoresSafeArea()
            }
        }
        .background(Image("fishBackground").resizable().edgesIgnoringSafeArea(.all))
    }
    
    // Computed properties for editing interface
    private var editingAspectTitle: String {
        switch editingAspect {
        case .description: return "Description"
        case .category: return "Category"
        case .energy: return "Energy Level"
        case .length: return "Task Length"
        case .frequency: return "Frequency"
        case .date: return "Date"
        case .none: return ""
        }
    }
    
    @ViewBuilder
    private var editingInterface: some View {
        switch editingAspect {
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
        case .none:
            EmptyView()
        }
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
            ForEach(TaskCategory.allCases, id: \.self) { category in
                Button(action: {
                    editingCategory = category
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: editingCategory == category ? category.filledIconName : category.iconName)
                            .font(.title)
                            .foregroundColor(editingCategory == category ? .accentColor : .primary)
                        Text(category.displayName)
                            .font(.caption)
                            .foregroundColor(editingCategory == category ? .accentColor : .primary)
                    }
                    .padding()
                    .background(editingCategory == category ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
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
                    Button(action: {
                        editingEnergy = level
                    }) {
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
                hoursPicker
                minutesPicker
            }
        }
    }
    
    private var hoursPicker: some View {
        Picker("Hours", selection: hoursBinding) {
            ForEach(0..<13) { hour in
                Text("\(hour) hr").tag(hour)
            }
        }
        .pickerStyle(.wheel)
        .frame(width: 100)
    }
    
    private var minutesPicker: some View {
        Picker("Minutes", selection: minutesBinding) {
            ForEach([0, 15, 30, 45], id: \.self) { min in
                Text("\(min) min").tag(min)
            }
        }
        .pickerStyle(.wheel)
        .frame(width: 100)
    }
    
    private var hoursBinding: Binding<Int> {
        Binding(
            get: { Int(editingLength) / 3600 },
            set: { editingLength = TimeInterval($0 * 3600 + (Int(editingLength) % 3600)) }
        )
    }
    
    private var minutesBinding: Binding<Int> {
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
                ForEach(TaskFrequency.allCases, id: \.self) { frequency in
                    Button(action: {
                        editingFrequency = frequency
                    }) {
                        HStack {
                            Text(frequency.rawValue.capitalized)
                                .foregroundColor(editingFrequency == frequency ? .white : .primary)
                            Spacer()
                            if editingFrequency == frequency {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(editingFrequency == frequency ? Color.accentColor : Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var dateEditingView: some View {
        VStack(spacing: 16) {
            Text("Select Date")
                .font(.headline)
            DatePicker("Task Date", selection: $editingDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .labelsHidden()
        }
    }
    
    private func saveChanges() {
        switch editingAspect {
        case .description:
            task.taskDescription = editingText
        case .category:
            task.category = editingCategory
        case .energy:
            task.energy = editingEnergy
        case .length:
            task.lengthMins = editingLength
        case .frequency:
            task.frequency = editingFrequency
        case .date:
            task.taskDate = editingDate
        case .none:
            break
        }
    }
}

#Preview {
    InspectTaskView(task: .constant(TaskModel.sampleTasks[0]))
        .environmentObject(UserModel(name: "Test User", email: "test@example.com"))
}

