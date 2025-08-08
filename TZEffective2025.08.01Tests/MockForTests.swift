//
//  TodoListTests.swift
//  TZEffective2025.08.01Tests
//
//  Created by Assistant on 06.08.2025.
//

import XCTest
import CoreData
@testable import TZEffective2025_08_01

// MARK: - Mock Classes
class MockCoreDataService: CoreDataServiceProtocol {
    var mockTodos: [TodoItemViewModel] = []
    var createTodoCalled = false
    var updateTodoCalled = false
    var deleteTodoCalled = false
    var fetchTodosCalled = false
    var updateTodoCompletionCalled = false
    var saveTodosCalled = false
    
    private lazy var testContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TodoDataModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        return container
    }()
    
    func saveTodos(_ todos: [TodoItemAPI]) {
        saveTodosCalled = true
    }
    
    func fetchTodos(completion: @escaping ([NSManagedObject]) -> Void) {
        fetchTodosCalled = true
        
        let context = testContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "TodoItem", in:  context)!
        
        let managedObjects = mockTodos.map { viewModel -> NSManagedObject in
            let managedObject = NSManagedObject(entity: entity, insertInto: nil)
            managedObject.setValue(viewModel.id, forKey: "id")
            managedObject.setValue(viewModel.title, forKey: "title")
            managedObject.setValue(viewModel.describe, forKey: "describe")
            managedObject.setValue(viewModel.isCompleted, forKey: "completed")
            managedObject.setValue(viewModel.createdAt, forKey: "createdAt")
            managedObject.setValue(viewModel.userId, forKey: "userId")
            return managedObject
        }
        
        DispatchQueue.main.async {
            completion(managedObjects)
        }
    }
    
    func updateTodoCompletion(id: Int, isCompleted: Bool) {
        updateTodoCompletionCalled = true
    }
    
    func updateTodo(id: Int, title: String, description: String) {
        updateTodoCalled = true
    }
    
    func deleteTodo(_ id: Int) {
        deleteTodoCalled = true
    }
    
    func createTodo(title: String, description: String, completion: @escaping(Int) -> Void) {
        createTodoCalled = true
        DispatchQueue.main.async {
            completion(1)
        }
    }
}

class MockNetworkService: NetworkServiceProtocol {
    var fetchTodosCalled = false
    
    func fetchTodos(completion: @escaping (Result<TodoResponse, Error>) -> Void) {
        fetchTodosCalled = true
        let mockResponse = TodoResponse(
            todos: [
                TodoItemAPI(id: 1, todo: "API Test Todo", completed: false, userId: 1)
            ],
            total: 1,
            skip: 0,
            limit: 10
        )
        completion(.success(mockResponse))
    }
}

class MockUserDefaultsService: UserDefaultsServiceProtocol {
    var isNotFirstLaunchResult: Bool = false
    var isNotFirstLaunchCalled = false
    var markAsNotFirstLaunchCalled = false
    
    func isNotFirstLaunch() -> Bool {
        isNotFirstLaunchCalled = true
        return isNotFirstLaunchResult
    }
    
    func markAsNotFirstLaunch() {
        markAsNotFirstLaunchCalled = true
    }
}

class MockTodoListInteractorOutput: TodoListInteractorOutput {
    var didLoadTodosCalled: (([TodoItemViewModel]) -> Void)?
    var didReceiveErrorCalled: ((String) -> Void)?
    var didUpdateTodosCalled: (([TodoItemViewModel]) -> Void)?
    var didDeleteTodoCalled: (([TodoItemViewModel]) -> Void)?
    
    func didLoadTodos(_ todos: [TodoItemViewModel]) {
        didLoadTodosCalled?(todos)
    }
    
    func didReceiveError(_ error: String) {
        didReceiveErrorCalled?(error)
    }
    
    func didUpdateTodos(_ todos: [TodoItemViewModel]) {
        didUpdateTodosCalled?(todos)
    }
    
    func didDeleteTodo(_ todos: [TodoItemViewModel]) {
        didDeleteTodoCalled?(todos)
    }
}

class MockTodoListInteractor: TodoListInteractorInput {
    var output: TodoListInteractorOutput?
    
    var loadTodosCalled = false
    var updateTodoCalled = false
    var updateTodoId: Int?
    var updateTodoTitle: String?
    var updateTodoDescription: String?
    var deleteTodoCalled = false
    var deleteTodoId: Int?
    var searchTodosCalled = false
    var searchTodosQuery: String?
    var toggleTodoCompletionCalled = false
    var toggleTodoCompletionId: Int?
    
    func loadTodos() {
        loadTodosCalled = true
    }
    
    func updateTodo(id: Int, title: String, description: String) {
        updateTodoCalled = true
        updateTodoId = id
        updateTodoTitle = title
        updateTodoDescription = description
    }
    
    func deleteTodo(_ id: Int) {
        deleteTodoCalled = true
        deleteTodoId = id
    }
    
    func searchTodos(with query: String) {
        searchTodosCalled = true
        searchTodosQuery = query
    }
    
    func toggleTodoCompletion(id: Int) {
        toggleTodoCompletionCalled = true
        toggleTodoCompletionId = id
    }
}

class MockTodoListRouter: TodoListRouterInput {
    var openDetailScreenCalled = false
    var openDetailScreenTodo: TodoItemViewModel?
    var openAddNewTodoScreenCalled = false
    var shareTodoCalled = false
    var shareTodoTodo: TodoItemViewModel?
    
    func openDetailScreen(with todo: TodoItemViewModel, todoListener: TodoUpdateListener?) {
        openDetailScreenCalled = true
        openDetailScreenTodo = todo
    }
    
    func shareTodo(with todo: TodoItemViewModel) {
        shareTodoCalled = true
        shareTodoTodo = todo
    }
    
    func openAddNewTodoScreen(todoListener: TodoUpdateListener?) {
        openAddNewTodoScreenCalled = true
    }
    
    func openAddNewTodoScreen() {
        openAddNewTodoScreenCalled = true
    }
}

class MockTodoListView: TodoListViewInput {
    var displayTodosCalled = false
    var displayErrorCalled = false
    var showLoadingCalled = false
    var hideLoadingCalled = false
    var updateTasksCountCalled = false
    
    func displayTodos(_ todos: [TodoItemViewModel]) {
        displayTodosCalled = true
    }
    
    func displayError(_ message: String) {
        displayErrorCalled = true
    }
    
    func showLoading() {
        showLoadingCalled = true
    }
    
    func hideLoading() {
        hideLoadingCalled = true
    }
    
    func updateTasksCount(_ count: Int) {
        updateTasksCountCalled = true
    }
}

class MockDetailTodoInteractorOutput: DetailTodoInteractorOutput {
    var didLoadTodoCalled: ((TodoItemViewModel) -> Void)?
    var didSaveTodoCalled: ((Int, String, String, Bool) -> Void)?
    var didReceiveErrorCalled: ((String) -> Void)?
    
    func didLoadTodo(_ todo: TodoItemViewModel) {
        didLoadTodoCalled?(todo)
    }
    
    func didSaveTodo(id: Int, title: String, description: String, isNew: Bool) {
        didSaveTodoCalled?(id, title, description, isNew)
    }
    
    func didReceiveError(_ error: String) {
        didReceiveErrorCalled?(error)
    }
}

class MockDetailTodoInteractor: DetailTodoInteractorInput {
    var output: DetailTodoInteractorOutput?
    
    var loadTodoCalled = false
    var saveTodoCalled = false
    var saveTodoTitle: String?
    var saveTodoDescription: String?
    
    func loadTodo() {
        loadTodoCalled = true
    }
    
    func saveTodo(title: String, description: String) {
        saveTodoCalled = true
        saveTodoTitle = title
        saveTodoDescription = description
    }
}

class MockDetailTodoRouter: DetailTodoRouterInput {
    var closeViewCalled = false
    
    func closeView() {
        closeViewCalled = true
    }
}

class MockTodoUpdateListener: TodoUpdateListener {
    var updateCalled = false
    var updateModel: TodoUpdateModel?
    
    func update(model: TodoUpdateModel) {
        updateCalled = true
        updateModel = model
    }
}

class MockDetailTodoView: DetailTodoViewInput {
    var displayTodoCalled = false
    var showErrorCalled = false
    var closeViewCalled = false
    var editedData: (title: String, description: String) = ("", "")
    
    func displayTodo(_ todo: TodoItemViewModel) {
        displayTodoCalled = true
    }
    
    func showError(_ message: String) {
        showErrorCalled = true
    }
    
    func closeView() {
        closeViewCalled = true
    }
    
    func getEditedData() -> (title: String, description: String) {
        return editedData
    }
} 
