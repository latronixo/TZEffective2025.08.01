//
//  DetailTodoInteractorTests.swift
//  TZEffective2025.08.01Tests
//
//  Created by Валентин on 08.08.2025.
//

import XCTest
import CoreData
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

