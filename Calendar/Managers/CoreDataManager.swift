//
//  CoreDataManager.swift
//  Calendar
//
//  Created by Rhyse Summers on 10/06/2025.
//

//import Foundation
//import CoreData
//import SwiftUI
//
//class CoreDataManager: ObservableObject {
//    static let shared = CoreDataManager()
//    
//    lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "CalendarDataModel")
//        container.loadPersistentStores { _, error in
//            if let error = error {
//                fatalError("Core Data store failed to load: \(error)")
//            }
//        }
//        return container
//    }()
//    
//    var context: NSManagedObjectContext {
//        persistentContainer.viewContext
//    }
//    
//    private init() {}
//    
//    // MARK: - Save Context
//    func save() {
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                print("Error saving Core Data context: \(error)")
//            }
//        }
//    }
//    
//    // MARK: - User Management
//    func saveUser(_ user: UserModel) {
//        // Delete existing user first
//        deleteAllUsers()
//        
//        let userEntity = UserEntity(context: context)
//        userEntity.id = user.id
//        userEntity.name = user.name
//        userEntity.email = user.email
//        userEntity.profileURL = user.profile?.absoluteString
//        userEntity.createdAt = user.createdAt
//        
//        // Save tasks
//        for task in user.tasks {
//            let taskEntity = TaskEntity(context: context)
//            taskEntity.id = task.id
//            taskEntity.name = task.name
//            taskEntity.taskDescription = task.description
//            taskEntity.category = task.category.rawValue
//            taskEntity.energy = Int16(task.energy)
//            taskEntity.taskDate = task.taskDate
//            taskEntity.user = userEntity
//        }
//        
//        save()
//    }
//    
//    func loadUser() -> UserModel? {
//        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
//        
//        do {
//            let userEntities = try context.fetch(request)
//            guard let userEntity = userEntities.first else { return nil }
//            
//            let user = UserModel(name: userEntity.name ?? "", email: userEntity.email ?? "")
//            user.id = userEntity.id ?? UUID()
//            user.profile = URL(string: userEntity.profileURL ?? "")
//            user.createdAt = userEntity.createdAt ?? Date()
//            
//            // Load tasks
//            if let taskEntities = userEntity.tasks?.allObjects as? [TaskEntity] {
//                for taskEntity in taskEntities {
//                    let task = TaskModel(
//                        name: taskEntity.name ?? "",
//                        description: taskEntity.taskDescription ?? "",
//                        frequency: .none, // You'd need to store this
//                        category: TaskCategory(rawValue: taskEntity.category ?? "") ?? .personal,
//                        energy: Int(taskEntity.energy),
//                        taskDate: taskEntity.taskDate ?? Date()
//                    )
//                    task.id = taskEntity.id ?? UUID()
//                    user.tasks.append(task)
//                }
//            }
//            
//            return user
//        } catch {
//            print("Error loading user from Core Data: \(error)")
//            return nil
//        }
//    }
//    
//    func deleteAllUsers() {
//        let request: NSFetchRequest<NSFetchRequestResult> = UserEntity.fetchRequest()
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
//        
//        do {
//            try context.execute(deleteRequest)
//            save()
//        } catch {
//            print("Error deleting users: \(error)")
//        }
//    }
//} 
