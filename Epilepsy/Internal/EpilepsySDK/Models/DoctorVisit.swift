//
//  DoctorVisit.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 17/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftDate

class DoctorVisit: Object {
    @objc dynamic var id: String = String.random(with: 16)
    @objc dynamic var alertDate: Date?
    @objc dynamic var alertEnabled: Bool = true
    @objc dynamic var doctor: String?
    @objc dynamic var name: String?
    @objc dynamic var visitDate: Date = Date()
    @objc dynamic var isDone: Bool = false
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    convenience init(byDefault: Bool) {
        self.init()
        
        let lastVisit = try? Realm().objects(DoctorVisit.self).last
        if let lastVisitDate = lastVisit??.visitDate, lastVisitDate + 1.month > Date() {
            self.visitDate = lastVisitDate + 1.month
        } else {
            self.visitDate = abs(date: Date()) + 1.month
        }
        self.name = lastVisit??.name
        self.doctor = lastVisit??.doctor
    }
    
    private func abs(date: Date) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy dd MMMM HH"
        let formattedDate = dateFormatter.string(from: date + 1.hour)
        return dateFormatter.date(from: formattedDate)!
    }
}

extension DoctorVisit: Notificationable {

    var notifications: [UILocalNotification]? {
        guard alertEnabled, let alertDate = alertDate else { return nil }
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let notification = UILocalNotification()
        notification.alertBody = String(format: NSLocalizedString("Напоминаем о визите к врачу в %@.", comment: ""), timeFormatter.string(from: visitDate))
        notification.fireDate = alertDate
        notification.userInfo = [kNotificationObjectId : id]
        return [notification]
    }

}
