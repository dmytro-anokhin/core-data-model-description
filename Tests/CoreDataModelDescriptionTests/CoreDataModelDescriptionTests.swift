import XCTest
import CoreData
@testable import CoreDataModelDescription

// MARK: - Core Data Managed Objects

final class Author: NSManagedObject {

    @NSManaged var name: String?

    @NSManaged public var publications: NSSet?
}

class Publication: NSManagedObject {

    @NSManaged var publicationDate: Date?

    @NSManaged var numberOfViews: Int64

    @NSManaged var author: Author?
}

final class Story: Publication {

    @NSManaged var videoURL: URL?
}

final class Article: Publication {

    @NSManaged var text: String?
}

// MARK: - Test

@available(iOS 11.0, OSX 10.13, *)
final class CoreDataModelDescriptionTests: XCTestCase {

    func testCoreDataModelDescription() throws {

        let modelDescription = CoreDataModelDescription(
            entities: [
                .entity(
                    name: "Author",
                    managedObjectClass: Author.self,
                    parentEntity: nil,
                    attributes: [
                        .attribute(name: "name", type: .stringAttributeType)
                    ],
                    relationships: [
                        .relationship(name: "publications", destination: "Publication", toMany: true, deleteRule: .cascadeDeleteRule, inverse: "author")
                    ]),
                .entity(
                    name: "Publication",
                    managedObjectClass: Publication.self,
                    parentEntity: nil,
                    attributes: [
                        .attribute(name: "publicationDate", type: .dateAttributeType),
                        .attribute(name: "numberOfViews", type: .integer64AttributeType, isOptional: true)
                    ],
                    relationships: [
                        .relationship(name: "author", destination: "Author", toMany: false, inverse: "publications")
                    ]),
                .entity(
                    name: "Story",
                    managedObjectClass: Story.self,
                    parentEntity: "Publication",
                    attributes: [
                        .attribute(name: "videoURL", type: .URIAttributeType)
                    ]),
                .entity(
                    name: "Article",
                    managedObjectClass: Article.self,
                    parentEntity: "Publication",
                    attributes: [
                        .attribute(name: "text", type: .stringAttributeType)
                    ])
            ]
        )

        let container = makePersistentContainer(name: "CoreDataModelDescriptionTest", modelDescription: modelDescription)
        let context = container.viewContext

        let author = NSEntityDescription.insertNewObject(forEntityName: "Author", into: context) as! Author
        author.name = "John Doe"

        let articleDate = Date()
        let storyDate = articleDate.addingTimeInterval(60.0)

        let article = NSEntityDescription.insertNewObject(forEntityName: "Article", into: context) as! Article
        article.publicationDate = articleDate
        article.text = "This is an article"
        article.author = author

        let story = NSEntityDescription.insertNewObject(forEntityName: "Story", into: context) as! Story
        story.publicationDate = storyDate
        story.videoURL = URL(string: "https://video")
        story.author = author

        try context.save()
    }

    static var allTests = [
        ("testCoreDataModelDescription", testCoreDataModelDescription),
    ]
}


@available(iOS 10.0, OSX 10.12, *)
extension XCTestCase {

    func makePersistentContainer(name: String, modelDescription: CoreDataModelDescription) -> NSPersistentContainer {
        let model = modelDescription.makeModel()

        let persistentContainer = NSPersistentContainer(name: name, managedObjectModel: model)

        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [persistentStoreDescription]

        let loadPersistentStoresExpectation = expectation(description: "Persistent container expected to load the store")

        persistentContainer.loadPersistentStores { description, error in
            XCTAssertNil(error)
            loadPersistentStoresExpectation.fulfill()
        }

        wait(for: [loadPersistentStoresExpectation], timeout: 0.1)

        return persistentContainer
    }
}
