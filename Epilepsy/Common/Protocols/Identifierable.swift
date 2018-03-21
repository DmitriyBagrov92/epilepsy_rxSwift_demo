//
//  Identifierable.swift
//  rxDemo
//
//  Created by DmitriyBagrov on 04/09/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import UIKit

protocol Identifierable {
    static var identifier: String { get }
}

extension Identifierable where Self: UIViewController {
    
    static var identifier: String {
        return String(describing: self)
    }
    
}

extension Identifierable where Self: UITableViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
}
