//
//  Array+Extension.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 23/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation

extension Array {

    func grouped<T>(by criteria: (Element) -> T) -> [T: [Element]] {
        var groups = [T: [Element]]()
        for element in self {
            let key = criteria(element)
            if groups.keys.contains(key) == false {
                groups[key] = [Element]()
            }
            groups[key]?.append(element)
        }
        return groups
    }
    
}
