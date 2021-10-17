//
//  CoreDataModelDescription.swift
//  CoreDataModelDescription
//
//  Created by Dmytro Anokhin on 12/08/2019.
//  Copyright © 2019 Dmytro Anokhin. All rights reserved.
//

import CoreData


/// Used to create `NSManagedObjectModel`
@available(iOS 11.0, tvOS 11.0, macOS 10.13, *)
public struct CoreDataModelDescription {

    public var entities: [CoreDataEntityDescription]

    public init(entities: [CoreDataEntityDescription]) {
        self.entities = entities
    }

    public func makeModel(byMerging model: NSManagedObjectModel = NSManagedObjectModel()) -> NSManagedObjectModel {

        // For convenience: the package objects use "Description" suffix, Core Data objects have no suffix.
        let entitiesDescriptions = self.entities
        let entities: [NSEntityDescription]

        // Model creation has next steps:
        // 1. Create entities and their attributes. Entities are mapped to their names for faster lookup. This step also creates configuration name to entities map.
        // 2. Second step creates relationships and establishes parent-child (sub-super entity) connections. This step produces a list of relationships with inverse (and their descriptions).
        // 3. Third step connects inverse relationships.
        // 4. Last step builds indexes. This must be done in the last step because changing entities hierarchy structurally drops indexes.

        // First step
        var entityNameToEntity: [String: NSEntityDescription] = [:]
        var configurationNameToEntities: [String: Array<NSEntityDescription>] = [:]
        var entityNameToPropertyNameToProperty: [String: [String: NSPropertyDescription]] = [:]

        for entityDescription in entitiesDescriptions {
            let entity = NSEntityDescription()
            entity.name = entityDescription.name
            entity.managedObjectClassName = entityDescription.managedObjectClassName
            entity.isAbstract = entityDescription.isAbstract

            var propertyNameToProperty: [String: NSPropertyDescription] = [:]

            for attributeDescription in entityDescription.attributes {
                let attribute = attributeDescription.makeAttribute()
                propertyNameToProperty[attribute.name] = attribute
            }

            for fetchedPropertyDescription in entityDescription.fetchedProperties {
                let fetchedProperty = fetchedPropertyDescription.makeFetchedProperty()
                propertyNameToProperty[fetchedProperty.name] = fetchedProperty
            }

            entity.properties = Array(propertyNameToProperty.values)
            entity.uniquenessConstraints = [entityDescription.constraints]

            // Map the entity to its name
            entityNameToEntity[entityDescription.name] = entity

            // Map the entity to its configuration
            if let configurationName = entityDescription.configuration {
                var configurationEntities = configurationNameToEntities[configurationName] ?? []
                configurationEntities.append(entity)
                configurationNameToEntities[configurationName] = configurationEntities
            }

            // Map properties
            entityNameToPropertyNameToProperty[entityDescription.name] = propertyNameToProperty
        }

        // Second step
        var relationshipsWithInverse: [(CoreDataRelationshipDescription, NSRelationshipDescription)] = []

        for entityDescription in entitiesDescriptions {
            let entity = entityNameToEntity[entityDescription.name]!

            var propertyNameToProperty: [String: NSPropertyDescription] = [:]

            for relationshipDescription in entityDescription.relationships {
                let relationship = NSRelationshipDescription()
                relationship.name = relationshipDescription.name
                relationship.maxCount = relationshipDescription.maxCount
                relationship.minCount = relationshipDescription.minCount
                relationship.isOrdered = relationshipDescription.ordered
                relationship.deleteRule = relationshipDescription.deleteRule
                relationship.isOptional = relationshipDescription.optional

                var destinationEntity = entityNameToEntity[relationshipDescription.destination]
                if destinationEntity == nil {
                    destinationEntity = model.entitiesByName[relationshipDescription.destination]
                }
                assert(destinationEntity != nil, "Can not find destination entity: '\(relationshipDescription.destination)', in relationship '\(relationshipDescription.name)', for entity: '\(entityDescription.name)'")
                relationship.destinationEntity = destinationEntity

                if let _ = relationshipDescription.inverse {
                    relationshipsWithInverse.append((relationshipDescription, relationship))
                }

                propertyNameToProperty[relationshipDescription.name] = relationship
                entityNameToPropertyNameToProperty[entityDescription.name]![relationshipDescription.name] = relationship
            }

            // Relationships
            entity.properties += Array(propertyNameToProperty.values)

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

        entities = Array(entityNameToEntity.values)

        // Last step, build indexes
        for entityDescription in entitiesDescriptions {
            let entity = entityNameToEntity[entityDescription.name]!
            let propertyNameToProperty = entityNameToPropertyNameToProperty[entityDescription.name] ?? [:]

            entity.indexes = entityDescription.indexes.map { indexDescription in
                let elements: [NSFetchIndexElementDescription] = indexDescription.elements.compactMap { elementDescription in
                    switch elementDescription.property {
                        case .property(let name):
                            guard let property = propertyNameToProperty[name] else {
                                assertionFailure("Can not find attribute, fetched property, or relationship with name: \(name).")
                                return nil
                            }

                            return NSFetchIndexElementDescription(property: property, collationType: elementDescription.type)

                        case .expression:
                            assertionFailure("Expression indexes are not supported yet")
                            return nil
                        }
                    }

                return NSFetchIndexDescription(name: indexDescription.name, elements: elements)
            }
        }

        // Append new entities and set their configurations

        model.entities.append(contentsOf: entities)

        for (configurationName, entities) in configurationNameToEntities {
            model.setEntities(entities, forConfigurationName: configurationName)
        }
        
        return model
    }
}
