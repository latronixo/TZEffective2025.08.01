//
//  DetailTodoAssembly.swift
//  TZEffective2025.08.01
//
//  Created by Валентин on 03.08.2025.
//

import UIKit

class DetailTodoAssembly {
    static func assembleDetailTodoModule(todo: TodoItemViewModel?, coreDataService: CoreDataServiceProtocol, todoListener: TodoUpdateListener?) -> UIViewController {
        let view = DetailTodoView()
        let interactor = DetailTodoInteractor(todo: todo, coreDataService: coreDataService)
        let router = DetailTodoRouter()
        
        let presenter = DetailTodoPresenter(interactor: interactor, view: view, router: router, todoListener: todoListener)
        
        view.output = presenter
        interactor.output = presenter
        router.viewController = view
        
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController        
    }
}
