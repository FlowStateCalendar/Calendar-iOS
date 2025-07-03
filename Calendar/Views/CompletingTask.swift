//
//  CompletingTask.swift
//  Calendar
//
//  Created by Rhyse Summers on 10/06/2025.
//

import SwiftUI

enum TaskState {
    case notStarted
    case running
    case paused
    case completed
}

struct CompletingTask: View {
    @ObservedObject var task: TaskModel
    @EnvironmentObject var user: UserModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var timeRemaining: TimeInterval
    @State private var taskState: TaskState = .notStarted
    @State private var timer: Timer? = nil
    @State private var totalTimeWorked: TimeInterval = 0
    @State private var showCompletionAlert = false
    @State private var earnedXP: Int = 0
    @State private var earnedCoins: Int = 0

    init(task: TaskModel) {
        self.task = task
        // Use the task's lengthMins as the timer duration (in seconds)
        _timeRemaining = State(initialValue: task.lengthMins)
    }

    var percentage: Double {
        guard task.lengthMins > 0 else { return 1.0 }
        return 1.0 - (timeRemaining / task.lengthMins)
    }
    
    var buttonTitle: String {
        switch taskState {
        case .notStarted:
            return "Start Task"
        case .running:
            return "Pause"
        case .paused:
            return "Resume"
        case .completed:
            return "Restart"
        }
    }
    
    var buttonColor: Color {
        switch taskState {
        case .notStarted:
            return .green
        case .running:
            return .orange
        case .paused:
            return .blue
        case .completed:
            return .green
        }
    }

    var body: some View {
        VStack {
            UserBar()
            
            // Header
            VStack(spacing: 8) {
                Text("Current Task")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(task.name)
                    .font(.title2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top)
            
            Spacer()
            
            // Main content
            VStack(spacing: 32) {
                // Timer display
                VStack(spacing: 16) {
                    Text(timeString)
                        .font(.system(size: 64, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    // Progress bar
                    VStack(spacing: 8) {
                        ProgressView(value: percentage)
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                            .scaleEffect(y: 2)
                            .padding(.horizontal, 40)
                        
                        Text("\(Int(percentage * 100))% Complete")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                // Task info
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: task.category.filledIconName)
                            .foregroundColor(.white)
                        Text(task.category.displayName)
                            .foregroundColor(.white)
                        Spacer()
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { i in
                                Image(systemName: i <= task.energy ? "bolt.fill" : "bolt")
                                    .foregroundColor(i <= task.energy ? .yellow : .white.opacity(0.5))
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    if !task.taskDescription.isEmpty {
                        Text(task.taskDescription)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                
                // Reward preview
                if taskState == .notStarted {
                    VStack(spacing: 8) {
                        Text("Rewards")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 20) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.orange)
                                Text("\(RewardCalculator.xp(for: task)) XP")
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Image(systemName: "dollarsign.ring")
                                    .foregroundColor(.yellow)
                                Text("\(RewardCalculator.coins(for: task)) Coins")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            Spacer()
            
            // Control buttons
            VStack(spacing: 16) {
                // Main action button
                Button(action: handleMainAction) {
                    HStack {
                        Image(systemName: buttonIcon)
                        Text(buttonTitle)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(buttonColor)
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
                }
                
                // Secondary buttons
                if taskState == .running || taskState == .paused {
                    HStack(spacing: 16) {
                        Button(action: completeTask) {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text(percentage >= 1.0 ? "Complete" : "End Task")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .background(Image("fishBackground").resizable().edgesIgnoringSafeArea(.all))
        .onDisappear {
            timer?.invalidate()
        }
        .alert("Task Completed!", isPresented: $showCompletionAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Great job! You've earned \(earnedXP) XP and \(earnedCoins) coins.")
        }
    }
    
    private var buttonIcon: String {
        switch taskState {
        case .notStarted:
            return "play.fill"
        case .running:
            return "pause.fill"
        case .paused:
            return "play.fill"
        case .completed:
            return "arrow.clockwise"
        }
    }

    private var timeString: String {
        let totalSeconds = max(Int(timeRemaining), 0)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    private func handleMainAction() {
        switch taskState {
        case .notStarted:
            startTask()
        case .running:
            pauseTask()
        case .paused:
            resumeTask()
        case .completed:
            resetTask()
        }
    }
    
    private func startTask() {
        taskState = .running
        startTimer()
    }
    
    private func pauseTask() {
        taskState = .paused
        timer?.invalidate()
    }
    
    private func resumeTask() {
        taskState = .running
        startTimer()
    }
    
    private func resetTask() {
        timer?.invalidate()
        timeRemaining = task.lengthMins
        totalTimeWorked = 0
        taskState = .notStarted
    }
    
    private func completeTask() {
        timer?.invalidate()
        taskState = .completed
        timeRemaining = 0
        
        // Calculate completion percentage for reward calculation
        let completionPercentage = 1.0 - (timeRemaining / task.lengthMins)
        
        // Award rewards based on completion percentage
        let xpEarned = RewardCalculator.xp(for: task, completion: completionPercentage)
        let coinsEarned = RewardCalculator.coins(for: task, completion: completionPercentage)
        
        // Add rewards to user
        user.addXP(xpEarned)
        user.coins += coinsEarned
        
        earnedXP = Int(xpEarned)
        earnedCoins = Int(coinsEarned)
        
        showCompletionAlert = true
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                totalTimeWorked += 1
            } else {
                timer?.invalidate()
                taskState = .completed
                
                // Award rewards
                user.awardXPForTask(task)
                user.awardCoinsForTask(task)
                
                showCompletionAlert = true
            }
        }
    }
}

#Preview {
    CompletingTask(task: TaskModel.sampleTasks[0])
        .environmentObject(UserModel.createSampleUser())
}
