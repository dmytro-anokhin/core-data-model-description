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

final class User: NSManagedObject {
    
    @NSManaged var email: String
    
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

    /**
     User Entity is Stored in a different Configuration as all News Entites
     */
    func testCoreDataModelDescriptionWithConfiguration() throws {

        let modelDescription = CoreDataModelDescription(
            entities: [
                .entity(
                    name: "User",
                    managedObjectClass: User.self,
                    parentEntity: nil,
                    attributes: [
                        .attribute(name: "email", type: .stringAttributeType)
                    ],
                    configuration: "UserData"),
                .entity(
                    name: "Author",
                    managedObjectClass: Author.self,
                    parentEntity: nil,
                    attributes: [
                        .attribute(name: "name", type: .stringAttributeType)
                    ],
                    relationships: [
                        .relationship(name: "publications", destination: "Publication", toMany: true, deleteRule: .cascadeDeleteRule, inverse: "author")
                    ],
                    configuration: "News"),
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
                    ],
                    configuration: "News"),
                .entity(
                    name: "Story",
                    managedObjectClass: Story.self,
                    parentEntity: "Publication",
                    attributes: [
                        .attribute(name: "videoURL", type: .URIAttributeType)
                    ],
                    configuration: "News"),
                .entity(
                    name: "Article",
                    managedObjectClass: Article.self,
                    parentEntity: "Publication",
                    attributes: [
                        .attribute(name: "text", type: .stringAttributeType)
                    ],
                    configuration: "News")
            ]
        )

        let container = makePersistentContainer(name: "CoreDataModelDescriptionTest", modelDescription: modelDescription, configurations: ["UserData", "News"])
        let context = container.viewContext
        
        let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
        user.email = "john.doe@apple.com"

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
        ("testCoreDataModelDescriptionWithConfiguration", testCoreDataModelDescriptionWithConfiguration)
    ]
}


@available(iOS 10.0, OSX 10.12, *)
extension XCTestCase {

    func makePersistentContainer(name: String, modelDescription: CoreDataModelDescription, configurations: [String]? = nil) -> NSPersistentContainer {
        let model = modelDescription.makeModel()

        let persistentContainer = NSPersistentContainer(name: name, managedObjectModel: model)
        
        let persistentStoreDescriptions: [NSPersistentStoreDescription]
        if let configurations = configurations {
            persistentStoreDescriptions =
                    configurations.map { (configurationName) in
                        let persistentStoreDescription = NSPersistentStoreDescription()
                        persistentStoreDescription.type = NSInMemoryStoreType
                        persistentStoreDescription.configuration = configurationName
                        //Need to set URL for distinction, even for Type NSInMemoryStoreType
                        persistentStoreDescription.url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent(configurationName).appendingPathExtension("sqlite")
                        return persistentStoreDescription
                    }
        } else {
            let persistentStoreDescription = NSPersistentStoreDescription()
            persistentStoreDescription.type = NSInMemoryStoreType
            persistentStoreDescriptions = [persistentStoreDescription]
        }

        persistentContainer.persistentStoreDescriptions = persistentStoreDescriptions
        
        let loadPersistentStoresExpectation = expectation(description: "Persistent container expected to load the store")

        var loadedPersistentStoresCount = 0
        
        persistentContainer.loadPersistentStores { description, error in
            XCTAssertNil(error)
            guard let configurations = configurations else {
                loadPersistentStoresExpectation.fulfill()
                return
            }
            loadedPersistentStoresCount += 1
            if loadedPersistentStoresCount == configurations.count {
                loadPersistentStoresExpectation.fulfill()
            }
        }

        wait(for: [loadPersistentStoresExpectation], timeout: 0.1)

        return persistentContainer
    }
}
