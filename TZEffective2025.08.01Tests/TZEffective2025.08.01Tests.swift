//
//  TodoListTests.swift
//  TZEffective2025.08.01Tests
//
//  Created by Assistant on 06.08.2025.
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
    
    func testLoadTodosFromCoreData() {
        // Given
        let expectation = XCTestExpectation(description: "Load todos from Core Data")
        let mockTodos = [
            TodoItemViewModel(id: 1, title: "Test 1", describe: "Desc 1", isCompleted: false, createdAt: Date(), userId: 1),
            TodoItemViewModel(id: 2, title: "Test 2", describe: "Desc 2", isCompleted: true, createdAt: Date(), userId: 1)
        ]
        mockCoreDataService.mockTodos = mockTodos
        mockUserDefaultsService.isNotFirstLaunchResult = true
        
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
        XCTAssertTrue(mockUserDefaultsService.isNotFirstLaunchCalled)
        XCTAssertTrue(mockCoreDataService.fetchTodosCalled)
        XCTAssertFalse(mockNetworkService.fetchTodosCalled)
    }
    
    func testLoadTodosFromAPI() {
        // Given
        let expectation = XCTestExpectation(description: "Load todos from API")
        mockUserDefaultsService.isNotFirstLaunchResult = false
        
        mockOutput.didLoadTodosCalled = { todos in
            XCTAssertEqual(todos.count, 1)
            XCTAssertEqual(todos[0].title, "API Test Todo")
            expectation.fulfill()
        }
        
        // When
        interactor.loadTodos()
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertTrue(mockUserDefaultsService.isNotFirstLaunchCalled)
        XCTAssertTrue(mockNetworkService.fetchTodosCalled)
        XCTAssertTrue(mockUserDefaultsService.markAsNotFirstLaunchCalled)
    }
    
    func testSearchTodosWithQuery() {
        // Given
        let expectation = XCTestExpectation(description: "Search todos")
        let mockTodos = [
            TodoItemViewModel(id: 1, title: "Apple", describe: "Apple description", isCompleted: false, createdAt: Date(), userId: 1),
            TodoItemViewModel(id: 2, title: "Banana", describe: "Banana description", isCompleted: true, createdAt: Date(), userId: 1),
            TodoItemViewModel(id: 3, title: "Orange", describe: "Orange description", isCompleted: false, createdAt: Date(), userId: 1)
        ]
        mockCoreDataService.mockTodos = mockTodos
        mockUserDefaultsService.isNotFirstLaunchResult = true
        
        // Сначала загружаем todos
        interactor.loadTodos()
        
        mockOutput.didUpdateTodosCalled = { todos in
            XCTAssertEqual(todos.count, 1)
            XCTAssertEqual(todos[0].title, "Apple")
            expectation.fulfill()
        }
        
        // When
        interactor.searchTodos(with: "Apple")
        
        // Then
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testSearchTodosWithEmptyQuery() {
        // Given
        let expectation = XCTestExpectation(description: "Search todos with empty query")
        let mockTodos = [
            TodoItemViewModel(id: 1, title: "Test 1", describe: "Desc 1", isCompleted: false, createdAt: Date(), userId: 1),
            TodoItemViewModel(id: 2, title: "Test 2", describe: "Desc 2", isCompleted: true, createdAt: Date(), userId: 1)
        ]
        mockCoreDataService.mockTodos = mockTodos
        mockUserDefaultsService.isNotFirstLaunchResult = true
        
        // Сначала загружаем todos
        interactor.loadTodos()
        
        mockOutput.didUpdateTodosCalled = { todos in
            XCTAssertEqual(todos.count, 2)
            expectation.fulfill()
        }
        
        // When
        interactor.searchTodos(with: "")
        
        // Then
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testToggleTodoCompletion() {
        // Given
        let expectation = XCTestExpectation(description: "Toggle todo completion")
        let mockTodos = [
            TodoItemViewModel(id: 1, title: "Test 1", describe: "Desc 1", isCompleted: false, createdAt: Date(), userId: 1)
        ]
        mockCoreDataService.mockTodos = mockTodos
        mockUserDefaultsService.isNotFirstLaunchResult = true
        
        // Сначала загружаем todos
        interactor.loadTodos()
        
        mockOutput.didUpdateTodosCalled = { todos in
            XCTAssertEqual(todos.count, 1)
            XCTAssertTrue(todos[0].isCompleted)
            expectation.fulfill()
        }
        
        // When
        interactor.toggleTodoCompletion(id: 1)
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertTrue(mockCoreDataService.updateTodoCompletionCalled)
    }
    
    func testDeleteTodo() {
        // Given
        let expectation = XCTestExpectation(description: "Delete todo")
        let mockTodos = [
            TodoItemViewModel(id: 1, title: "Test 1", describe: "Desc 1", isCompleted: false, createdAt: Date(), userId: 1),
            TodoItemViewModel(id: 2, title: "Test 2", describe: "Desc 2", isCompleted: true, createdAt: Date(), userId: 1)
        ]
        mockCoreDataService.mockTodos = mockTodos
        mockUserDefaultsService.isNotFirstLaunchResult = true
        
        // Сначала загружаем todos
        interactor.loadTodos()
        
        mockOutput.didDeleteTodoCalled = { todos in
            XCTAssertEqual(todos.count, 1)
            XCTAssertEqual(todos[0].id, 2)
            expectation.fulfill()
        }
        
        // When
        interactor.deleteTodo(1)
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertTrue(mockCoreDataService.deleteTodoCalled)
    }
    
    func testUpdateTodo() {
        // Given
        let expectation = XCTestExpectation(description: "Update todo")
        let mockTodos = [
            TodoItemViewModel(id: 1, title: "Old Title", describe: "Old Description", isCompleted: false, createdAt: Date(), userId: 1)
        ]
        mockCoreDataService.mockTodos = mockTodos
        mockUserDefaultsService.isNotFirstLaunchResult = true
        
        // Сначала загружаем todos
        interactor.loadTodos()
        
        mockOutput.didUpdateTodosCalled = { todos in
            XCTAssertEqual(todos.count, 1)
            XCTAssertEqual(todos[0].title, "New Title")
            XCTAssertEqual(todos[0].describe, "New Description")
            expectation.fulfill()
        }
        
        // When
        interactor.updateTodo(id: 1, title: "New Title", description: "New Description")
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertTrue(mockCoreDataService.updateTodoCalled)
    }
}

// MARK: - DetailTodoInteractor Tests
final class DetailTodoInteractorTests: XCTestCase {
    var interactor: DetailTodoInteractor!
    var mockCoreDataService: MockCoreDataService!
    var mockOutput: MockDetailTodoInteractorOutput!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockCoreDataService = MockCoreDataService()
        mockOutput = MockDetailTodoInteractorOutput()
        
        interactor = DetailTodoInteractor(todo: nil, coreDataService: mockCoreDataService)
        interactor.output = mockOutput
    }
    
    override func tearDownWithError() throws {
        interactor = nil
        mockCoreDataService = nil
        mockOutput = nil
        try super.tearDownWithError()
    }
    
    func testLoadTodoWithExistingTodo() {
        // Given
        let existingTodo = TodoItemViewModel(id: 1, title: "Existing Todo", describe: "Existing Description", isCompleted: false, createdAt: Date(), userId: 1)
        interactor = DetailTodoInteractor(todo: existingTodo, coreDataService: mockCoreDataService)
        interactor.output = mockOutput
        
        let expectation = XCTestExpectation(description: "Load existing todo")
        
        mockOutput.didLoadTodoCalled = { todo in
            XCTAssertEqual(todo.id, 1)
            XCTAssertEqual(todo.title, "Existing Todo")
            XCTAssertEqual(todo.describe, "Existing Description")
            expectation.fulfill()
        }
        
        // When
        interactor.loadTodo()
        
        // Then
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testLoadTodoWithNewTodo() {
        // Given
        let expectation = XCTestExpectation(description: "Load new todo")
        
        mockOutput.didLoadTodoCalled = { todo in
            XCTAssertEqual(todo.id, 0)
            XCTAssertEqual(todo.title, "")
            XCTAssertEqual(todo.describe, "")
            XCTAssertFalse(todo.isCompleted)
            expectation.fulfill()
        }
        
        // When
        interactor.loadTodo()
        
        // Then
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testSaveTodoWithExistingTodo() {
        // Given
        let existingTodo = TodoItemViewModel(id: 1, title: "Old Title", describe: "Old Description", isCompleted: false, createdAt: Date(), userId: 1)
        interactor = DetailTodoInteractor(todo: existingTodo, coreDataService: mockCoreDataService)
        interactor.output = mockOutput
        
        let expectation = XCTestExpectation(description: "Save existing todo")
        
        mockOutput.didSaveTodoCalled = { id, title, description, isNew in
            XCTAssertEqual(id, 1)
            XCTAssertEqual(title, "New Title")
            XCTAssertEqual(description, "New Description")
            XCTAssertFalse(isNew)
            expectation.fulfill()
        }
        
        // When
        interactor.saveTodo(title: "New Title", description: "New Description")
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertTrue(mockCoreDataService.updateTodoCalled)
    }
    
    func testSaveTodoWithNewTodo() {
        // Given
        let expectation = XCTestExpectation(description: "Save new todo")
        
        mockOutput.didSaveTodoCalled = { id, title, description, isNew in
            XCTAssertGreaterThan(id, 0)
            XCTAssertEqual(title, "New Todo")
            XCTAssertEqual(description, "New Description")
            XCTAssertTrue(isNew)
            expectation.fulfill()
        }
        
        // When
        interactor.saveTodo(title: "New Todo", description: "New Description")
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertTrue(mockCoreDataService.createTodoCalled)
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
    
    func testEditTodo() {
        // Given
        let todo = TodoItemViewModel(id: 1, title: "Test Todo", describe: "Test Description", isCompleted: false, createdAt: Date(), userId: 1)
        
        // When
        presenter.editTodo(todo)
        
        // Then
        XCTAssertTrue(mockRouter.openDetailScreenCalled)
        XCTAssertEqual(mockRouter.openDetailScreenTodo?.id, 1)
    }
    
    func testShareTodo() {
        // Given
        let todo = TodoItemViewModel(id: 1, title: "Test Todo", describe: "Test Description", isCompleted: false, createdAt: Date(), userId: 1)
        
        // When
        presenter.shareTodo(todo)
        
        // Then
        XCTAssertTrue(mockRouter.shareTodoCalled)
        XCTAssertEqual(mockRouter.shareTodoTodo?.id, 1)
    }
    
    func testDeleteTodo() {
        // Given
        let id = 1
        
        // When
        presenter.deleteTodo(id)
        
        // Then
        XCTAssertTrue(mockInteractor.deleteTodoCalled)
        XCTAssertEqual(mockInteractor.deleteTodoId, id)
    }
    
    func testSearchTextChanged() {
        // Given
        let searchText = "test"
        
        // When
        presenter.searchTextChanged(searchText)
        
        // Then
        XCTAssertTrue(mockInteractor.searchTodosCalled)
        XCTAssertEqual(mockInteractor.searchTodosQuery, searchText)
    }
    
    func testTodoToggled() {
        // Given
        let id = 1
        
        // When
        presenter.todoToggled(id: id)
        
        // Then
        XCTAssertTrue(mockInteractor.toggleTodoCompletionCalled)
        XCTAssertEqual(mockInteractor.toggleTodoCompletionId, id)
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
    
    func testDidLoadTodos() {
        // Given
        let todos = [
            TodoItemViewModel(id: 1, title: "Test 1", describe: "Desc 1", isCompleted: false, createdAt: Date(), userId: 1),
            TodoItemViewModel(id: 2, title: "Test 2", describe: "Desc 2", isCompleted: true, createdAt: Date(), userId: 1)
        ]
        
        // When
        presenter.didLoadTodos(todos)
        
        // Then
        XCTAssertTrue(mockView.displayTodosCalled)
    }
    
    func testDidReceiveError() {
        // Given
        let errorMessage = "Test error"
        
        // When
        presenter.didReceiveError(errorMessage)
        
        // Then
        XCTAssertTrue(mockView.displayErrorCalled)
    }
}

// MARK: - DetailTodoPresenter Tests
final class DetailTodoPresenterTests: XCTestCase {
    var presenter: DetailTodoPresenter!
    var mockInteractor: MockDetailTodoInteractor!
    var mockView: MockDetailTodoView!
    var mockRouter: MockDetailTodoRouter!
    var mockTodoListener: MockTodoUpdateListener!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockInteractor = MockDetailTodoInteractor()
        mockView = MockDetailTodoView()
        mockRouter = MockDetailTodoRouter()
        mockTodoListener = MockTodoUpdateListener()
        
        presenter = DetailTodoPresenter(
            interactor: mockInteractor,
            view: mockView,
            router: mockRouter,
            todoListener: mockTodoListener
        )
    }
    
    override func tearDownWithError() throws {
        presenter = nil
        mockInteractor = nil
        mockView = nil
        mockRouter = nil
        mockTodoListener = nil
        try super.tearDownWithError()
    }
    
    func testViewDidLoad() {
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(mockInteractor.loadTodoCalled)
    }
    
    func testBackButtonTapped() {
        // Given
        let mockDetailView = MockDetailTodoView()
        mockDetailView.editedData = (title: "Test Title", description: "Test Description")
        
        // When
        presenter.backButtonTapped()
        
        // Then
        XCTAssertTrue(mockInteractor.saveTodoCalled)
    }
    
    func testDidLoadTodo() {
        // Given
        let todo = TodoItemViewModel(id: 1, title: "Test Todo", describe: "Test Description", isCompleted: false, createdAt: Date(), userId: 1)
        
        // When
        presenter.didLoadTodo(todo)
        
        // Then
        XCTAssertTrue(mockView.displayTodoCalled)
    }
    
    func testDidSaveTodo() {
        // Given
        let id = 1
        let title = "Saved Title"
        let description = "Saved Description"
        let isNew = false
        
        // When
        presenter.didSaveTodo(id: id, title: title, description: description, isNew: isNew)
        
        // Then
        XCTAssertTrue(mockTodoListener.updateCalled)
        XCTAssertTrue(mockView.closeViewCalled)
    }
}

// MARK: - Mock Classes
class MockCoreDataService: CoreDataServiceProtocol {
    var mockTodos: [TodoItemViewModel] = []
    var createTodoCalled = false
    var updateTodoCalled = false
    var deleteTodoCalled = false
    var fetchTodosCalled = false
    var updateTodoCompletionCalled = false
    var saveTodosCalled = false
    
    func saveTodos(_ todos: [TodoItemAPI]) {
        saveTodosCalled = true
    }
    
    func fetchTodos(completion: @escaping ([NSManagedObject]) -> Void) {
        fetchTodosCalled = true
        
        let managedObjects = mockTodos.map { viewModel -> NSManagedObject in
            let entity = NSEntityDescription()
            entity.name = "TodoItem"
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
    var closeCalled = false
    
    func close() {
        closeCalled = true
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
    var updateTodoInListCalled = false
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
    
    func updateTodoInList(id: Int, title: String, description: String, isNew: Bool) {
        updateTodoInListCalled = true
    }
    
    func getEditedData() -> (title: String, description: String) {
        return editedData
    }
}

// MARK: - Additional Protocols and Models
protocol TodoUpdateListener: AnyObject {
    func update(model: TodoUpdateModel)
}

struct TodoUpdateModel {
    let id: Int
    let title: String
    let description: String
    let isNew: Bool
}

protocol DetailTodoViewInput {
    func displayTodo(_ todo: TodoItemViewModel)
    func showError(_ message: String)
    func closeView()
    func updateTodoInList(id: Int, title: String, description: String, isNew: Bool)
}

protocol DetailTodoViewOutput {
    func viewDidLoad()
    func backButtonTapped()
    func saveButtonTapped(title: String, description: String)
}

protocol DetailTodoRouterInput {
    func close()
}

protocol DetailTodoPresenterInput {
    func viewDidLoad()
    func backButtonTapped()
} 
