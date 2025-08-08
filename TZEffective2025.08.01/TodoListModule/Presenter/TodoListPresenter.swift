//
//  TodoListPresenter.swift
//  TZEffective2025.08.01
//
//  Created by Валентин on 02.08.2025.
//

import Foundation

protocol TodoListPresenterInput {
    func viewDidLoad()
    func searchTextChanged(_ text: String)
    func todoToggled(id: Int)
    func updateTodoAfterEdit(id: Int, title: String, description: String)
}

final class TodoListPresenter {
    private let interactor: TodoListInteractorInput
    private let router: TodoListRouterInput
    private let view: TodoListViewInput
    
    init(interactor: TodoListInteractorInput, router: TodoListRouterInput, view: TodoListViewInput) {
        self.interactor = interactor
        self.router = router
        self.view = view
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(todoUpdated),
            name: NSNotification.Name("TodoUpdated"),
            object: nil
        )
    }
    
    @objc private func todoUpdated(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let id = userInfo["id"] as? Int,
              let title = userInfo["title"] as? String,
              let description = userInfo["description"] as? String else { return }
        
        if let isNew = userInfo["isNew"] as? Bool, isNew {
            interactor.loadTodos()
        } else {
            updateTodoAfterEdit(id: id, title: title, description: description)
        }
    }
}

extension TodoListPresenter: TodoUpdateListener {
    func update(model: TodoUpdateModel) {
        if model.isNew {
            interactor.loadTodos()
        } else {
            updateTodoAfterEdit(id: model.id, title: model.title, description: model.description)
        }
    }
}

extension TodoListPresenter: TodoListViewOutput {
    func viewDidLoad() {
        view.showLoading()
        interactor.loadTodos()
    }
    
    func searchTextChanged(_ text: String) {
        interactor.searchTodos(with: text)
    }
    
    func todoToggled(id: Int) {
        interactor.toggleTodoCompletion(id: id)
    }
    
    func editTodo(_ todo: TodoItemViewModel) {
        router.openDetailScreen(with: todo, todoListener: self)
        
    }
    
    func shareTodo(_ todo: TodoItemViewModel) {
        router.shareTodo(with: todo)
    }
    
    func deleteTodo(_ id: Int) {
        interactor.deleteTodo(id)
    }
    
    func updateTodoAfterEdit(id: Int, title: String, description: String) {
        interactor.updateTodo(id: id, title: title, description: description)
    }
    
    func addNewTodo() {
        router.openAddNewTodoScreen(todoListener: self)
    }
}

extension TodoListPresenter: TodoListInteractorOutput {
    func didLoadTodos(_ todos: [TodoItemViewModel]) {
        view.hideLoading()
        view.displayTodos(todos)
    }
    
    func didReceiveError(_ error: String) {
        view.hideLoading()
        view.displayError(error)
    }
    
    func didUpdateTodos(_ todos: [TodoItemViewModel]) {
        view.displayTodos(todos)
    }
    
    func didDeleteTodo(_ todos: [TodoItemViewModel]) {
        view.displayTodos(todos)
    }
}
