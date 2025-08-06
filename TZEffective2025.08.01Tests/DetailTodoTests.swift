//
//  DetailTodoTests.swift
//  TZEffective2025.08.01Tests
//
//  Created by Валентин on 02.08.2025.
//

import XCTest
@testable import TZEffective2025_08_01

// MARK: - DetailTodoInteractor Tests
final class DetailTodoInteractorTests: XCTestCase {
    var interactor: DetailTodoInteractor!
    var mockCoreDataService: MockCoreDataService!
    var mockOutput: MockDetailTodoInteractorOutput!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockCoreDataService = MockCoreDataService()
        mockOutput = MockDetailTodoInteractorOutput()
        
        interactor = DetailTodoInteractor(
            todo: nil,
            coreDataService: mockCoreDataService
        )
        interactor.output = mockOutput
    }
    
    override func tearDownWithError() throws {
        interactor = nil
        mockCoreDataService = nil
        mockOutput = nil
        try super.tearDownWithError()
    }
    
    func testLoadTodoForNewTask() {
        // Given
        let expectation = XCTestExpectation(description: "Load todo for new task")
        
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
    
    func testLoadTodoForExistingTask() {
        // Given
        let existingTodo = TodoItemViewModel(
            id: 1,
            title: "Existing Task",
            describe: "Existing Description",
            isCompleted: false,
            createdAt: Date(),
            userId: 1
        )
        
        interactor = DetailTodoInteractor(
            todo: existingTodo,
            coreDataService: mockCoreDataService
        )
        interactor.output = mockOutput
        
        let expectation = XCTestExpectation(description: "Load existing todo")
        
        mockOutput.didLoadTodoCalled = { todo in
            XCTAssertEqual(todo.id, 1)
            XCTAssertEqual(todo.title, "Existing Task")
            XCTAssertEqual(todo.describe, "Existing Description")
            expectation.fulfill()
        }
        
        // When
        interactor.loadTodo()
        
        // Then
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testSaveTodoForNewTask() {
        // Given
        let expectation = XCTestExpectation(description: "Save new todo")
        let title = "New Task"
        let description = "New Description"
        
        mockOutput.didSaveTodoCalled = { id, title, description, isNew in
            XCTAssertGreaterThan(id, 0)
            XCTAssertEqual(title, "New Task")
            XCTAssertEqual(description, "New Description")
            XCTAssertTrue(isNew)
            expectation.fulfill()
        }
        
        // When
        interactor.saveTodo(title: title, description: description)
        
        // Then
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testSaveTodoForExistingTask() {
        // Given
        let existingTodo = TodoItemViewModel(
            id: 1,
            title: "Existing Task",
            describe: "Existing Description",
            isCompleted: false,
            createdAt: Date(),
            userId: 1
        )
        
        interactor = DetailTodoInteractor(
            todo: existingTodo,
            coreDataService: mockCoreDataService
        )
        interactor.output = mockOutput
        
        let expectation = XCTestExpectation(description: "Save existing todo")
        let newTitle = "Updated Task"
        let newDescription = "Updated Description"
        
        mockOutput.didSaveTodoCalled = { id, title, description, isNew in
            XCTAssertEqual(id, 1)
            XCTAssertEqual(title, "Updated Task")
            XCTAssertEqual(description, "Updated Description")
            XCTAssertFalse(isNew)
            expectation.fulfill()
        }
        
        // When
        interactor.saveTodo(title: newTitle, description: newDescription)
        
        // Then
        wait(for: [expectation], timeout: 5.0)
    }
}

// MARK: - DetailTodoPresenter Tests
final class DetailTodoPresenterTests: XCTestCase {
    var presenter: DetailTodoPresenter!
    var mockInteractor: MockDetailTodoInteractor!
    var mockView: MockDetailTodoView!
    var mockRouter: MockDetailTodoRouter!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockInteractor = MockDetailTodoInteractor()
        mockView = MockDetailTodoView()
        mockRouter = MockDetailTodoRouter()
        
        presenter = DetailTodoPresenter(
            interactor: mockInteractor,
            view: mockView,
            router: mockRouter
        )
    }
    
    override func tearDownWithError() throws {
        presenter = nil
        mockInteractor = nil
        mockView = nil
        mockRouter = nil
        try super.tearDownWithError()
    }
    
    func testViewDidLoad() {
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(mockInteractor.loadTodoCalled)
    }
    
    func testSaveButtonTapped() {
        // Given
        let title = "Test Title"
        let description = "Test Description"
        
        // When
        presenter.saveButtonTapped(title: title, description: description)
        
        // Then
        XCTAssertTrue(mockInteractor.saveTodoCalled)
        XCTAssertEqual(mockInteractor.saveTodoTitle, title)
        XCTAssertEqual(mockInteractor.saveTodoDescription, description)
    }
    
    func testDidLoadTodo() {
        // Given
        let todo = TodoItemViewModel(
            id: 1,
            title: "Test Todo",
            describe: "Test Description",
            isCompleted: false,
            createdAt: Date(),
            userId: 1
        )
        
        // When
        presenter.didLoadTodo(todo)
        
        // Then
        XCTAssertTrue(mockView.displayTodoCalled)
        XCTAssertEqual(mockView.displayedTodo?.id, 1)
        XCTAssertEqual(mockView.displayedTodo?.title, "Test Todo")
    }
    
    func testDidSaveTodo() {
        // Given
        let expectation = XCTestExpectation(description: "Save todo completion")
        
        mockView.updateTodoInListCalled = { id, title, description, isNew in
            XCTAssertEqual(id, 1)
            XCTAssertEqual(title, "Test Title")
            XCTAssertEqual(description, "Test Description")
            XCTAssertFalse(isNew)
            expectation.fulfill()
        }
        
        // When
        presenter.didSaveTodo(id: 1, title: "Test Title", description: "Test Description", isNew: false)
        
        // Then
        wait(for: [expectation], timeout: 5.0)
    }
}

// MARK: - Mock Classes for DetailTodo
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

class MockDetailTodoView: DetailTodoViewInput {
    var displayTodoCalled = false
    var displayedTodo: TodoItemViewModel?
    var updateTodoInListCalled: ((Int, String, String, Bool) -> Void)?
    
    func displayTodo(_ todo: TodoItemViewModel) {
        displayTodoCalled = true
        displayedTodo = todo
    }
    
    func showError(_ message: String) {
        // Mock implementation
    }
    
    func closeView() {
        // Mock implementation
    }
    
    func updateTodoInList(id: Int, title: String, description: String, isNew: Bool) {
        updateTodoInListCalled?(id, title, description, isNew)
    }
}

class MockDetailTodoRouter: DetailTodoRouterInput {
    // Mock implementation
} 
