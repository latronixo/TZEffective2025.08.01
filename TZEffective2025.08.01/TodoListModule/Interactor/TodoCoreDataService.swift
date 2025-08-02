//
//  TodoCoreDataService.swift
//  TZEffective2025.08.01
//
//  Created by Валентин on 02.08.2025.
//

import Foundation
import CoreData

protocol TodoCoreDataServiceProtocol {
    func saveTodos(_ todos: [TodoItemAPI])
    func fetchTodos() -> [NSManagedObject]
    func deleteAllTodos()
    func isFirstLaunch() -> Bool
    func markAsFirstLaunch()
}

class TodoCoreDataService: TodoCoreDataServiceProtocol {
    private let container: NSPersistentContainer
    private let userDefaults = UserDefaults.standard
    private let firstLaunchKey = "isFirstlaunc"
    
    init() {
        container = NSPersistentContainer(name: "TZEffective2025_08_01")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchTodos() -> [NSManagedObject] {
        let context = container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "TodoItem")
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching todos: \(error)")
            return []
        }
    }
    
    func deleteAllTodos() {
        let context = container.viewContext
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TodoItem")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Error deleting todos: \(error)")
        }
    }
    
    func isFirstLaunch() -> Bool {
        return !userDefaults.bool(forKey: firstLaunchKey)
    }
    
    func markAsFirstLaunch() {
        userDefaults.set(true, forKey: firstLaunchKey)
    }

    
    
    
    
}
