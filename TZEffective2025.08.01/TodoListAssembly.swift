//
//  TodoListAssembly.swift
//  TZEffective2025.08.01
//
//  Created by Валентин on 02.08.2025.
//

import UIKit

class TodoListAssembly {
    static func assembleTodoListModule() -> UINavigationController {
        let view = TodoListView()
        let networkService = TodoNetworkService()
        let coreDataService = TodoCoreDataService()
        let interactor = TodoListInteractor(networkService: networkService, coreDataService: coreDataService)
        let router = TodoListRouter()
        
        let presenter = TodoListPresenter(interactor: interactor,
                                        router: router,
                                        view: view)
        
        interactor.output = presenter
        view.output = presenter
        router.rootViewController = view
        
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }
}
