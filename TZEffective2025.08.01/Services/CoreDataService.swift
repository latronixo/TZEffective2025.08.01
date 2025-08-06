//
//  CoreDataService.swift
//  TZEffective2025.08.01
//
//  Created by Валентин on 02.08.2025.
//

import Foundation
import CoreData

protocol CoreDataServiceProtocol {
    func saveTodos(_ todos: [TodoItemAPI])
    func fetchTodos(completion: @escaping ([NSManagedObject]) -> Void)
    func updateTodoCompletion(id: Int, isCompleted: Bool)
    func updateTodo(id: Int, title: String, description: String)
    func deleteTodo(_ id: Int)
    func createTodo(title: String, description: String, completion: @escaping(Int) -> Void)
}

class CoreDataService: CoreDataServiceProtocol {
    private let container: NSPersistentContainer
    private let backgroundQueue = DispatchQueue(label: "com.todo.coredata.queue", qos: .background)
        
    init() {
        container = NSPersistentContainer(name: "TodoDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    func saveTodos(_ todos: [TodoItemAPI]) {
        backgroundQueue.async { [weak self] in
            guard let context = self?.container.viewContext else { return }
            
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
    }
    
    func fetchTodos(completion: @escaping ([NSManagedObject]) -> Void) {
        backgroundQueue.async { [weak self] in
            guard let context = self?.container.viewContext else { return }
            let request = NSFetchRequest<NSManagedObject>(entityName: "TodoItem")
            
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            
            do {
                let result = try context.fetch(request)
                completion(result)
            } catch {
                print("Error fetching todos: \(error)")
                completion([])
            }
        }
    }
    
    func updateTodoCompletion(id: Int, isCompleted: Bool) {
        backgroundQueue.async { [weak self] in
            guard let context = self?.container.viewContext else { return }
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
    }
    
    func updateTodo(id: Int, title: String, description: String) {
        backgroundQueue.async { [weak self] in
            guard let context = self?.container.viewContext else { return }
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
    }
    
    func deleteTodo(_ id: Int) {
        backgroundQueue.async { [weak self] in
            guard let context = self?.container.viewContext else { return }
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
    }
    
    func createTodo(title: String, description: String, completion: @escaping(Int) -> Void) {
        backgroundQueue.async { [weak self] in
            guard let context = self?.container.viewContext else { return }
            let todoItem = NSEntityDescription.insertNewObject(forEntityName: "TodoItem", into: context)
            
            //генерируем новый id
            var maxId = 0
            
            let request = NSFetchRequest<NSManagedObject>(entityName: "TodoItem")
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
            request.fetchLimit = 1
            
            do {
                let results = try context.fetch(request)
                maxId = results.first?.value(forKey: "id") as? Int ?? 0
            } catch {
                print("Error fetching max id: \(error)")
            }
            
            let newId = maxId + 1
            
            todoItem.setValue(newId, forKey: "id")
            todoItem.setValue(title, forKey: "title")
            todoItem.setValue(description, forKey: "describe")
            todoItem.setValue(false, forKey: "completed")
            todoItem.setValue(1, forKey: "userId")
            todoItem.setValue(Date(), forKey: "createdAt")
            
            do {
                try context.save()
                completion(newId)
            } catch {
                print("Error creating todo: \(error)")
                completion(0)
            }
        }
    }
}
