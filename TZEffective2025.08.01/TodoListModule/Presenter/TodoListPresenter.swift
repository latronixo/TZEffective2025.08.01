//
//  TodoListPresenter.swift
//  ViperExample
//
//  Created by Валентин on 31.07.2025.
//

import Foundation

protocol TodoListPresenterInput {
    var output: TodoListPresenterOutput? { get set }
}

protocol TodoListPresenterOutput: AnyObject {
    
}

final class TodoListPresenter {
    weak var output: TodoListPresenterOutput?
    
    private let interactor: TodoListInteractorInput
    private let router: TodoListRouterInput
    private let view: TodoListViewInput
    
    init(interactor: TodoListInteractorInput, router: TodoListRouterInput, view: TodoListViewInput) {
        self.interactor = interactor
        self.router = router
        self.view = view
    }
    
}

extension TodoListPresenter: TodoListViewOutput {
    func userSelectCreateTodo(withLogin login: String, password: String) {
        interactor.createTodo(withLogin: login, password: password)
    }
}

extension TodoListPresenter: TodoListInteractorOutput {
    func didReceive(error: String) {
        
    }
    
    func didCreateTodo(withLogin login: String) {
        router.openAddScreen(withLogin: login)
    }
}
