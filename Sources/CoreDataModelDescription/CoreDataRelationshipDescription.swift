//
//  CoreDataRelationshipDescription.swift
//  CoreDataModelDescription
//
//  Created by Dmytro Anokhin on 12/08/2019.
//  Copyright © 2019 Dmytro Anokhin. All rights reserved.
//

import CoreData


public struct CoreDataRelationshipDescription {

    public static func relationship(
               name: String,
        destination: String,
           optional: Bool = true,
             toMany: Bool = false,
         deleteRule: NSDeleteRule = .nullifyDeleteRule,
            inverse: String? = nil) -> CoreDataRelationshipDescription {

        let maxCount = toMany ? 0 : 1

        return CoreDataRelationshipDescription(name: name, destination: destination, optional: optional, maxCount: maxCount, minCount: 0, deleteRule: deleteRule, inverse: inverse)
    }

    public var name: String

    public var destination: String

    public var optional: Bool

    public var maxCount: Int

    public var minCount: Int

    public var deleteRule: NSDeleteRule

    public var inverse: String?
}
