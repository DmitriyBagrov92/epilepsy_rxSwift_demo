//
//  SwiftFuncExtensions.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 19/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation

extension Collection {
    
    subscript (safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
    
}
