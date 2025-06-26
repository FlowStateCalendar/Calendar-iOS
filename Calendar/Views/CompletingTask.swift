//
//  CompletingTask.swift
//  Calendar
//
//  Created by Rhyse Summers on 10/06/2025.
//

import SwiftUI

struct CompletingTask: View {
    @ObservedObject var task: TaskModel
    @State private var timeRemaining: TimeInterval
    @State private var timerActive = false
    @State private var timer: Timer? = nil

    init(task: TaskModel) {
        self.task = task
        // Use the task's lengthMins as the timer duration (in seconds)
        _timeRemaining = State(initialValue: task.lengthMins)
    }

    var percentage: Double {
        guard task.lengthMins > 0 else { return 1.0 }
        return 1.0 - (timeRemaining / task.lengthMins)
    }

    var body: some View {
        VStack {
            UserBar()
            Text("Current Task")
                .font(.title)
                .padding(.top)
            Spacer()
            VStack(spacing: 24) {
                Text(task.name)
                    .font(.headline)
                Text(timeString)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .padding()
                ProgressView(value: percentage)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.horizontal, 40)
                Text("\(Int(percentage * 100))% Complete")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: startTimer) {
                Text(timerActive ? "Pause" : (timeRemaining == 0 ? "Restart" : "Start"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
            }
        }
        .background(Color(.teal).ignoresSafeArea())
        .onDisappear { timer?.invalidate() }
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

    private func startTimer() {
        if timeRemaining == 0 {
            timeRemaining = task.lengthMins
        }
        timerActive.toggle()
        if timerActive {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer?.invalidate()
                    timerActive = false
                }
            }
        } else {
            timer?.invalidate()
        }
    }
}

#Preview {
    CompletingTask(task: TaskModel.sampleTasks[0])
        .environmentObject(UserModel.createSampleUser())
}
