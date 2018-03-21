//
//  String+Extension.swift
//  rxDemo
//
//  Created by DmitriyBagrov on 11/09/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation

extension String {
    
    static func random(with length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    var isEmail: Bool {
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        return predicate.evaluate(with: self)
    }
    
}
