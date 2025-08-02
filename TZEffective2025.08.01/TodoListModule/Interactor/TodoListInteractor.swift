//
//  TodoListInteractor.swift
//  TZEffective2025.08.01
//
//  Created by Валентин on 02.08.2025.
//

import Foundation
import CoreData

protocol TodoListInteractorInput {
    var output: TodoListInteractorOutput? { get set }
    func loadTodos()
    func searchTodos(with query: String)
    func toggleTodoCompletion(id: Int)
}

protocol TodoListInteractorOutput: AnyObject {
    func didLoadTodos(_ todos: [TodoItemViewModel])
    func didReceiveError(_ error: String)
    func didUpdateTodos(_ todos: [TodoItemViewModel])
}

final class TodoListInteractor: TodoListInteractorInput {
    weak var output: TodoListInteractorOutput?
    
    private let networkService: TodoNetworkServiceProtocol
    private let coreDataService: TodoCoreDataServiceProtocol
    private var allTodos: [TodoItemViewModel] = []
    
    init(networkService: TodoNetworkServiceProtocol, coreDataService: TodoCoreDataServiceProtocol) {
        self.networkService = networkService
        self.coreDataService = coreDataService
    }
    
    func loadTodos() {
        if coreDataService.isFirstLaunch() {
            loadTodosFromAPI()
        } else {
            loadTodosFromCoreData()
        }
    }
    
    private func loadTodosFromAPI() {
        networkService.fetchTodos { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let todoViewModels = response.todos.map { TodoItemViewModel(from: $0) }
                    self?.allTodos = todoViewModels
                    self?.coreDataService.saveTodos(response.todos)
                    self?.coreDataService.markAsFirstLaunch()
                    self?.output?.didLoadTodos(todoViewModels)
                case .failure(let error):
                    self?.output?.didReceiveError(error.localizedDescription)
                }
            }
        }
    }
    
    private func loadTodosFromCoreData() {
        let coreDataItems = coreDataService.fetchTodos()
        let todoViewModels = coreDataItems.map { TodoItemViewModel(from: $0) }
        self.allTodos = todoViewModels
        self.output?.didLoadTodos(todoViewModels)
    }
    
    func searchTodos(with query: String) {
        if query.isEmpty {
            output?.didUpdateTodos(allTodos)
        } else {
            let filteredTodos = allTodos.filter { todo in
                todo.title.localizedCaseInsensitiveContains(query) || 
                todo.describe.localizedCaseInsensitiveContains(query)
            }
            output?.didUpdateTodos(filteredTodos)
        }
    }
    
    func toggleTodoCompletion(id: Int) {
        if let index = allTodos.firstIndex(where: { $0.id == id }) {
            let newCompletedState = !allTodos[index].isCompleted
                    
            allTodos[index] = TodoItemViewModel(
                id: allTodos[index].id,
                title: allTodos[index].title,
                describe: allTodos[index].describe,
                isCompleted: newCompletedState,
                createdAt: allTodos[index].createdAt,
                userId: allTodos[index].userId
            )
                    
            coreDataService.updateTodoCompletion(id: id, isCompleted: newCompletedState)
                    
            output?.didUpdateTodos(allTodos)
        }
    }
}
