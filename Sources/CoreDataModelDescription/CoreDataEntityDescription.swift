//
//  CoreDataEntityDescription.swift
//  CoreDataModelDescription
//
//  Created by Dmytro Anokhin on 12/08/2019.
//  Copyright © 2019 Dmytro Anokhin. All rights reserved.
//

import CoreData


/// Describes and creates `NSEntityDescription`
public struct CoreDataEntityDescription {

    public static func entity(name: String, managedObjectClass: NSManagedObject.Type = NSManagedObject.self, parentEntity: String? = nil, attributes: [CoreDataAttributeDescription] = [], relationships: [CoreDataRelationshipDescription] = [], configuration: String = "Default") -> CoreDataEntityDescription {
        return CoreDataEntityDescription(name: name, managedObjectClassName: NSStringFromClass(managedObjectClass), parentEntity: parentEntity, attributes: attributes, relationships: relationships, configuration: configuration)
    }

    public var name: String

    public var managedObjectClassName: String

    public var parentEntity: String?

    public var attributes: [CoreDataAttributeDescription]

    public var relationships: [CoreDataRelationshipDescription]
    
    public var configuration: String
}
