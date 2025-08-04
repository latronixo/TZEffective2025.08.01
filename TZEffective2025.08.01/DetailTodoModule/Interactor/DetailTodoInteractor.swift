//
//  DetailTodoInteractor.swift
//  TZEffective2025.08.01
//
//  Created by Валентин on 03.08.2025.
//

import Foundation

protocol DetailTodoInteractorInput {
    var output: DetailTodoInteractorOutput? { get set }
    func loadTodo()
    func saveTodo(title: String, description: String)
}

protocol DetailTodoInteractorOutput: AnyObject {
    func didLoadTodo(_ todo: TodoItemViewModel)
    func didSaveTodo(id: Int, title: String, description: String)
    func didReceiveError(_ error: String)
}

final class DetailTodoInteractor: DetailTodoInteractorInput {
    var output: DetailTodoInteractorOutput?
    
    private let todo: TodoItemViewModel
    private let coreDataService: TodoCoreDataServiceProtocol
    
    init(todo: TodoItemViewModel, coreDataService: TodoCoreDataServiceProtocol) {
        self.todo = todo
        self.coreDataService = coreDataService
    }
    
    func loadTodo() {
        output?.didLoadTodo(todo)
    }
    
    func saveTodo(title: String, description: String) {
        coreDataService.updateTodo(id: todo.id, title: title, description: description)
        output?.didSaveTodo(id: todo.id, title: title, description: description)
    }
}

