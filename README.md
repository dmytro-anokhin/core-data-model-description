# CoreDataModelDescription

Declarative way to describe a Core Data model in code.

## Usage

Use `CoreDataModelDescription` to describe your model. Sample code describes this model:

![Image of Author, Publication, and Article model](https://miro.medium.com/max/1400/1*j7NgD-RplJ13E6j1Lzao0A.png)

Assuming you already defined `Author`, `Publication`, and `Article` subclasses of `NSManagedObject`.

```swift
let modelDescription = CoreDataModelDescription(
    entities: [
        .entity(
            name: "Author",
            managedObjectClass: Author.self,
            attributes: [
                .attribute(name: "name", type: .stringAttributeType)
            ],
            relationships: [
                .relationship(name: "publications", destination: "Publication", toMany: true, deleteRule: .cascadeDeleteRule, inverse: "author")
            ]),
        .entity(
            name: "Publication",
            managedObjectClass: Publication.self,
            attributes: [
                .attribute(name: "publicationDate", type: .dateAttributeType),
                .attribute(name: "numberOfViews", type: .integer64AttributeType, isOptional: true)
            ],
            relationships: [
                .relationship(name: "author", destination: "Author", toMany: false, inverse: "publications")
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

let model = modelDescription.makeModel()
```

## Article

This package described in my article [Core Data and Swift Package Manager](https://medium.com/@dmytro.anokhin/core-data-and-swift-package-manager-6ed9ff70921a).
