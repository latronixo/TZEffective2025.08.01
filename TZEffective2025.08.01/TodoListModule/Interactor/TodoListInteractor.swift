//
//  TodoListInteractor.swift
//  ViperExample
//
//  Created by Валентин on 31.07.2025.
//

import UIKit

protocol TodoListInteractorInput {
    var output: TodoListInteractorOutput? { get set } 
    func createTodo(withLogin login: String, password: String)
}

protocol TodoListInteractorOutput: AnyObject {
    func didReceive(error: String)
    func didCreateTodo(withLogin login: String)
}

final class TodoListInteractor: TodoListInteractorInput {
    weak var output: TodoListInteractorOutput?
    
    func createTodo(withLogin login: String, password: String) {
        
    }
}
