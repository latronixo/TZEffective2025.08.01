//
//  TodoListInteractorTests.swift
//  TZEffective2025.08.01Tests
//
//  Created by Валентин on 08.08.2025.
//

import XCTest
import CoreData
@testable import TZEffective2025_08_01

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
        let loadExpectation = XCTestExpectation(description: "Initial load completed")
        let searchExpectation = XCTestExpectation(description: "Search completed")
        
        let mockTodos = [
            TodoItemViewModel(id: 1, title: "Apple", describe: "Apple description", isCompleted: false, createdAt: Date(), userId: 1),
            TodoItemViewModel(id: 2, title: "Banana", describe: "Banana description", isCompleted: true, createdAt: Date(), userId: 1),
            TodoItemViewModel(id: 3, title: "Orange", describe: "Orange description", isCompleted: false, createdAt: Date(), userId: 1)
        ]
        mockCoreDataService.mockTodos = mockTodos
        mockUserDefaultsService.isNotFirstLaunchResult = true
        
        // Сначала настраиваем замыкания для output
        mockOutput.didLoadTodosCalled = { _ in
            loadExpectation.fulfill()
        }
        
        mockOutput.didUpdateTodosCalled = { todos in
            XCTAssertEqual(todos.count, 1)
            XCTAssertEqual(todos[0].title, "Apple")
            searchExpectation.fulfill()
        }
        
        // When 1: Загружаем задачи
        interactor.loadTodos()
        
        // Then 1: Ждем завершения загрузки
        wait(for: [loadExpectation], timeout: 5.0)
        
        // When 2: Теперь, когда задачи загружены: выполняем поиск
        interactor.searchTodos(with: "Apple")
        
        // Then 2: ждем завершения поиска
        wait(for: [searchExpectation], timeout: 5.0)
    }
    
    func testSearchTodosWithEmptyQuery() {
        // Given
        let loadExpectation = XCTestExpectation(description: "Initial load for empty query test completed")
        let searchExpectation = XCTestExpectation(description: "Search with empty query completed")
        
        let mockTodos = [
            TodoItemViewModel(id: 1, title: "Test 1", describe: "Desc 1", isCompleted: false, createdAt: Date(), userId: 1),
            TodoItemViewModel(id: 2, title: "Test 2", describe: "Desc 2", isCompleted: true, createdAt: Date(), userId: 1)
        ]
        mockCoreDataService.mockTodos = mockTodos
        mockUserDefaultsService.isNotFirstLaunchResult = true
        
        mockOutput.didLoadTodosCalled = { _ in
            loadExpectation.fulfill()
        }
        
        mockOutput.didUpdateTodosCalled = { todos in
            XCTAssertEqual(todos.count, 2)
            searchExpectation.fulfill()
        }
        
        // When 1: загружаем todos
        interactor.loadTodos()
        
        //Then 1: Ждем завершения загрузки
        wait(for: [loadExpectation], timeout: 5.0)
        
        // When 2: теперь, когда задачи загружены, выполняем поиск
        interactor.searchTodos(with: "")
        
        // Then2: ждем завершени поиска
        wait(for: [searchExpectation], timeout: 5.0)
    }
    
    func testToggleTodoCompletion() {
        // Given
        let loadExpectation = XCTestExpectation(description: "Initial load for toggle test completed")
        let toggleExpectation = XCTestExpectation(description: "Toggle todo completion completed")
        
        let mockTodos = [
            TodoItemViewModel(id: 1, title: "Test 1", describe: "Desc 1", isCompleted: false, createdAt: Date(), userId: 1)
        ]
        mockCoreDataService.mockTodos = mockTodos
        mockUserDefaultsService.isNotFirstLaunchResult = true
        
        mockOutput.didLoadTodosCalled = { _ in
            loadExpectation.fulfill()
        }
        
        mockOutput.didUpdateTodosCalled = { todos in
            XCTAssertEqual(todos.count, 1)
            XCTAssertTrue(todos[0].isCompleted)
            toggleExpectation.fulfill()
        }
        
        // When 1: загружаем todos
        interactor.loadTodos()
        
        // Then 1: ждем завершения загрузки
        wait(for: [loadExpectation], timeout: 5.0)
        
        // When 2: теперь, когда задачи загружены, переключаем статус
        interactor.toggleTodoCompletion(id: 1)
        
        // Then 2: Ждем завершения переключения и проверяем результат
        wait(for: [toggleExpectation], timeout: 5.0)
        XCTAssertTrue(mockCoreDataService.updateTodoCompletionCalled)
    }
    
    func testDeleteTodo() {
        // Given
        let loadExpectation = XCTestExpectation(description: "Initial load for delete test completed")
        let deleteExpectation = XCTestExpectation(description: "Delete todo completed")
        
        let mockTodos = [
            TodoItemViewModel(id: 1, title: "Test 1", describe: "Desc 1", isCompleted: false, createdAt: Date(), userId: 1),
            TodoItemViewModel(id: 2, title: "Test 2", describe: "Desc 2", isCompleted: true, createdAt: Date(), userId: 1)
        ]
        mockCoreDataService.mockTodos = mockTodos
        mockUserDefaultsService.isNotFirstLaunchResult = true
        
        mockOutput.didLoadTodosCalled = { _ in
            loadExpectation.fulfill()
        }
        
        mockOutput.didDeleteTodoCalled = { todos in
            XCTAssertEqual(todos.count, 1)
            XCTAssertEqual(todos[0].id, 2)
            deleteExpectation.fulfill()
        }
        
        // When 1: загружаем задачи
        interactor.loadTodos()
        
        // Then 1: ждем завершения загрузки
        wait(for: [loadExpectation], timeout: 5.0)
        
        // When 2: теперь, когда задачи загружены, удаляем одну
        interactor.deleteTodo(1)
        
        // Then 2: ждем завершения удаления и проверяем результат
        wait(for: [deleteExpectation], timeout: 5.0)
        XCTAssertTrue(mockCoreDataService.deleteTodoCalled)
    }
    
    func testUpdateTodo() {
        // Given
        let loadExpectation = XCTestExpectation(description: "Initial load for delete test completed")
        let updateExpectation = XCTestExpectation(description: "Update todo completed")
        
        let mockTodos = [
            TodoItemViewModel(id: 1, title: "Old Title", describe: "Old Description", isCompleted: false, createdAt: Date(), userId: 1)
        ]
        
        mockCoreDataService.mockTodos = mockTodos
        mockUserDefaultsService.isNotFirstLaunchResult = true
        
        mockOutput.didLoadTodosCalled = { _ in
            loadExpectation.fulfill()
        }
        
        mockOutput.didUpdateTodosCalled = { todos in
            XCTAssertEqual(todos.count, 1)
            XCTAssertEqual(todos[0].title, "New Title")
            XCTAssertEqual(todos[0].describe, "New Description")
            updateExpectation.fulfill()
        }
        
        // When 1: Сначала загружаем todos
        interactor.loadTodos()
        
        //Then 1: ждем завершения загрузки
        wait(for: [loadExpectation], timeout: 5.0)
        
        // When 2: меняем название и описание
        interactor.updateTodo(id: 1, title: "New Title", description: "New Description")
        
        // Then 2: ждем завершения загрузки
        wait(for: [updateExpectation], timeout: 5.0)
    }
}
