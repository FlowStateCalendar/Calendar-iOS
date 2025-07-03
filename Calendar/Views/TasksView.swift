//
//  TasksView.swift
//  Calendar
//
//  Created by Rhyse Summers on 06/06/2025.
//

import SwiftUI

// MARK: - Responsive Design System
/// A comprehensive responsive design system that adapts to different device sizes
/// Similar to Tailwind CSS breakpoints but optimized for iOS devices
struct ResponsiveDesign {
    static let shared = ResponsiveDesign()
    
    /// Screen size breakpoints that determine layout and sizing
    /// These are based on common iOS device screen widths
    enum Breakpoint {
        case sm   // < 375 (iPhone SE, iPhone mini)
        case md   // 375-768 (iPhone 12/13/14/15, iPhone Pro)
        case lg   // 768-1024 (iPad, iPad Air, iPad mini)
        case xl   // > 1024 (iPad Pro 11", iPad Pro 12.9")
    }
    
    /// Determines the appropriate breakpoint based on screen width
    /// This is the foundation of the responsive system
    static func breakpoint(for size: CGSize) -> Breakpoint {
        let width = size.width
        if width < 375 { return .sm }      // Compact phones
        if width < 768 { return .md }      // Standard phones
        if width < 1024 { return .lg }     // iPads
        return .xl                         // Large iPads
    }
    
    /// Container sizing system that adapts to different screen sizes
    /// Provides consistent, proportional sizing across all devices
    struct Container {
        /// Calculates the optimal width for containers based on device size
        /// Uses percentage-based sizing with maximum constraints for larger screens
        static func width(for size: CGSize) -> CGFloat {
            let breakpoint = ResponsiveDesign.breakpoint(for: size)
            let screenWidth = size.width
            
            switch breakpoint {
            case .sm:
                return screenWidth * 0.95 // 95% of screen width - compact phones need more space
            case .md:
                return screenWidth * 0.92 // 92% of screen width - standard phones
            case .lg:
                return min(screenWidth * 0.85, 600) // 85% or max 600pt - iPads get constrained width
            case .xl:
                return min(screenWidth * 0.80, 700) // 80% or max 700pt - large iPads get max constraint
            }
        }
        
        /// Calculates the optimal height for containers based on device size
        /// HEIGHT RESPONSIVENESS: This is where iPad height responsiveness happens!
        /// Different devices get different height percentages to optimize content fit
        static func height(for size: CGSize) -> CGFloat {
            let breakpoint = ResponsiveDesign.breakpoint(for: size)
            let screenHeight = size.height
            
            switch breakpoint {
            case .sm:
                return screenHeight * 0.85 // 85% - compact phones need more height for content
            case .md:
                return screenHeight * 0.88 // 88% - standard phones get balanced height
            case .lg:
                return screenHeight * 0.90 // 90% - iPads get more height for better content display
            case .xl:
                return screenHeight * 0.92 // 92% - large iPads get maximum height utilization
            }
        }
        
        /// Provides appropriate corner radius based on device size
        /// Larger devices get slightly larger corner radius for better proportions
        static func cornerRadius(for size: CGSize) -> CGFloat {
            let breakpoint = ResponsiveDesign.breakpoint(for: size)
            switch breakpoint {
            case .sm: return 16 // Compact phones
            case .md: return 18 // Standard phones
            case .lg: return 20 // iPads
            case .xl: return 22 // Large iPads
            }
        }
        
        /// Provides responsive padding that scales with device size
        /// Larger devices get more padding for better visual balance
        static func padding(for size: CGSize) -> EdgeInsets {
            let breakpoint = ResponsiveDesign.breakpoint(for: size)
            switch breakpoint {
            case .sm:
                return EdgeInsets(top: 16, leading: 12, bottom: 16, trailing: 12) // Compact padding
            case .md:
                return EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16) // Standard padding
            case .lg:
                return EdgeInsets(top: 24, leading: 20, bottom: 24, trailing: 20) // iPad padding
            case .xl:
                return EdgeInsets(top: 28, leading: 24, bottom: 28, trailing: 24) // Large iPad padding
            }
        }
    }
}

// MARK: - Responsive Grid Configuration
/// Configures the task grid layout based on device capabilities
/// Determines columns, rows, circle sizes, and spacing for optimal display
struct ResponsiveGridConfig {
    let columns: Int
    let rows: Int
    let itemsPerPage: Int
    let circleSize: CGFloat
    let spacing: CGFloat
    
    /// Creates the optimal grid configuration for a given device size
    /// This is where the magic happens - different devices get different layouts!
    static func forDevice(size: CGSize) -> ResponsiveGridConfig {
        let breakpoint = ResponsiveDesign.breakpoint(for: size)
        
        switch breakpoint {
        case .xl:
            // Large iPad (12.9" Pro, etc.) - Maximum content density
            return ResponsiveGridConfig(
                columns: 4,        // 4 columns for wide screen
                rows: 4,          // 4 rows for tall screen
                itemsPerPage: 16, // 16 items total (4x4 grid)
                circleSize: 160,  // Large circles for big screen
                spacing: 40       // Generous spacing
            )
        case .lg:
            // Regular iPad (iPad Air, iPad mini, 11" Pro) - Balanced layout
            return ResponsiveGridConfig(
                columns: 3,        // 3 columns for medium width
                rows: 3,          // 3 rows for medium height
                itemsPerPage: 9,  // 9 items total (3x3 grid)
                circleSize: 150,  // Medium-large circles
                spacing: 35       // Good spacing
            )
        case .md:
            // iPhone (Standard) - Compact but functional
            return ResponsiveGridConfig(
                columns: 2,        // 2 columns for narrow screen
                rows: 3,          // 3 rows for reasonable height
                itemsPerPage: 6,  // 6 items total (2x3 grid)
                circleSize: 140,  // Medium circles
                spacing: 30       // Standard spacing
            )
        case .sm:
            // Compact iPhone (SE, mini) - Optimized for small screens
            return ResponsiveGridConfig(
                columns: 2,        // 2 columns (same as standard)
                rows: 3,          // 3 rows (same as standard)
                itemsPerPage: 6,  // 6 items total (2x3 grid)
                circleSize: 130,  // Slightly smaller circles
                spacing: 25       // Tighter spacing
            )
        }
    }
}

// MARK: - Task Item Structure
/// Represents a single task item in the grid
/// Can be either a real task or a filler item for empty slots
struct TaskItem: Identifiable {
    let id = UUID()
    let task: TaskModel?
    let isFiller: Bool
    
    init(task: TaskModel?) {
        self.task = task
        self.isFiller = task == nil
    }
}

// MARK: - Task Circle Component
/// Individual task circle that displays task information
/// Uses proportional sizing based on the circle size parameter
struct TaskCircle: View {
    let taskItem: TaskItem
    let onTaskTap: (TaskModel) -> Void
    let onAddTaskTap: () -> Void
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Main circle background
            Circle()
                .fill(taskItem.isFiller ? Color.gray.opacity(0.3) : Color.green)
                .frame(width: size, height: size)
            
            // Content inside the circle - all elements scale proportionally
            VStack(spacing: size * 0.06) { // Proportional spacing: 6% of circle size
                // Category icon - scales with circle size
                Image(systemName: taskItem.isFiller ? "plus.circle" : taskItem.task?.category.filledIconName ?? "questionmark.circle")
                    .font(.system(size: size * 0.2)) // Icon = 20% of circle size
                    .foregroundColor(taskItem.isFiller ? .gray.opacity(0.5) : .white)
                    .padding(.top, size * 0.06) // Top padding = 6% of circle size
                
                // Task name text - scales with circle size
                Text(taskItem.isFiller ? "Add Task" : (taskItem.task?.name ?? "Unknown"))
                    .font(.system(size: size * 0.12, weight: .semibold)) // Text = 12% of circle size
                    .foregroundColor(taskItem.isFiller ? .gray.opacity(0.5) : .white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7) // Allows text to shrink if needed
                
                // Energy bolts - scale with circle size
                HStack(spacing: size * 0.01) { // Bolt spacing = 1% of circle size
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: getBoltIcon(for: i))
                            .foregroundColor(getBoltColor(for: i))
                            .font(.system(size: size * 0.11)) // Bolt = 11% of circle size
                    }
                }
                .padding(.bottom, size * 0.03) // Bottom padding = 3% of circle size
            }
            .frame(width: size * 0.85, height: size * 0.85) // Content area = 85% of circle size
        }
        .onTapGesture {
            if taskItem.isFiller {
                onAddTaskTap()
            } else if let task = taskItem.task {
                onTaskTap(task)
            }
        }
    }
    
    /// Returns the appropriate bolt icon (filled or empty)
    private func getBoltIcon(for index: Int) -> String {
        if taskItem.isFiller {
            return "bolt"
        }
        return index <= (taskItem.task?.energy ?? 0) ? "bolt.fill" : "bolt"
    }
    
    /// Returns the appropriate bolt color based on energy level
    private func getBoltColor(for index: Int) -> Color {
        if taskItem.isFiller {
            return .gray.opacity(0.3)
        }
        return index <= (taskItem.task?.energy ?? 0) ? .yellow : .white.opacity(0.5)
    }
}

// MARK: - Responsive Container View
/// A reusable container that automatically adapts to different screen sizes
/// Provides consistent styling and sizing across the app
struct ResponsiveContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            // Calculate responsive dimensions based on screen size
            let containerWidth = ResponsiveDesign.Container.width(for: geometry.size)
            let containerHeight = ResponsiveDesign.Container.height(for: geometry.size)
            let cornerRadius = ResponsiveDesign.Container.cornerRadius(for: geometry.size)
            let padding = ResponsiveDesign.Container.padding(for: geometry.size)
            
            ZStack {
                // Background rectangle with responsive styling
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .frame(width: containerWidth, height: containerHeight)
                
                // Content with responsive padding
                content
                    .padding(padding)
                    .frame(width: containerWidth, height: containerHeight)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Center the container
        }
    }
}

struct TasksView: View {
    @EnvironmentObject var user: UserModel
    @State private var selectedTask: TaskModel?
    @State private var showNewTaskView = false
    
    // Cache sample tasks to prevent regeneration on every view update
    @State private var cachedSampleTasks: [TaskModel] = []
    
    // Responsive configuration - will be set based on device size
    @State private var gridConfig: ResponsiveGridConfig?
    
    // Combine sample tasks and user tasks, removing duplicates by id
    var allTasks: [TaskModel] {
        let combined = cachedSampleTasks + user.tasks
        var seen = Set<UUID>()
        return combined.filter { seen.insert($0.id).inserted }
    }

    // Dynamic grid columns based on current configuration
    var gridColumns: [GridItem] {
        guard let config = gridConfig else { return [GridItem(.flexible()), GridItem(.flexible())] }
        return Array(repeating: GridItem(.flexible()), count: config.columns)
    }

    // Split tasks into pages with filler items for consistent grid layout
    var pages: [[TaskItem]] {
        guard let config = gridConfig else { return [] }
        
        return stride(from: 0, to: allTasks.count, by: config.itemsPerPage).map { startIndex in
            let endIndex = min(startIndex + config.itemsPerPage, allTasks.count)
            let pageTasks = Array(allTasks[startIndex..<endIndex])
            
            // Add filler items if page is not full to maintain grid structure
            var pageWithFillers = pageTasks.map { TaskItem(task: $0) }
            while pageWithFillers.count < config.itemsPerPage {
                pageWithFillers.append(TaskItem(task: nil)) // nil represents a filler circle
            }
            
            return pageWithFillers
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                UserBar()
                Text("Your Tasks")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Responsive container with task grid
                ResponsiveContainer {
                    // Task grid inside paged TabView for multiple pages
                    TabView {
                        ForEach(pages.indices, id: \.self) { index in
                            let page = pages[index]
                            LazyVGrid(columns: gridColumns, spacing: gridConfig?.spacing ?? 30) {
                                ForEach(page) { taskItem in
                                    TaskCircle(
                                        taskItem: taskItem,
                                        onTaskTap: { task in
                                            selectedTask = task
                                        },
                                        onAddTaskTap: {
                                            showNewTaskView = true
                                        },
                                        size: gridConfig?.circleSize ?? 140
                                    )
                                }
                            }
                            .padding(.vertical, 20) // Add vertical padding to prevent circle cutoff
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                }
                
                Spacer()
            }
        }
        .background(Image("fishBackground").resizable().edgesIgnoringSafeArea(.all))
        
        // Modal overlay for NewTaskView presentation
        .overlay(
            ZStack {
                if selectedTask != nil || showNewTaskView {
                    // Semi-transparent background for modal effect
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity) // Fade in/out for background
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTask = nil
                                showNewTaskView = false
                            }
                        }
                    
                    // Modal content with responsive sizing
                    GeometryReader { geometry in
                        let containerWidth = ResponsiveDesign.Container.width(for: geometry.size)
                        let containerHeight = ResponsiveDesign.Container.height(for: geometry.size)
                        let cornerRadius = ResponsiveDesign.Container.cornerRadius(for: geometry.size)
                        
                        ZStack {
                            // Modal background with shadow
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                                .frame(width: containerWidth, height: containerHeight)
                            
                            // NewTaskView content
                            if selectedTask != nil {
                                NewTaskView(taskToEdit: selectedTask!)
                                    .environmentObject(user)
                                    .frame(width: containerWidth, height: containerHeight)
                                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                            } else if showNewTaskView {
                                NewTaskView(taskToEdit: nil)
                                    .environmentObject(user)
                                    .frame(width: containerWidth, height: containerHeight)
                                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.1)
                                .combined(with: .opacity),
                            removal: .opacity
                        ))
                    }
                }
            }
        )
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedTask != nil || showNewTaskView)
        .onAppear {
            // Cache sample tasks only once when view appears
            if cachedSampleTasks.isEmpty {
                cachedSampleTasks = TaskModel.sampleTasks
            }
            
            // Initialize grid configuration based on current device size
            let size = UIScreen.main.bounds.size
            gridConfig = ResponsiveGridConfig.forDevice(size: size)
        }
    }
}

#Preview {
    TasksView()
        .environmentObject(UserModel(name: "Test User", email: "test@example.com"))
}
