//
//  Notificationable.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 18/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import UserNotificationsUI

protocol Notificationable {
    var notifications: [UILocalNotification]? { get }
}
