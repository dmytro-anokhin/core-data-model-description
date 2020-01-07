import XCTest
import CoreData
@testable import CoreDataModelDescription

final class CoreDataModelRelationshipDescriptionTests: XCTestCase {

    final class Parent: NSManagedObject {
        @NSManaged var children: Set<Child>
    }

    final class Child: NSManagedObject {
        @NSManaged var parent: Parent?
    }

    func testCreateRelationshipWithKeyPath() {
        let relationship: CoreDataRelationshipDescription = .relationship(\Child.parent)

        XCTAssert(relationship.optional)
        XCTAssertEqual(relationship.maxCount, 1)
        XCTAssertEqual(relationship.name, "parent")
        XCTAssertEqual(relationship.destination, "Parent")
        XCTAssertNil(relationship.inverse)
        XCTAssertEqual(relationship.deleteRule, .nullifyDeleteRule)
    }

    func testCreateToManyRelationshipWithKeyPath() {
        let relationship: CoreDataRelationshipDescription = .relationship(\Parent.children)

        XCTAssertFalse(relationship.optional)
        XCTAssertEqual(relationship.maxCount, 0)
        XCTAssertEqual(relationship.name, "children")
        XCTAssertEqual(relationship.destination, "Child")
        XCTAssertNil(relationship.inverse)
        XCTAssertEqual(relationship.deleteRule, .nullifyDeleteRule)
    }

    func testCreateRelationshipWithInverseKeyPath() {
        let relationship: CoreDataRelationshipDescription = .relationship(\Parent.children, inverse: \Child.parent)
        XCTAssertEqual(relationship.inverse, "parent")
    }

    func testRelationshipsEquivalent() {
        let relationship: CoreDataRelationshipDescription = .relationship(name: "children", destination: "Child", optional: false, toMany: true, inverse: "parent")
        let keypathRelationship: CoreDataRelationshipDescription = .relationship(\Parent.children, inverse: \Child.parent)

        XCTAssertEqual(relationship.name, keypathRelationship.name)
        XCTAssertEqual(relationship.destination, keypathRelationship.destination)
        XCTAssertEqual(relationship.maxCount, keypathRelationship.maxCount)
        XCTAssertEqual(relationship.optional, keypathRelationship.optional)
        XCTAssertEqual(relationship.deleteRule, keypathRelationship.deleteRule)
        XCTAssertEqual(relationship.inverse, keypathRelationship.inverse)
    }
}
