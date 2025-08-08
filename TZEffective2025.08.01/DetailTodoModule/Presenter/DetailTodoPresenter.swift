//
//  DetailTodoPresenter.swift
//  TZEffective2025.08.01
//
//  Created by Валентин on 03.08.2025.
//

import Foundation

protocol DetailTodoPresenterInput {
    func viewDidLoad()
    func backButtonTapped()
}

final class DetailTodoPresenter {
    
    private let interactor: DetailTodoInteractorInput
    private let view: DetailTodoViewInput
    private let router: DetailTodoRouterInput
    
    private weak var listener: TodoUpdateListener?
    
    init(interactor: DetailTodoInteractorInput, view: DetailTodoViewInput, router: DetailTodoRouterInput, todoListener: TodoUpdateListener?) {
        self.interactor = interactor
        self.view = view
        self.router = router
        self.listener = todoListener
    }
}

extension DetailTodoPresenter: DetailTodoViewOutput {
    func viewDidLoad() {
        interactor.loadTodo()
    }
    
    func backButtonTapped(title: String, description: String) {
        if title.isEmpty && !description.isEmpty {
            view.showError("Название задачи не может быть пустым")
            return
        }
        
        if title.isEmpty && description.isEmpty {
            view.closeView()
            return
        }
    
        interactor.saveTodo(title: title, description: description)
    }
}

extension DetailTodoPresenter: DetailTodoInteractorOutput {
    func didLoadTodo(_ todo: TodoItemViewModel) {
        view.displayTodo(todo)
    }
    
    func didSaveTodo(id: Int, title: String, description: String, isNew: Bool) {
        //пробрасываем для обновления задачи в основном списке
        listener?.update(model: TodoUpdateModel(id: id, title: title, description: description, isNew: isNew))
        view.closeView()
    }
    
    func didReceiveError(_ error: String) {
        view.showError(error)
    }
}
