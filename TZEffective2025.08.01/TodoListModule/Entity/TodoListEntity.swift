//
//  TodoListEntity.swift
//  ViperExample
//
//  Created by Валентин on 31.07.2025.
//

import Foundation

struct TodoListEntity {
    let items: [TodoItemViewModel]
    let totalCount: Int
    let filteresItems: [TodoItemViewModel]
    let searchText: String
}
