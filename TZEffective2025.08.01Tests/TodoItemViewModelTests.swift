//
//  TodoItemViewModelTests.swift
//  TZEffective2025.08.01Tests
//
//  Created by Валентин on 08.08.2025.
//

import XCTest
import CoreData
@testable import TZEffective2025_08_01

// MARK: - TodoItemViewModel Tests
final class TodoItemViewModelTests: XCTestCase {
    
    var testContainer: NSPersistentContainer!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        testContainer = NSPersistentContainer(name: "TodoDataModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        testContainer.persistentStoreDescriptions = [description]
        testContainer.loadPersistentStores { _, error in
            if let error = error {
                XCTFail("Failed to load in-memory store: \(error)")
            }
        }
    }
    
    override func tearDownWithError() throws {
        testContainer = nil
        try super.tearDownWithError()
    }
    
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
        let entity = NSEntityDescription.entity(forEntityName: "TodoItem", in: testContainer.viewContext)!
        
        let managedObject = NSManagedObject(entity: entity, insertInto: testContainer.viewContext)
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
