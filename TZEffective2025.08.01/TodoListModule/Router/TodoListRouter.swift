//
//  TodoListRouter.swift
//  ViperExample
//
//  Created by Валентин on 31.07.2025.
//

import UIKit

protocol TodoListRouterInput {
    func openDetailScreen(with todo: TodoItemViewModel)
    func shareTodo(with todo: TodoItemViewModel)
    func openAddNewTodoScreen()
}

final class TodoListRouter: TodoListRouterInput {
    
    weak var rootViewController: UIViewController?
    private var coreDataService: CoreDataServiceProtocol
    
    init(coreDataService: CoreDataServiceProtocol) {
        self.coreDataService = coreDataService
    }
    
    func openDetailScreen(with todo: TodoItemViewModel) {
        let detailModule = DetailTodoAssembly.assembleDetailTodoModule(todo: todo, coreDataService: coreDataService)
        rootViewController?.present(detailModule, animated: true)
    }
    
    func shareTodo(with todo: TodoItemViewModel) {
        let text = "Задача: \(todo.title)\nОписание: \(todo.describe)"
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        rootViewController?.present(activityViewController, animated: true)
    }
    
    func openAddNewTodoScreen() {
        let detailModule = DetailTodoAssembly.assembleDetailTodoModule(todo: nil, coreDataService: coreDataService)
        rootViewController?.present(detailModule, animated: true)
    }
}
