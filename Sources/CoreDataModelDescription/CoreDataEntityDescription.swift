//
//  CoreDataEntityDescription.swift
//  CoreDataModelDescription
//
//  Created by Dmytro Anokhin on 12/08/2019.
//  Copyright © 2019 Dmytro Anokhin. All rights reserved.
//

import CoreData


/// Describes and creates `NSEntityDescription`
@available(iOS 11.0, tvOS 11.0, macOS 10.13, *)
public struct CoreDataEntityDescription {

    public static func entity(name: String,
                              managedObjectClass: NSManagedObject.Type = NSManagedObject.self,
                              parentEntity: String? = nil,
                              isAbstract: Bool = false,
                              attributes: [CoreDataAttributeDescription] = [],
                              fetchedProperties: [CoreDataFetchedPropertyDescription] = [],
                              relationships: [CoreDataRelationshipDescription] = [],
                              indexes: [CoreDataFetchIndexDescription] = [],
                              constraints: [Any] = [],
                              configuration: String? = nil) -> CoreDataEntityDescription {
        CoreDataEntityDescription(name: name, managedObjectClassName: NSStringFromClass(managedObjectClass), parentEntity: parentEntity, isAbstract: isAbstract, attributes: attributes, fetchedProperties: fetchedProperties, relationships: relationships, indexes: indexes, constraints: constraints, configuration: configuration)
    }
    
    public var name: String

    public var managedObjectClassName: String

    public var parentEntity: String?

    public var isAbstract: Bool

    public var attributes: [CoreDataAttributeDescription]
    
    public var fetchedProperties: [CoreDataFetchedPropertyDescription]

    public var relationships: [CoreDataRelationshipDescription]

    public var indexes: [CoreDataFetchIndexDescription]

    public var constraints: [Any]

    public var configuration: String?
}
