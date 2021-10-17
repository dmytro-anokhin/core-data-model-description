import XCTest
import CoreData
@testable import CoreDataModelDescription

// MARK: - Core Data Managed Objects

final class Publisher: NSManagedObject {

    @NSManaged var name: String?

}

final class Author: NSManagedObject {

    @NSManaged var name: String?

    @NSManaged public var publications: Set<Publication>?
}

class Publication: NSManagedObject {

    @NSManaged var publicationDate: Date?

    @NSManaged var numberOfViews: Int64

    @NSManaged var author: Author?
    
    @NSManaged var publisherHouse: Publisher?
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

@available(iOS 11.0, tvOS 11.0, macOS 10.13, *)
final class CoreDataModelDescriptionTests: XCTestCase {

    func testCoreDataModelDescription() throws {
        
        let baseModelDescription = CoreDataModelDescription(
            entities: [
                .entity(
                    name: "Publisher",
                    managedObjectClass: Publisher.self,
                    parentEntity: nil,
                    attributes: [
                        .attribute(name: "name", type: .stringAttributeType)
                    ],
                    relationships: [
                    ],
                    indexes: [
                        .index(name: "byName", elements: [ .property(name: "name") ])
                    ])
            ]
        )

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
                    ],
                    indexes: [
                        .index(name: "byName", elements: [ .property(name: "name") ])
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
                        .relationship(name: "author", destination: "Author", toMany: false, inverse: "publications"),
                        .relationship(name: "publisherHouse", destination: "Publisher", toMany: false)
                    ],
                    indexes: [
                        .index(name: "byAuthor", elements: [ .property(name: "author") ]),
                        .index(name: "byAuthorByPublicationDate", elements: [ .property(name: "publicationDate") ]),
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

        let container = makePersistentContainer(name: "CoreDataModelDescriptionTest", baseModelDescription: baseModelDescription, modelDescription: modelDescription)
        let context = container.viewContext

        let publisher = NSEntityDescription.insertNewObject(forEntityName: "Publisher", into: context) as! Publisher
        publisher.name = "Great House"
        
        let author = NSEntityDescription.insertNewObject(forEntityName: "Author", into: context) as! Author
        author.name = "John Doe"

        let articleDate = Date()
        let storyDate = articleDate.addingTimeInterval(60.0)

        let article = NSEntityDescription.insertNewObject(forEntityName: "Article", into: context) as! Article
        article.publicationDate = articleDate
        article.text = "This is an article"
        article.author = author
        article.publisherHouse = publisher

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
                    constraints: [
                        "email"
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
                        .relationship(name: "publications", destination: "Publication", toMany: true, deleteRule: .cascadeDeleteRule, inverse: "author", ordered: true)
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
                    indexes: [
                        .index(name: "byAuthor", elements: [ .property(name: "author") ]),
                        .index(name: "byAuthorByPublicationDate", elements: [ .property(name: "publicationDate") ]),
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
        
        let duplicatedUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
        duplicatedUser.email = "john.doe@apple.com"

        
        XCTAssertThrowsError(try context.save())

        let request = NSFetchRequest<User>(entityName: "User")
        XCTAssertEqual(try context.count(for: request), 2)
        
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        XCTAssertNoThrow(try context.save())
        XCTAssertEqual(try context.count(for: request), 1)
    }

    func testCoreDataModelDescriptionWithKeypaths() throws {
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
                        .relationship(\Author.publications, inverse: \Publication.author, deleteRule: .cascadeDeleteRule)
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
                        .relationship(\Publication.author, inverse: \Author.publications)
                    ],
                    indexes: [
                        .index(name: "byAuthor", elements: [ .property(name: "author") ]),
                        .index(name: "byAuthorByPublicationDate", elements: [ .property(name: "publicationDate") ]),
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

    func testAbstractEntity() {
        class Abstract: NSManagedObject {
            @NSManaged var name: String
        }

        final class Concrete: Abstract {
            @NSManaged var id: Int
        }

        let modelDescription = CoreDataModelDescription(entities: [
            .entity(name: "Abstract", managedObjectClass: Abstract.self, isAbstract: true, attributes: [.attribute(name: "name", type: .stringAttributeType)]),
            .entity(name: "Concrete", managedObjectClass: Concrete.self, parentEntity: "Abstract", attributes: [.attribute(name: "id", type: .integer64AttributeType)])
        ])

        let container = makePersistentContainer(name: "CoreDataModelDescriptionTest", modelDescription: modelDescription)
        let context = container.viewContext

        let abstractEntityDescription = NSEntityDescription.entity(forEntityName: "Abstract", in: context)
        XCTAssert(abstractEntityDescription?.isAbstract == true, "Entity is not marked as abstract in entity model")
    }
    
    static var allTests = [
        ("testCoreDataModelDescription", testCoreDataModelDescription),
        ("testCoreDataModelDescriptionWithConfiguration", testCoreDataModelDescriptionWithConfiguration)
    ]
}


@available(iOS 11.0, tvOS 11.0, macOS 10.13, *)
extension XCTestCase {

    func makePersistentContainer(name: String, baseModelDescription: CoreDataModelDescription?=nil, modelDescription: CoreDataModelDescription, configurations: [String]? = nil) -> NSPersistentContainer {

        var model:NSManagedObjectModel
        if baseModelDescription == nil {
            model = modelDescription.makeModel()
        } else {
            model = modelDescription.makeModel(byMerging: baseModelDescription!.makeModel())
        }

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
