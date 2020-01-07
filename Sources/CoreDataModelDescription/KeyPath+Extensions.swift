//
//  KeyPath+Extensions.swift
//  CoreDataModelDescription
//  
//
//  Created by Nate Rivard on 03/01/2020.
//  Copyright © 2019 Dmytro Anokhin. All rights reserved.
//

import Foundation

extension KeyPath {

    /// returns the Root object type
    var rootType: Any.Type {
        return Root.self
    }

    /// returns the unwrapped `Value.Type` (if optional), or `Value.self` otherwise.
    /// For example, if self == KeyPath<NSManagedObject, String>, then `valueType` is `String.Type`
    /// if self == KeyPath<NSManagedObject, String?>, then `valueType` is `String.Type`, not `Optional<String>.Type`
    var unwrappedType: Any.Type {
        guard let optionalType = Value.self as? OptionalProtocol.Type else {
            return Value.self
        }

        return optionalType.wrappedType
    }

    /// returns the end destination (as defined by Core Data) type, ignoring optionality and ignoring any kind of collection wrapper.
    /// For example, if self == KeyPath<NSManagedObject, String?>, then `destinationType` is `String.Type`
    /// if self == KeyPath<NSManagedObject, Set<String>>, then `destinationType` is also `String.Type`
    var destinationType: Any.Type {
        let unwrapped = unwrappedType

        guard let toManyType = unwrapped.self as? ToManyProtocol.Type else {
            return unwrapped
        }

        return toManyType.elementType
    }

    /// returns this keypath as a `String` value. This will crash if `Value` is not `@objc`. Luckily, `@NSManaged` properties satisfy this requirement.
    var stringValue: String {
        return NSExpression(forKeyPath: self).keyPath
    }

    /// returns whether the underlying `Value` type (as defined by `valueType`), is considered a `toMany` relationship
    var isToMany: Bool {
        return unwrappedType is ToManyProtocol.Type
    }

    /// returns whether `Value.self` is wrapped as an optional type. This does _not_ use `destinationType`.
    var isOptional: Bool {
        return Value.self is OptionalProtocol.Type
    }
}

/// Type-erasure protocol to determine a) if `Value` is `Optional`, and b) the underlying `Wrapped` type
protocol OptionalProtocol {
    static var wrappedType: Any.Type { get }
}

extension Optional: OptionalProtocol {
    static var wrappedType: Any.Type {
        return Wrapped.self
    }
}

/// Type-erasure protocol to determine a) if `Value` is a `Set`, and b) the underlying `Element` type
/// NOTE: `NSSet` and `NSOrderedSet` are not supported as there is no way to determine what it's underlying `Element` type is.
///  They are type erased as `Any`.
protocol ToManyProtocol {
    static var elementType: Any.Type { get }
}

extension Set: ToManyProtocol {
    static var elementType: Any.Type {
        return Element.self
    }
}
