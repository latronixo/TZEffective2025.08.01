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
    func updateTodoCompletion(id: Int, isCompleted: Bool)
    func updateTodo(id: Int, title: String, description: String)
    func deleteTodo(_ id: Int)
    func createTodo(title: String, description: String) -> Int
}

class TodoCoreDataService: TodoCoreDataServiceProtocol {
    private let container: NSPersistentContainer
    private let userDefaults = UserDefaults.standard
    private let firstLaunchKey = "isFirstLaunch"
    
    init() {
        container = NSPersistentContainer(name: "TodoDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    func saveTodos(_ todos: [TodoItemAPI]) {
        let context = container.viewContext
        
        for todo in todos {
            let todoItem = NSEntityDescription.insertNewObject(forEntityName: "TodoItem", into: context)
            todoItem.setValue(todo.id, forKey: "id")
            todoItem.setValue(todo.todo, forKey: "title")
            todoItem.setValue(todo.todo, forKey: "describe")
            todoItem.setValue(todo.completed, forKey: "completed")
            todoItem.setValue(todo.userId, forKey: "userId")
            todoItem.setValue(Date(), forKey: "createdAt")
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving todos: \(error)")
        }
    }
    
    func fetchTodos() -> [NSManagedObject] {
        let context = container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "TodoItem")
        
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
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
    
    func updateTodoCompletion(id: Int, isCompleted: Bool) {
        let context = container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "TodoItem")
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let results = try context.fetch(request)
            if let todoItem = results.first {
                todoItem.setValue(isCompleted, forKey: "completed")
                try context.save()
            }
        } catch {
            print("Error updating todo completion: \(error)")
        }
    }
    
    func updateTodo(id: Int, title: String, description: String) {
        let context = container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "TodoItem")
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let results = try context.fetch(request)
            if let todoItem = results.first {
                todoItem.setValue(title, forKey: "title")
                todoItem.setValue(description, forKey: "describe")
                try context.save()
            }
        } catch {
            print("Error updating todo: \(error)")
        }
    }
    
    func deleteTodo(_ id: Int) {
        let context = container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "TodoItem")
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let results = try context.fetch(request)
            if let todoItem = results.first {
                context.delete(todoItem)
                try context.save()
            }
        } catch {
            print("Error deleting todo: \(error)")
        }
    }
    
    func createTodo(title: String, description: String) -> Int {
        let context = container.viewContext
        let todoItem = NSEntityDescription.insertNewObject(forEntityName: "TodoItem", into: context)
        
        //генерируем новый id
        let maxId = fetchMaxId()
        let newId = maxId + 1
        
        todoItem.setValue(newId, forKey: "id")
        todoItem.setValue(title, forKey: "title")
        todoItem.setValue(description, forKey: "describe")
        todoItem.setValue(false, forKey: "completed")
        todoItem.setValue(1, forKey: "userId")
        todoItem.setValue(Date(), forKey: "createdAt")

        do {
            try context.save()
            return newId
        } catch {
            print("Error creating todo: \(error)")
            return 0
        }
    }
    private func fetchMaxId() -> Int {
        let context = container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "TodoItem")
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first?.value(forKey: "id") as? Int ?? 0
        } catch {
            print("Error fetching max id: \(error)")
            return 0
        }
    }
}
