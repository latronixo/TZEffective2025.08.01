//
//  TodoListAssembly.swift
//  ViperExample
//
//  Created by Валентин on 01.08.2025.
//

import UIKit

class TodoListAssembly {
    static func assembleTodoListModule() -> UIViewController {
        let view = TodoListView()
        let interactor = TodoListInteractor()
        let router = TodoListRouter()
        
        let presenter = TodoListPresenter(interactor: interactor,
                                               router: router,
                                               view: view)
        
        interactor.output = presenter
        view.output = presenter
        
        router.rootViewController = view
        return view
    }
}
