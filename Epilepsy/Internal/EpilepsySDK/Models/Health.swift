//
//  Health.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 09/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RealmSwift

class Health: Object {
    @objc dynamic var date: Date = Date()
    @objc dynamic var value: Int = 5
    
    convenience init(date: Date, value: Int) {
        self.init()
        self.date = date
        self.value = value
    }
}

