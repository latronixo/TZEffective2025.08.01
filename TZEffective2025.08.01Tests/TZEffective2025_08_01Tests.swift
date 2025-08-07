//
//  TZEffective2025_08_01Tests.swift
//  TZEffective2025_08_01Tests
//
//  Created by Валентин on 02.08.2025.
//

import XCTest
import CoreData
@testable import TZEffective2025_08_01

// MARK: - TodoItemViewModel Tests
final class TodoItemViewModelTests: XCTestCase {
    
    func testInitFromAPIItem() {
        // Given
        let apiItem = TodoItemAPI(id: 1, todo: "Test Todo", completed: true, userId: 1)
        
        // When
        let viewModel = TodoItemViewModel(from: apiItem)
        
        // Then
        XCTAssertEqual(viewModel.id, 1)
        XCTAssertEqual(viewModel.title, "Test Todo")
        XCTAssertEqual(viewModel.describe, "Test Todo")
        XCTAssertTrue(viewModel.isCompleted)
        XCTAssertEqual(viewModel.userId, 1)
        XCTAssertNotNil(viewModel.createdAt)
    }
    
    func testInitFromCoreDataItem() {
        // Given
        let managedObject = NSManagedObject()
        managedObject.setValue(2, forKey: "id")
        managedObject.setValue("Core Data Todo", forKey: "title")
        managedObject.setValue("Core Data Description", forKey: "describe")
        managedObject.setValue(false, forKey: "completed")
        managedObject.setValue(Date(), forKey: "createdAt")
        managedObject.setValue(3, forKey: "userId")
        
        // When
        let viewModel = TodoItemViewModel(from: managedObject)
        
        // Then
        XCTAssertEqual(viewModel.id, 2)
        XCTAssertEqual(viewModel.title, "Core Data Todo")
        XCTAssertEqual(viewModel.describe, "Core Data Description")
        XCTAssertFalse(viewModel.isCompleted)
        XCTAssertEqual(viewModel.userId, 3)
        XCTAssertNotNil(viewModel.createdAt)
    }
    
    func testInitWithParameters() {
        // Given
        let id = 5
        let title = "Custom Title"
        let describe = "Custom Description"
        let isCompleted = true
        let createdAt = Date()
        let userId = 10
        
        // When
        let viewModel = TodoItemViewModel(
            id: id,
            title: title,
            describe: describe,
            isCompleted: isCompleted,
            createdAt: createdAt,
            userId: userId
        )
        
        // Then
        XCTAssertEqual(viewModel.id, id)
        XCTAssertEqual(viewModel.title, title)
        XCTAssertEqual(viewModel.describe, describe)
        XCTAssertEqual(viewModel.isCompleted, isCompleted)
        XCTAssertEqual(viewModel.createdAt, createdAt)
        XCTAssertEqual(viewModel.userId, userId)
    }
}

// MARK: - CoreDataService Tests
final class CoreDataServiceTests: XCTestCase {
    var coreDataService: CoreDataService!
    var testContainer: NSPersistentContainer!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Создаем тестовый контейнер Core Data в памяти
        testContainer = NSPersistentContainer(name: "TodoDataModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        testContainer.persistentStoreDescriptions = [description]
        
        testContainer.loadPersistentStores { _, error in
            if let error = error {
                XCTFail("Failed to load test Core Data store: \(error)")
            }
        }
        
        // Создаем сервис с тестовым контейнером
        coreDataService = CoreDataService()
    }
    
    override func tearDownWithError() throws {
        coreDataService = nil
        testContainer = nil
        try super.tearDownWithError()
    }
    
    func testCreateTodo() {
        // Given
        let expectation = XCTestExpectation(description: "Create todo completion")
        let title = "Test Todo"
        let description = "Test Description"
        
        // When
        coreDataService.createTodo(title: title, description: description) { newId in
            // Then
            XCTAssertGreaterThan(newId, 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchTodos() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch todos completion")
        
        // When
        coreDataService.fetchTodos { todos in
            // Then
            XCTAssertNotNil(todos)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testUpdateTodo() {
        // Given
        let expectation = XCTestExpectation(description: "Update todo completion")
        let id = 1
        let newTitle = "Updated Title"
        let newDescription = "Updated Description"
        
        // When
        coreDataService.updateTodo(id: id, title: newTitle, description: newDescription)
        
        // Then - проверяем что обновление не вызывает ошибок
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testDeleteTodo() {
        // Given
        let expectation = XCTestExpectation(description: "Delete todo completion")
        let id = 1
        
        // When
        coreDataService.deleteTodo(id)
        
        // Then - проверяем что удаление не вызывает ошибок
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}

// MARK: - TodoListInteractor Tests
final class TodoListInteractorTests: XCTestCase {
    var interactor: TodoListInteractor!
    var mockCoreDataService: MockCoreDataService!
    var mockNetworkService: MockNetworkService!
    var mockUserDefaultsService: MockUserDefaultsService!
    var mockOutput: MockTodoListInteractorOutput!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockCoreDataService = MockCoreDataService()
        mockNetworkService = MockNetworkService()
        mockUserDefaultsService = MockUserDefaultsService()
        
        mockOutput = MockTodoListInteractorOutput()
        
        interactor = TodoListInteractor(
            networkService: mockNetworkService,
            coreDataService: mockCoreDataService,
            userDefaultsService: mockUserDefaultsService
        )
        interactor.output = mockOutput
    }
    
    override func tearDownWithError() throws {
        interactor = nil
        mockCoreDataService = nil
        mockNetworkService = nil
        mockUserDefaultsService = nil
        mockOutput = nil
        try super.tearDownWithError()
    }
    
    func testLoadTodosSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Load todos success")
        let mockTodos = [
            TodoItemViewModel(id: 1, title: "Test 1", describe: "Desc 1", isCompleted: false, createdAt: Date(), userId: 1),
            TodoItemViewModel(id: 2, title: "Test 2", describe: "Desc 2", isCompleted: true, createdAt: Date(), userId: 1)
        ]
        mockCoreDataService.mockTodos = mockTodos
        
        mockOutput.didLoadTodosCalled = { todos in
            XCTAssertEqual(todos.count, 2)
            XCTAssertEqual(todos[0].title, "Test 1")
            XCTAssertEqual(todos[1].title, "Test 2")
            expectation.fulfill()
        }
        
        // When
        interactor.loadTodos()
        
        // Then
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testUpdateTodo() {
        // Given
        let expectation = XCTestExpectation(description: "Update todo")
        let id = 1
        let newTitle = "Updated Title"
        let newDescription = "Updated Description"
        
        mockOutput.didUpdateTodosCalled = { todos in
            XCTAssertEqual(todos.count, 1)
            XCTAssertEqual(todos[0].title, newTitle)
            XCTAssertEqual(todos[0].describe, newDescription)
            expectation.fulfill()
        }
        
        // When
        interactor.updateTodo(id: id, title: newTitle, description: newDescription)
        
        // Then
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testLoadTodosOnFirstLaunchShouldLoadFromAPI() {
        // GIVEN: Устанавливаем, что это первый запуск
        mockUserDefaultsService.isNotFirstLaunchResult = false
        
        // WHEN: Загружаем задачи
        interactor.loadTodos()
        
        // THEN: Проверяем, что были вызваны правильные методы
        XCTAssertTrue(mockUserDefaultsService.isNotFirstLaunchCalled)
        XCTAssertTrue(mockNetworkService.fetchTodosCalled) //Проверяем, что interactor пошел в сеть
        XCTAssertFalse(mockCoreDataService.fetchTodosCalled)    //убеждаемся, что он НЕ пошел в CoreData
    }
}

// MARK: - TodoListPresenter Tests
final class TodoListPresenterTests: XCTestCase {
    var presenter: TodoListPresenter!
    var mockInteractor: MockTodoListInteractor!
    var mockRouter: MockTodoListRouter!
    var mockView: MockTodoListView!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockInteractor = MockTodoListInteractor()
        mockRouter = MockTodoListRouter()
        mockView = MockTodoListView()
        
        presenter = TodoListPresenter(
            interactor: mockInteractor,
            router: mockRouter,
            view: mockView
        )
    }
    
    override func tearDownWithError() throws {
        presenter = nil
        mockInteractor = nil
        mockRouter = nil
        mockView = nil
        try super.tearDownWithError()
    }
    
    func testViewDidLoad() {
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(mockInteractor.loadTodosCalled)
    }
    
    func testAddNewTodo() {
        // When
        presenter.addNewTodo()
        
        // Then
        XCTAssertTrue(mockRouter.openAddNewTodoScreenCalled)
    }
    
    func testUpdateTodoAfterEdit() {
        // Given
        let id = 1
        let title = "Updated Title"
        let description = "Updated Description"
        
        // When
        presenter.updateTodoAfterEdit(id: id, title: title, description: description)
        
        // Then
        XCTAssertTrue(mockInteractor.updateTodoCalled)
        XCTAssertEqual(mockInteractor.updateTodoId, id)
        XCTAssertEqual(mockInteractor.updateTodoTitle, title)
        XCTAssertEqual(mockInteractor.updateTodoDescription, description)
    }
}

// MARK: - Mock Classes
class MockCoreDataService: CoreDataServiceProtocol {
    var mockTodos: [TodoItemViewModel] = []
    var createTodoCalled = false
    var updateTodoCalled = false
    var deleteTodoCalled = false
    var fetchTodosCalled = false
    
    func saveTodos(_ todos: [TodoItemAPI]) {
        // Mock implementation
    }
    
    func fetchTodos(completion: @escaping ([NSManagedObject]) -> Void) {
        fetchTodosCalled = true
        // Mock implementation - возвращаем пустой массив
        DispatchQueue.main.async {
            completion([])
        }
    }
    
    func updateTodoCompletion(id: Int, isCompleted: Bool) {
        // Mock implementation
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
        // Mock successful response
        let mockResponse = TodoResponse(
            todos: [
                TodoItemAPI(id: 1, todo: "Test Todo", completed: false, userId: 1)
            ],
            total: 1,
            skip: 0,
            limit: 10
        )
        completion(.success(mockResponse))
    }
}

class MockUserDefaultsService: UserDefaultsServiceProtocol {
    // Свойство для контроля результата. true = это НЕ первый запуск. false = это ПЕРВЫЙ запуск.
    var isNotFirstLaunchResult: Bool = false
    
    // Флаги для проверки, были ли вызваны методы
    var isNotFirstLaunchCalled = false
    var markAsNotFirstLaunchCalled = false
    
    func isNotFirstLaunch() -> Bool {
        isNotFirstLaunchCalled = true
        return isNotFirstLaunchResult
    }
    
    func markAsNotFirstLaunch() {
        isNotFirstLaunchResult = true
    }
}

class MockTodoListInteractorOutput: TodoListInteractorOutput {
    var didLoadTodosCalled: (([TodoItemViewModel]) -> Void)?
    var didReceiveErrorCalled: ((String) -> Void)?
    var didUpdateTodosCalled: (([TodoItemViewModel]) -> Void)?
    var didDeleteTodocalled: (([TodoItemViewModel]) -> Void)?
    
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
        didDeleteTodocalled?(todos)
    }
}

class MockTodoListInteractor: TodoListInteractorInput {
    var output: (any TZEffective2025_08_01.TodoListInteractorOutput)?
    
    var loadTodosCalled = false
    var updateTodoCalled = false
    var updateTodoId: Int?
    var updateTodoTitle: String?
    var updateTodoDescription: String?
    
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
        // Mock implementation
    }
    
    func searchTodos(with query: String) {
        // Mock implementation
    }
    
    func toggleTodoCompletion(id: Int) {
        // Mock implementation
    }
}

class MockTodoListRouter: TodoListRouterInput {
    var openAddNewTodoScreenCalled = false
    
    func openAddNewTodoScreen() {
        openAddNewTodoScreenCalled = true
    }
}

class MockTodoListView: TodoListViewInput {
    var displayTodosCalled = false
    var displayErrorCalled = false
    
    func displayTodos(_ todos: [TodoItemViewModel]) {
        displayTodosCalled = true
    }
    
    func displayError(_ message: String) {
        displayErrorCalled = true
    }
}
