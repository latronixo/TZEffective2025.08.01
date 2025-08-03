//
//  DetailTodoRouter.swift
//  TZEffective2025.08.01
//
//  Created by Валентин on 03.08.2025.
//

import UIKit

protocol DetailTodoRouterInput {
    func closeView()
}

final class DetailTodoRouter: DetailTodoRouterInput {
    weak var viewController: UIViewController?
    
    func closeView() {
        viewController?.dismiss(animated: true)
    }
}
