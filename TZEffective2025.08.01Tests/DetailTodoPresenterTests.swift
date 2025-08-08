//
//  DetailTodoPresenterTests.swift
//  TZEffective2025.08.01Tests
//
//  Created by Валентин on 08.08.2025.
//

import XCTest
import CoreData
@testable import TZEffective2025_08_01

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
        let title = "Test Title"
        let description = "Test Description"
        
        // When
        presenter.backButtonTapped(title: title, description: description)
        
        // Then
        XCTAssertTrue(mockInteractor.saveTodoCalled, "Метод saveTodo должен был быть вызван, так как title не пустой.")
        XCTAssertEqual(mockInteractor.saveTodoTitle, title)
        XCTAssertEqual(mockInteractor.saveTodoDescription, description)
    }
    
    func testBackButtonTappedWithEmptyTitleShouldShowError() {
        // Given
        let title = ""
        let description = "Some description"
        
        // When
        presenter.backButtonTapped(title: title, description: description)
        
        // Then
        XCTAssertFalse(mockInteractor.saveTodoCalled, "Метод saveTodo не должен был быть вызван.")
        XCTAssertTrue(mockView.showErrorCalled, "Метод showError должен был быть вызван.")
    }

    func testBackButtonTappedWithEmptyFieldsShouldClose() {
        // Given
        let title = ""
        let description = ""
        
        // When
        presenter.backButtonTapped(title: title, description: description)
        
        // Then
        XCTAssertFalse(mockInteractor.saveTodoCalled, "Метод saveTodo не должен был быть вызван.")
        XCTAssertTrue(mockView.closeViewCalled, "Метод closeView должен был быть вызван.")
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

