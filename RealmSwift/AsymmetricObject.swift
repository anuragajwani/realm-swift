////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import Foundation
import Realm
import Realm.Private

/**
 `EmbeddedObject` is a base class used to define embedded Realm model objects.

 Embedded objects work similarly to normal objects, but are owned by a single
 parent Object (which itself may be embedded). Unlike normal top-level objects,
 embedded objects cannot be directly created in or added to a Realm. Instead,
 they can only be created as part of a parent object, or by assigning an
 unmanaged object to a parent object's property. Embedded objects are
 automatically deleted when the parent object is deleted or when the parent is
 modified to no longer point at the embedded object, either by reassigning an
 Object property or by removing the embedded object from the List containing it.

 Embedded objects can only ever have a single parent object which links to
 them, and attempting to link to an existing managed embedded object will throw
 an exception.

 The property types supported on `EmbeddedObject` are the same as for `Object`,
 except for that embedded objects cannot link to top-level objects, so `Object`
 and `List<Object>` properties are not supported (`EmbeddedObject` and
 `List<EmbeddedObject>` *are*).

 Embedded objects cannot have primary keys or indexed properties.

 ```swift
 class Owner: Object {
     @Persisted var name: String
     @Persisted var dogs: List<Dog>
 }
 class Dog: EmbeddedObject {
     @Persisted var name: String
     @Persisted var adopted: Bool
     @Persisted(originProperty: "dogs") var owner: LinkingObjects<Owner>
 }
 ```
 */
public typealias AsymmetricObject = RealmSwiftAsymmetricObject
extension AsymmetricObject: _RealmCollectionValueInsideOptional {
    /// :nodoc:
    public class override final func isAsymmetric() -> Bool {
        return true
    }

    // MARK: Initializers

    /**
     Creates an unmanaged instance of a Realm object.

     The `value` argument is used to populate the object. It can be a key-value coding compliant object, an array or
     dictionary returned from the methods in `NSJSONSerialization`, or an `Array` containing one element for each
     managed property. An exception will be thrown if any required properties are not present and those properties were
     not defined with default values.

     When passing in an `Array` as the `value` argument, all properties must be present, valid and in the same order as
     the properties defined in the model.

     An unmanaged embedded object can be added to a Realm by assigning it to a property of a managed object or by adding it to a managed List.

     - parameter value:  The value used to populate the object.
     */
    public convenience init(value: Any) {
        self.init()
        RLMInitializeWithValue(self, value, .partialPrivateShared())
    }


    // MARK: Properties

    /// The Realm which manages the object, or `nil` if the object is unmanaged.
    public var realm: Realm? {
        if let rlmReam = RLMObjectBaseRealm(self) {
            return Realm(rlmReam)
        }
        return nil
    }

    /// The object schema which lists the managed properties for the object.
    public var objectSchema: ObjectSchema {
        return ObjectSchema(RLMObjectBaseObjectSchema(self)!)
    }

    /// Indicates if the object can no longer be accessed because it is now invalid.
    ///
    /// An object can no longer be accessed if the object has been deleted from the Realm that manages it, or if
    /// `invalidate()` is called on that Realm.
    public override final var isInvalidated: Bool { return super.isInvalidated }

    /// A human-readable description of the object.
    open override var description: String { return super.description }

    /**
     WARNING: This is an internal helper method not intended for public use.
     It is not considered part of the public API.
     :nodoc:
     */
    public override final class func _getProperties() -> [RLMProperty] {
        return ObjectUtil.getSwiftProperties(self)
    }

    // MARK: Object Customization

    /**
     Override this method to specify the names of properties to ignore. These properties will not be managed by
     the Realm that manages the object.

     - warning: This function is only applicable to legacy property declarations
                using `@objc`. When using `@Persisted`, any properties not
                marked with `@Persisted` are automatically ignored.
     - returns: An array of property names to ignore.
     */
    @objc open class func ignoredProperties() -> [String] { return [] }

    // MARK: Key-Value Coding & Subscripting

    /// Returns or sets the value of the property with the given name.
    @objc open subscript(key: String) -> Any? {
        get {
            return RLMDynamicGetByName(self, key)
        }
        set {
            dynamicSet(object: self, key: key, value: newValue)
        }
    }

    // MARK: Comparison
    /**
     Returns whether two Realm objects are the same.

     Objects are considered the same if and only if they are both managed by the same
     Realm and point to the same underlying object in the database.

     - note: Equality comparison is implemented by `isEqual(_:)`. If the object type
             is defined with a primary key, `isEqual(_:)` behaves identically to this
             method. If the object type is not defined with a primary key,
             `isEqual(_:)` uses the `NSObject` behavior of comparing object identity.
             This method can be used to compare two objects for database equality
             whether or not their object type defines a primary key.

     - parameter object: The object to compare the receiver to.
     */
    public func isSameObject(as object: AsymmetricObject?) -> Bool {
        return RLMObjectBaseAreEqual(self, object)
    }
}
