//
//  DetailTodoAssembly.swift
//  TZEffective2025.08.01
//
//  Created by Валентин on 03.08.2025.
//

import UIKit

class DetailTodoAssembly {
    static func assembleDetailTodoModule(todo: TodoItemViewModel?, coreDataService: CoreDataServiceProtocol) -> UIViewController {
        let view = DetailTodoView()
        let interactor = DetailTodoInteractor(todo: todo, coreDataService: coreDataService)
        let router = DetailTodoRouter()
        
        let presenter = DetailTodoPresenter(interactor: interactor, view: view, router: router)
        
        view.output = presenter
        interactor.output = presenter
        router.viewController = view
        presenter.output = view
        
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController        
    }
}
