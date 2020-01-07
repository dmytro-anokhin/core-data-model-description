import XCTest
import CoreData
@testable import CoreDataModelDescription

final class KeyPathExtensionTests: XCTestCase {

    final class TestModel: NSObject {
        @objc var string: String = "test"
        @objc var optionalString: String?

        @objc var set: Set<String> = []
        @objc var optionalSet: Set<String>?
    }

    func testKeyPathRootType() {
        let keypath = \TestModel.string
        XCTAssert(keypath.rootType is TestModel.Type)
    }

    func testKeyPathDestinationType() {
        let stringPath = \TestModel.string
        XCTAssert(stringPath.destinationType is String.Type)

        let optionalStringPath = \TestModel.optionalString
        XCTAssert(optionalStringPath.destinationType is String.Type)

        let setPath = \TestModel.set
        XCTAssert(setPath.destinationType is String.Type)
        XCTAssertFalse(setPath.destinationType is Optional<Set<String>>.Type)
        XCTAssertFalse(setPath.destinationType is Set<AnyHashable>.Type)

        let optionalSetPath = \TestModel.optionalSet
        XCTAssert(optionalSetPath.destinationType is String.Type)
    }

    func testKeyPathStringValue() {
        let keypath = \TestModel.string
        XCTAssertEqual(keypath.stringValue, "string")
    }

    func testKeyPathIsToMany() {
        let stringPath = \TestModel.string
        XCTAssertFalse(stringPath.isToMany)

        let optionalStringPath = \TestModel.optionalString
        XCTAssertFalse(optionalStringPath.isToMany)

        let setPath = \TestModel.set
        XCTAssert(setPath.isToMany)

        let optionalSetPath = \TestModel.optionalSet
        XCTAssert(optionalSetPath.isToMany)
    }

    func testKeyPathIsOptional() {
        let string = \TestModel.string
        XCTAssertFalse(string.isOptional)

        let optionalString = \TestModel.optionalString
        XCTAssert(optionalString.isOptional)
    }
}
