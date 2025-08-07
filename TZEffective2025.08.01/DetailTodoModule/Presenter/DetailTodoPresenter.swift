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

protocol DetailTodoPresenterOutput: AnyObject {
    func displayTodo(_ todo: TodoItemViewModel)
    func showError(_ message: String)
    func closeView()
    func updateTodoInList(id: Int, title: String, description: String, isNew: Bool)
}

final class DetailTodoPresenter {
    weak var output: DetailTodoPresenterOutput?
    
    private let interactor: DetailTodoInteractorInput
    private let view: DetailTodoViewInput
    private let router: DetailTodoRouterInput
    private var currentTodo: TodoItemAPI?
    
    init(interactor: DetailTodoInteractorInput, view: DetailTodoViewInput, router: DetailTodoRouterInput) {
        self.interactor = interactor
        self.view = view
        self.router = router
    }
}

extension DetailTodoPresenter: DetailTodoViewOutput {
    func viewDidLoad() {
        interactor.loadTodo()
    }
    
    func backButtonTapped() {
        guard let detailView = view as? DetailTodoView else { return }
        let editedData = detailView.getEditedData()
        
        if editedData.title.isEmpty {
            output?.showError("Название задачи не может быть пустым")
            return
        }
        
        interactor.saveTodo(title: editedData.title, description: editedData.description)
    }
}

extension DetailTodoPresenter: DetailTodoInteractorOutput {
    func didLoadTodo(_ todo: TodoItemViewModel) {
        output?.displayTodo(todo)
    }
    
    func didSaveTodo(id: Int, title: String, description: String, isNew: Bool) {
        //пробрасываем для обновления задачи в основном списке
        output?.updateTodoInList(id: id, title: title, description: description, isNew: isNew)
        
        output?.closeView()
    }
    
    func didReceiveError(_ error: String) {
        output?.showError(error)
    }
}
