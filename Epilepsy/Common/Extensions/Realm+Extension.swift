//
//  Realm+Extension.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 03/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RealmSwift

protocol Detachable: Any {
    func detached() -> Self
}

extension Object: Detachable {
    
    func detached() -> Self {
        let detached = type(of: self).init()
        for property in objectSchema.properties {
            guard let value = value(forKey: property.name) else { continue }
            if let detachable = value as? Detachable {
                detached.setValue(detachable.detached(), forKey: property.name)
            } else {
                detached.setValue(value, forKey: property.name)
            }
        }
        return detached
    }
    
}

extension List: Detachable {
    
    func detached() -> List<Element> {
        let result = List<Element>()
        for element in self {
            if element is Detachable {
                result.append((element as! Detachable).detached() as! Element)
            }
        }
        return result
    }
    
}

extension String: Detachable {
    
    func detached() -> String {
        return self
    }
    
}
