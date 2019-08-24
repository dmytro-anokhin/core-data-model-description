//
//  CoreDataModelDescription.swift
//  CoreDataModelDescription
//
//  Created by Dmytro Anokhin on 12/08/2019.
//  Copyright © 2019 Dmytro Anokhin. All rights reserved.
//

import CoreData


/// Used to create `NSManagedObjectModel`
public struct CoreDataModelDescription {

    public var entities: [CoreDataEntityDescription]

    public init(entities: [CoreDataEntityDescription]) {
        self.entities = entities
    }
    
    public func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
                
        // Model creation is split in four steps:
        // 1. First step creates all entities and their attributes. Entities are mapped to their names for faster lookup.
        // 2. Second step creates relationships and establishes parent-child (sub-super entity) connections. This step produces a list of relationships with inverse (and their descriptions).
        // 3. Third step connects inverse relationships.
        // 4. Fourth step divides Entites into Groups based on their configuration Name

        // First step
        let entityNameToEntity: [String: NSEntityDescription] = .init(uniqueKeysWithValues: entities.map { entityDescription in

            let entity = NSEntityDescription()
            entity.name = entityDescription.name
            entity.managedObjectClassName = entityDescription.managedObjectClassName 
            entity.properties = entityDescription.attributes.map { $0.makeAttribute() } + entityDescription.fetchedProperties.map { $0.makeFetchedProperty() }
            
            
            return (entityDescription.name, entity)
        })

        // Second step
        var relationshipsWithInverse: [(CoreDataRelationshipDescription, NSRelationshipDescription)] = []

        for entityDescription in entities {
            let entity = entityNameToEntity[entityDescription.name]!
            
            // Relationships
            entity.properties += entityDescription.relationships.map { relationshipDescription in
                let relationship = NSRelationshipDescription()
                relationship.name = relationshipDescription.name
                relationship.maxCount = relationshipDescription.maxCount
                relationship.minCount = relationshipDescription.minCount
                relationship.deleteRule = relationshipDescription.deleteRule
                relationship.isOptional = relationshipDescription.optional

                let destinationEntity = entityNameToEntity[relationshipDescription.destination]
                assert(destinationEntity != nil, "Can not find destination entity: '\(relationshipDescription.destination)', in relationship '\(relationshipDescription.name)', for entity: '\(entityDescription.name)'")
                relationship.destinationEntity = destinationEntity

                if let _ = relationshipDescription.inverse {
                    relationshipsWithInverse.append((relationshipDescription, relationship))
                }

                return relationship
            }

            // Parent-child entity
            if let parentName = entityDescription.parentEntity {
                let parentEntity = entityNameToEntity[parentName]
                assert(parentEntity != nil, "Can not find parent entity: '\(parentName)', for entity: '\(entityDescription.name)'")
                parentEntity?.subentities += [entity]
            }
        }

        // Third step
        for el in relationshipsWithInverse {
            let relationshipDescription = el.0
            let relationship = el.1

            let inverseRelationshipName = relationshipDescription.inverse!
            let inverseRelationship = relationship.destinationEntity!.propertiesByName[inverseRelationshipName] as? NSRelationshipDescription

            assert(inverseRelationship != nil, "Can not find inverse relationship '\(inverseRelationshipName)', for relationship: '\(relationshipDescription.name)', for entity: '\(relationship.entity.name ?? "nil")', destination entity: '\(relationship.destinationEntity!.name ?? "nil")'")

            relationship.inverseRelationship = inverseRelationship
        }
        
        model.entities = Array(entityNameToEntity.values)
        
        //Fourth step
        entities.map { entity -> (String, String) in
            return (entity.configuration, entity.name)
        }
        .compactMap { (configuration, entityName) -> (String, NSEntityDescription)? in
            guard let entity = entityNameToEntity[entityName] else { return nil }
            return (configuration, entity)
        }
        .associateBy { (configuration, entity) in
            return (configuration, entity)
        }
        .forEach { (configuration, entities) in
            model.setEntities(entities, forConfigurationName: configuration)
        }
        
        return model
    }
}
