//
//  NewTaskView.swift
//  Calendar
//
//  Created by Rhyse Summers on 08/06/2025.
//

import SwiftUI
import Combine

struct NewTaskView: View {
    @EnvironmentObject var user: UserModel
    @Environment(\.dismiss) private var dismiss
    
    // State for task fields
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
    
    enum EditingAspect {
        case name, description, category, energy, length, frequency, date
    }
    
    var body: some View {
        VStack {
            UserBar()
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
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
                    Text("Create New Task")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 30)
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
                        .padding()
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
                                DetailCard(title: "Date", value: date.formatted(date: .abbreviated, time: .omitted), icon: "calendar")
                                    .onTapGesture {
                                        isEditing = true
                                        editingAspect = .date
                                        editingDate = date
                                    }
                            }
                            .padding()
                        }
                    }
                    Button(action: createTask) {
                        Text("Create Task")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
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
        .alert(isPresented: $showValidationAlert) {
            Alert(title: Text("Invalid Task"), message: Text(validationMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    // MARK: - Task Header
    private var taskHeader: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: category.filledIconName)
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor)
                Spacer()
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: i <= energy ? "bolt.fill" : "bolt")
                            .foregroundColor(i <= energy ? .yellow : .gray)
                            .font(.system(size: 24))
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
            Text("Select Date")
                .font(.headline)
            DatePicker("Task Date", selection: $editingDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .labelsHidden()
        }
    }
    
    private var editingAspectTitle: String {
        switch editingAspect {
        case .name: return "Name"
        case .description: return "Description"
        case .category: return "Category"
        case .energy: return "Energy Level"
        case .length: return "Task Length"
        case .frequency: return "Frequency"
        case .date: return "Date"
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
        let newTask = TaskModel(
            name: name,
            description: descriptionText,
            lengthMins: length,
            frequency: frequency,
            category: category,
            energy: energy,
            taskDate: date
        )
        user.addTask(newTask)
        dismiss()
    }
}

#Preview {
    NewTaskView()
        .environmentObject(UserModel(name: "Test User", email: "test@example.com"))
}
