//
//  TodoModels.swift
//  TZEffective2025.08.01
//
//  Created by Валентин on 02.08.2025.
//

import Foundation
import CoreData

// MARK: - API Models
struct TodoResponse: Codable {
    let todos: [TodoItemAPI]
    let total: Int
    let skip: Int
    let limit: Int
}

struct TodoItemAPI: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

// MARK: - View Models
struct TodoItemViewModel: Identifiable {
    let id: Int
    let title: String
    let describe: String
    let isCompleted: Bool
    let createdAt: Date
    let userId: Int
    
    init(from apiItem: TodoItemAPI) {
        self.id = apiItem.id
        self.title = apiItem.todo
        self.describe = apiItem.todo
        self.isCompleted = apiItem.completed
        self.createdAt = Date()
        self.userId = apiItem.userId
    }
    
    init(from coreDataItem: NSManagedObject) {
        self.id = coreDataItem.value(forKey: "id") as? Int ?? 0
        self.title = coreDataItem.value(forKey: "title") as? String ?? ""
        self.describe = coreDataItem.value(forKey: "describe") as? String ?? ""
        self.isCompleted = coreDataItem.value(forKey: "completed") as? Bool ?? false
        self.createdAt = coreDataItem.value(forKey: "createdAt") as? Date ?? Date ()
        self.userId = coreDataItem.value(forKey: "userId") as? Int ?? 0
    }
    
    init(id: Int, title: String, describe: String, isCompleted: Bool, createdAt: Date, userId: Int) {
        self.id = id
        self.title = title
        self.describe = describe
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.userId = userId
    }
}
