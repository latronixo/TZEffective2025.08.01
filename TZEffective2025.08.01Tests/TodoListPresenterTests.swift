//
//  TodoListPresenterTests.swift
//  TZEffective2025.08.01Tests
//
//  Created by Валентин on 08.08.2025.
//

import XCTest
import CoreData
@testable import TZEffective2025_08_01

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

