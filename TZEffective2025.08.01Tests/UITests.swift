//
//  UITests.swift
//  TZEffective2025.08.01Tests
//
//  Created by Валентин on 02.08.2025.
//

import XCTest
@testable import TZEffective2025_08_01

// MARK: - ContextMenu Tests
final class ContextMenuTests: XCTestCase {
    var contextMenu: ContextMenu!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        contextMenu = ContextMenu()
    }
    
    override func tearDownWithError() throws {
        contextMenu = nil
        try super.tearDownWithError()
    }
    
    func testContextMenuInitialization() {
        // Then
        XCTAssertNotNil(contextMenu)
        XCTAssertNotNil(contextMenu.view)
    }
    
    func testConfigureWithTodo() {
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
        contextMenu.configure(with: todo)
        
        // Then
        XCTAssertEqual(contextMenu.todo?.id, 1)
        XCTAssertEqual(contextMenu.todo?.title, "Test Todo")
        XCTAssertEqual(contextMenu.todo?.describe, "Test Description")
    }
    
    func testCreateTodoInfoView() {
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
        let todoInfoView = ContextMenu.createTodoInfoView()
        
        // Then
        XCTAssertNotNil(todoInfoView)
        XCTAssertTrue(todoInfoView.subviews.count > 0)
    }
}

// MARK: - TodoTableViewCell Tests
final class TodoTableViewCellTests: XCTestCase {
    var cell: TodoTableViewCell!
    var mockDelegate: MockTodoTableViewCellDelegate!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        cell = TodoTableViewCell(style: .default, reuseIdentifier: "TestCell")
        mockDelegate = MockTodoTableViewCellDelegate()
        cell.delegate = mockDelegate
    }
    
    override func tearDownWithError() throws {
        cell = nil
        mockDelegate = nil
        try super.tearDownWithError()
    }
    
    func testCellInitialization() {
        // Then
        XCTAssertNotNil(cell)
        XCTAssertNotNil(cell.containerView)
    }
    
    func testConfigureWithTodo() {
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
        cell.configure(with: todo)
        
        // Then
        XCTAssertEqual(cell.todo?.id, 1)
        XCTAssertEqual(cell.todo?.title, "Test Todo")
    }
    
    func testTapGestureRecognizer() {
        // Given
        let todo = TodoItemViewModel(
            id: 1,
            title: "Test Todo",
            describe: "Test Description",
            isCompleted: false,
            createdAt: Date(),
            userId: 1
        )
        cell.configure(with: todo)
        
        // When
        cell.handleTap()
        
        // Then
        XCTAssertTrue(mockDelegate.todoCellDidTapCalled)
        XCTAssertEqual(mockDelegate.tappedTodo?.id, 1)
    }
}

// MARK: - Assembly Tests
final class AssemblyTests: XCTestCase {
    
    func testDetailTodoAssembly() {
        // Given
        let mockCoreDataService = MockCoreDataService()
        let todo = TodoItemViewModel(
            id: 1,
            title: "Test Todo",
            describe: "Test Description",
            isCompleted: false,
            createdAt: Date(),
            userId: 1
        )
        
        // When
        let viewController = DetailTodoAssembly.assembleDetailTodoModule(
            todo: todo,
            coreDataService: mockCoreDataService
        )
        
        // Then
        XCTAssertNotNil(viewController)
        XCTAssertTrue(viewController is UINavigationController)
        
        let navigationController = viewController as! UINavigationController
        XCTAssertNotNil(navigationController.topViewController)
        XCTAssertTrue(navigationController.topViewController is DetailTodoView)
    }
    
    func testDetailTodoAssemblyForNewTodo() {
        // Given
        let mockCoreDataService = MockCoreDataService()
        
        // When
        let viewController = DetailTodoAssembly.assembleDetailTodoModule(
            todo: nil,
            coreDataService: mockCoreDataService
        )
        
        // Then
        XCTAssertNotNil(viewController)
        XCTAssertTrue(viewController is UINavigationController)
        
        let navigationController = viewController as! UINavigationController
        XCTAssertNotNil(navigationController.topViewController)
        XCTAssertTrue(navigationController.topViewController is DetailTodoView)
    }
}

// MARK: - Integration Tests
final class IntegrationTests: XCTestCase {
    var todoListPresenter: TodoListPresenter!
    var mockInteractor: MockTodoListInteractor!
    var mockRouter: MockTodoListRouter!
    var mockView: MockTodoListView!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockInteractor = MockTodoListInteractor()
        mockRouter = MockTodoListRouter()
        mockView = MockTodoListView()
        
        todoListPresenter = TodoListPresenter(
            interactor: mockInteractor,
            router: mockRouter,
            view: mockView
        )
    }
    
    override func tearDownWithError() throws {
        todoListPresenter = nil
        mockInteractor = nil
        mockRouter = nil
        mockView = nil
        try super.tearDownWithError()
    }
    
    func testCompleteTodoFlow() {
        // Given
        let expectation = XCTestExpectation(description: "Complete todo flow")
        
        // When
        todoListPresenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(mockInteractor.loadTodosCalled)
        expectation.fulfill()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testAddNewTodoFlow() {
        // Given
        let expectation = XCTestExpectation(description: "Add new todo flow")
        
        // When
        todoListPresenter.addNewTodo()
        
        // Then
        XCTAssertTrue(mockRouter.openAddNewTodoScreenCalled)
        expectation.fulfill()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testEditTodoFlow() {
        // Given
        let expectation = XCTestExpectation(description: "Edit todo flow")
        let id = 1
        let title = "Updated Title"
        let description = "Updated Description"
        
        // When
        todoListPresenter.updateTodoAfterEdit(id: id, title: title, description: description)
        
        // Then
        XCTAssertTrue(mockInteractor.updateTodoCalled)
        XCTAssertEqual(mockInteractor.updateTodoId, id)
        XCTAssertEqual(mockInteractor.updateTodoTitle, title)
        XCTAssertEqual(mockInteractor.updateTodoDescription, description)
        expectation.fulfill()
        
        wait(for: [expectation], timeout: 5.0)
    }
}

// MARK: - Performance Tests
final class PerformanceTests: XCTestCase {
    
    func testTodoItemViewModelCreationPerformance() {
        // Given
        let apiItem = TodoItemAPI(id: 1, todo: "Test Todo", completed: true, userId: 1)
        
        // When & Then
        measure {
            for _ in 0..<1000 {
                _ = TodoItemViewModel(from: apiItem)
            }
        }
    }
    
    func testTodoListSortingPerformance() {
        // Given
        var todos: [TodoItemViewModel] = []
        for i in 0..<1000 {
            todos.append(TodoItemViewModel(
                id: i,
                title: "Todo \(i)",
                describe: "Description \(i)",
                isCompleted: false,
                createdAt: Date().addingTimeInterval(Double(i)),
                userId: 1
            ))
        }
        
        // When & Then
        measure {
            _ = todos.sorted { $0.createdAt > $1.createdAt }
        }
    }
}

// MARK: - Mock Classes for UI Tests
class MockTodoTableViewCellDelegate: TodoTableViewCellDelegate {
    var todoCellDidTapCalled = false
    var tappedTodo: TodoItemViewModel?
    
    func todoCellDidTap(_ todo: TodoItemViewModel) {
        todoCellDidTapCalled = true
        tappedTodo = todo
    }
} 
