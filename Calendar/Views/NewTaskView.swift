//
//  NewTaskView.swift
//  Calendar
//
//  Created by Rhyse Summers on 08/06/2025.
//

import SwiftUI
import Combine

struct NewTaskView: View {
    @State private var taskMins: Int = 0
    @State private var taskHours: Int = 0
    @State private var energyLevel: Int = 0 // 0 to 5
    @State private var selectedCategory: TaskCategory? = nil
    @State private var taskDescription: String = ""
    @State private var taskName: String = "Task Name"
    @State private var isEditingName: Bool = false
    @State private var showTimePicker: Bool = false
    @State private var taskLengthSeconds: TimeInterval = 0
    // For the picker UI
    @State private var pickerHours: Int = 0
    @State private var pickerMins: Int = 0
    @State private var selectedFrequency: TaskFrequencyOption = .once
    @State private var selectedDays: Set<Int> = [] // 0 = Monday, 6 = Sunday
    @State private var taskDate: Date = Date()
    @State private var showDatePicker: Bool = false
    @State private var showValidationAlert: Bool = false
    @State private var validationMessage: String = ""
    
    @EnvironmentObject var user: UserModel
    @Environment(\.dismiss) private var dismiss
    
    enum TaskFrequencyOption: String, CaseIterable, Identifiable {
        case once = "Once"
        case every = "Every"
        case everyday = "Everyday"
        case everyWeekday = "Every Weekday"
        case weekends = "Weekends"
        var id: String { self.rawValue }
    }
    let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        VStack{
            
            UserBar()
            
            ZStack{
        
                // Close Button
                VStack{
                    HStack{
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
                    Spacer ()
                }
                
                VStack{
                    Text("Create a New Task")
                        .padding(.top, 30)
                    
                    // Icon Section
                    HStack{
                        // Energy level bolts
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= energyLevel ? "bolt.fill" : "bolt")
                                .foregroundColor(index <= energyLevel ? .yellow : .black)
                                .font(.system(size: 20))
                                .onTapGesture {
                                    energyLevel = index
                                }
                        }
                        
                        Spacer()
                        
                        // Icon
                        Circle()
                            .fill(Color.green.opacity(0.80))
                            .frame(width: 50, height: 50)
                        
                        Spacer()
                        
                        // Category icons
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Image(systemName: selectedCategory == category ? category.filledIconName : category.iconName)
                                    .foregroundColor(
                                        category.iconName == "fork.knife" ?
                                            (selectedCategory == category ? .secondary : .primary) :
                                            (selectedCategory == category ? .accentColor : .primary)
                                    )
                                    .font(.system(size: 24))
                            }
                        }
                    }
                    
                    // Name Section
                    HStack{
                        Spacer()
                        if isEditingName {
                            TextField("Task Name", text: $taskName, onCommit: {
                                isEditingName = false
                            })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 200)
                            .onSubmit {
                                isEditingName = false
                            }
                            .onDisappear {
                                isEditingName = false
                            }
                            .autocapitalization(.sentences)
                        } else {
                            Text(taskName)
                                .onTapGesture {
                                    isEditingName = true
                                }
                                .font(.headline)
                        }
                        Spacer()
                    }
                    
                    ScrollView{
                        
                        // Task Description
                        VStack{
                            // Title
                            Text("Task Description")
                            // Input Box
                            TextEditor(text: $taskDescription)
                                .padding(8)
                                .frame(minHeight: 100, maxHeight: 100)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.white))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                        
                        VStack(spacing: 20) {
                            // Task Length
                            VStack{
                                Text("Task Length")
                                HStack {
                                    let hours = Int(taskLengthSeconds) / 3600
                                    let mins = (Int(taskLengthSeconds) % 3600) / 60
                                    Text("\(hours) hr \(mins) min")
                                    Button("Change") {
                                        pickerHours = hours
                                        pickerMins = mins
                                        showTimePicker = true
                                    }
                                    .padding(.leading, 8)
                                }
                            }
                            
                            // Task Date
                            VStack{
                                Text("Task Date")
                                HStack {
                                    Text(taskDate, style: .date)
                                    Button("Today") {
                                        taskDate = Date()
                                    }
                                    .padding(.leading, 8)
                                    Button("Change") {
                                        showDatePicker.toggle()
                                    }
                                    .padding(.leading, 8)
                                }
                                if showDatePicker {
                                    DatePicker("Select Date", selection: $taskDate, displayedComponents: .date)
                                        .datePickerStyle(GraphicalDatePickerStyle())
                                        .labelsHidden()
                                        .padding(.top, 4)
                                }
                            }
                            
                            // Task Frequency
                            VStack{
                                Text("Task Frequency")
                                Picker("Frequency", selection: $selectedFrequency) {
                                    ForEach(TaskFrequencyOption.allCases) { option in
                                        Text(option.rawValue).tag(option)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding(.vertical, 4)
                                // Days of the week buttons
                                HStack(spacing: 8) {
                                    ForEach(0..<7) { day in
                                        Button(action: {
                                            if selectedDays.contains(day) {
                                                selectedDays.remove(day)
                                            } else {
                                                selectedDays.insert(day)
                                            }
                                        }) {
                                            Text(weekDays[day])
                                                .fontWeight(.bold)
                                                .frame(width: 40, height: 40)
                                                .background(selectedDays.contains(day) ? Color.accentColor : Color(.systemGray5))
                                                .foregroundColor(selectedDays.contains(day) ? .white : .primary)
                                                .clipShape(Circle())
                                        }
                                    }
                                }
                            }
                            
                            // Task Frequency
                            VStack{
                                Text("Reminders")
                            }
                            
                            
                            Spacer()
                        }
                    }
                    
                    // Create Task Button
                    VStack {
                        Button(action: {
                            // Validation
                            guard !taskName.trimmingCharacters(in: .whitespaces).isEmpty else {
                                validationMessage = "Task name cannot be empty."
                                showValidationAlert = true
                                return
                            }
                            guard selectedCategory != nil else {
                                validationMessage = "Please select a category."
                                showValidationAlert = true
                                return
                            }
                            guard taskLengthSeconds > 0 else {
                                validationMessage = "Please set a task length."
                                showValidationAlert = true
                                return
                            }
                            // Create TaskModel
                            let newTask = TaskModel(
                                name: taskName,
                                description: taskDescription,
                                lengthMins: taskLengthSeconds,
                                frequency: .none, // You can map selectedFrequency to TaskFrequency if needed
                                category: selectedCategory ?? .other,
                                energy: max(1, energyLevel),
                                taskDate: taskDate
                            )
                            user.addTask(newTask)
                            dismiss()
                        }) {
                            Text("Create Task")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(12)
                                .padding(.horizontal, 80)
                                .padding(.vertical, 10)
                        }
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .alert(isPresented: $showValidationAlert) {
                        Alert(title: Text("Invalid Task"), message: Text(validationMessage), dismissButton: .default(Text("OK")))
                    }
                }
            
            }.background {
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    topTrailingRadius: 20
                )
                .fill(.gray)
                .ignoresSafeArea()
            }
        }.background(Image("fishBackground").resizable().edgesIgnoringSafeArea(.all))
        // Time Picker Sheet
        .sheet(isPresented: $showTimePicker) {
            VStack {
                HStack {
                    Picker("Hours", selection: $pickerHours) {
                        ForEach(0..<13) { hour in
                            Text("\(hour) hr").tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                    Picker("Minutes", selection: $pickerMins) {
                        ForEach(0..<60) { min in
                            Text("\(min) min").tag(min)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                }
                .padding()
                Button("Done") {
                    // Update the TimeInterval
                    taskLengthSeconds = TimeInterval(pickerHours * 3600 + pickerMins * 60)
                    showTimePicker = false
                }
                .padding()
            }
            .presentationDetents([.height(250)])
        }
    }
}


#Preview {
    NewTaskView()
        .environmentObject(UserModel(name: "John Doe", email: "john@example.com"))
}
