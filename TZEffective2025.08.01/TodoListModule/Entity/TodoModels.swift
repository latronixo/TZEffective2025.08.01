//
//  TodoModels.swift
//  TZEffective2025.08.01
//
//  Created by Валентин on 02.08.2025.
//

import Foundation

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
        self.describe = ""
        self.isCompleted = apiItem.completed
        self.createdAt = Date()
        self.userId = apiItem.userId
    }
    
    init(from coreDataItem: TodoItem) {
        self.id = Int(coreDataItem.id)
        self.title = coreDataItem.title ?? ""
        self.describe = ""
        self.isCompleted = coreDataItem.completed
        self.createdAt = coreDataItem.createdAt
        self.userId = Int(coreDataItem.userId)
    }
}
