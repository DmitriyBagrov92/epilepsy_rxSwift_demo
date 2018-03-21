//
//  SwiftFuncExtension.swift
//  rxDemo
//
//  Created by DmitriyBagrov on 04/09/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import CoreGraphics

enum PluralType: String {
    case year
    case hour
    case minute
    
    var forms: [String] {
        switch self {
        case .year:
            return [NSLocalizedString("год", comment: ""), NSLocalizedString("года", comment: ""), NSLocalizedString("лет", comment: "")]
        case .hour:
            return [NSLocalizedString("час", comment: ""), NSLocalizedString("часа", comment: ""), NSLocalizedString("часов", comment: "")]
        case .minute:
            return [NSLocalizedString("минута", comment: ""), NSLocalizedString("минуты", comment: ""), NSLocalizedString("минут", comment: "")]
        }
    }
    
}

func + <K,V>(left: [K : V], right: [K : V]) -> [K : V] {
    var result = [K:V]()
    
    for (key,value) in left {
        result[key] = value
    }
    
    for (key,value) in right {
        result[key] = value
    }
    return result
}

extension Int {
    
    var f: CGFloat {
        return CGFloat(self)
    }
    
    var toString: String {
        return NSNumber(value: self as Int).stringValue
    }
    
    func plural(with type: PluralType) -> String {
        let forms = type.forms
        return self % 10 == 1 && self % 100 != 11 ? forms[0] :
            (self % 10 >= 2 && self % 10 <= 4 && (self % 100 < 10 || self % 100 >= 20) ? forms[1] : forms[2])
    }
}

extension Double {
    
    var f: CGFloat {
        return CGFloat(self)
    }
    
}

extension Float {
    
    var f: CGFloat {
        return CGFloat(self)
    }
    
}
