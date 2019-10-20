//
//  CoreDataFetchedPropertyDescription.swift
//  
//
//  Created by Pascal van der Locht on 23.08.19.
//

import CoreData


/// Describes and creates`NSFetchedPropertyDescription`
public struct CoreDataFetchedPropertyDescription {

    public static func fetchedProperty(name: String, fetchRequest: NSFetchRequest<NSFetchRequestResult>, isOptional: Bool = false) -> CoreDataFetchedPropertyDescription {
        return CoreDataFetchedPropertyDescription(name: name, fetchRequest: fetchRequest, isOptional: isOptional)
    }

    public var name: String

    public var fetchRequest: NSFetchRequest<NSFetchRequestResult>

    public var isOptional: Bool

    public func makeFetchedProperty() -> NSFetchedPropertyDescription {
        let fetchedProperty = NSFetchedPropertyDescription()
        fetchedProperty.name = name
        fetchedProperty.fetchRequest = fetchRequest
        fetchedProperty.isOptional = isOptional

        return fetchedProperty
    }
}
