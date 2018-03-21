//
//  Settings.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 20/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftDate

class Settings: Object {
    @objc dynamic var id: String = "DefaultSettings"
    
    let medicationDefaultTimes = List<String>()
    @objc dynamic var isAllNotificationsEnabled: Bool = true
    @objc dynamic var isEndOfDayNotificationsEnabled: Bool = true
    @objc dynamic var endOfDayNotificationTime: String = "20:00"
    
    @objc dynamic var lastICloudBackupDate: Date?
    @objc dynamic var backupICloudTimeInterval: Int = BackgroundFetchMinimumInterval.week.rawValue
    @objc dynamic var isBackupICloudEnabled: Bool = true
    
    @objc dynamic var lastEmailBackupDate: Date?
    @objc dynamic var isBackupEmailSendEnabled: Bool = false
    @objc dynamic var backupEmailTimeInterval: Int = BackgroundFetchMinimumInterval.week.rawValue
    @objc dynamic var userEmail: String?
    @objc dynamic var userBirthDate: Date?
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    convenience init(byDefault: Bool) {
        self.init()
        
        self.medicationDefaultTimes.append(objectsIn: ["09:00", "13:00", "19:00"])
    }
    
}

enum BackgroundFetchMinimumInterval: Int, EnumCollection {
    case week = 604800
    case month = 18144000
    
    var localizedDescription: String {
        switch self {
        case .week:
            return NSLocalizedString("Раз в неделю", comment: "")
        case .month:
            return NSLocalizedString("Раз в месяц", comment: "")
        }
    }
}

extension Settings {
    
    var minimumFetchInterval: TimeInterval {
        return Double(min(backupICloudTimeInterval, backupEmailTimeInterval))
    }
    
    var isICloudAvailable: Bool {
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent(kBackupFileName) != nil
    }
    
}

extension Settings: Notificationable {

    var defaultNotificationsCount: Int {
        return 5
    }

    var notifications: [UILocalNotification]? {
        var notifications: [UILocalNotification] = []
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let time = timeFormatter.date(from: endOfDayNotificationTime)!
        
        let c: [Calendar.Component : Int] = [.year: Date().year, .month: Date().month, .hour: time.hour, .day: Date().day, .minute: time.minute]
        var notifCursorDate = try! DateInRegion(components: c)!.absoluteDate
        
        for _ in 0..<defaultNotificationsCount {
            let notific = UILocalNotification()
            notific.fireDate = notifCursorDate
            notific.userInfo = [kNotificationObjectId : id]
            
            var notifBody = ""
            
            if let isHealthNoted = try? Realm().objects(Health.self).contains(where: { $0.date.isInSameDayOf(date: notifCursorDate) }), isHealthNoted == false {
                notifBody = NSLocalizedString("Вы не отметили свое самочувствие", comment: "")
            }
            
            if Drug.isAllDrugsUsed(in: notifCursorDate) == false {
                if notifBody.count > 0 { notifBody += "\n" }
                notifBody += NSLocalizedString("Вы не приняли все препараты", comment: "")
            }
            
            if notifBody.count > 0 {
                notific.alertBody = notifBody
                notifications.append(notific)
            }
            
            notifCursorDate = notifCursorDate + 1.day
        }
        
        return notifications
    }

}
