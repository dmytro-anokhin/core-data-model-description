//
//  CoreDataAttributeDescription.swift
//  CoreDataModelDescription
//
//  Created by Dmytro Anokhin on 12/08/2019.
//  Copyright © 2019 Dmytro Anokhin. All rights reserved.
//

import CoreData


/// Describes and creates`NSAttributeDescription`
public struct CoreDataAttributeDescription {

    public static func attribute(name: String, type: NSAttributeType, isOptional: Bool = false, isIndexed: Bool = false, isIndexedBySpotlight: Bool = false) -> CoreDataAttributeDescription {
        return CoreDataAttributeDescription(name: name, attributeType: type, isOptional: isOptional, isIndexed: isIndexed, isIndexedBySpotlight: isIndexedBySpotlight)
    }

    public var name: String

    public var attributeType: NSAttributeType

    public var isOptional: Bool
    
    public var isIndexed: Bool
    
    public var isIndexedBySpotlight: Bool

    public func makeAttribute() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()        
        attribute.name = name
        attribute.attributeType = attributeType
        attribute.isOptional = isOptional
        attribute.isIndexed = isIndexed
        attribute.isIndexedBySpotlight = isIndexedBySpotlight

        return attribute
    }
}
