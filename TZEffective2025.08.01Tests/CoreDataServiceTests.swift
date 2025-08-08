//
//  CoreDataServiceTests.swift
//  TZEffective2025.08.01Tests
//
//  Created by Валентин on 08.08.2025.
//

import XCTest
import CoreData
@testable import TZEffective2025_08_01


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
