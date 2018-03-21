//
//  Doze.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 17/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftDate

class Drug: Object {
    @objc dynamic var id: String = String.random(with: 16)
    @objc dynamic var name: String?
    @objc dynamic var mnn: String = DrugMNN(rawValue: "Вальпроевая кислота")!.rawValue
    @objc dynamic var startData: Date = Date()
    @objc dynamic var nextDozeStartDate: Date = Date()
    @objc dynamic var endData: Date = Date() + 1.month
    @objc dynamic var isDaily: Bool = true
    @objc dynamic var dozeType: String? //TODO: Rework to Enum
    @objc dynamic var drugID: String?
    @objc dynamic var rID: String?
    @objc dynamic var form: String = DrugForm(rawValue: "Гранулы")!.rawValue
    let medications = List<DrugMedication>()
    let dozeHistory = List<DrugDozeHistory>()
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    convenience init(date: Date = Date()) {
        self.init()
        self.startData = date
        medications.append(DrugMedication(dateTime: date))
    }
}

extension Drug {

    var isValid: EPError? {
        guard name?.count ?? 0 > 0 else { return EPError.DrugNameEmpty }
        guard dozeType?.count ?? 0 > 0 else { return EPError.DrugDozeEmpty }
        guard let doze = dozeType, Int(doze)! >= 0 && Int(doze)! <= 2000 else { return EPError.DrugDozeIncorectValue }
        return nil
    }
    
    static func isAllDrugsUsed(in date: Date) -> Bool {
        let predicate = NSPredicate(format: "(startData <= %@ AND isDaily = true) OR (isDaily = false AND endData >= %@ AND startData <= %@)", NSDate(timeIntervalSince1970: date.endOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: date.startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: date.endOfDay.timeIntervalSince1970))
        let dayDrugs = try! Realm().objects(Drug.self).filter(predicate)
        for drug in dayDrugs {
            for medication in drug.medications {
                if medication.usings.contains(where: { $0.date.isInSameDayOf(date: date) }) {
                    //medication was used in this day
                } else {
                    return false
                }
            }
        }
        return true
    }
    
    func insertNewDozeHistoryIfNeed(_ previousDoze: String?) {
        if (Date() > nextDozeStartDate && isDaily && previousDoze != dozeType)
        || (Date() > nextDozeStartDate && isDaily == false && Date() < endData && previousDoze != dozeType) {
            let dozeHistoryStartDate = dozeHistory.last?.endDate ?? startData
            let history = DrugDozeHistory()
            history.startDate = dozeHistoryStartDate
            history.endDate = Date() + 1.day
            history.doze = previousDoze
            dozeHistory.append(history)
            
            nextDozeStartDate = nextDozeStartDate + 1.day
        }
    }
    
}

extension Drug: Notificationable {
    
    var notifications: [UILocalNotification]? {
        var _notifications: [UILocalNotification] = []
        for medication in self.medications {
            let notification = UILocalNotification()
            notification.alertBody = String(format: NSLocalizedString("Пришло время принять препарат %@", comment: ""), self.name ?? "")
            notification.userInfo = [kNotificationObjectId : self.id]
            if self.isDaily {
                notification.fireDate = medication.useDate(with: self.startData)
                notification.repeatInterval = .day
                _notifications.append(notification)
            } else {
                var cursorDate = self.startData
                while cursorDate <= self.endData {
                    let dayNotification = UILocalNotification()
                    dayNotification.alertBody = String(format: NSLocalizedString("Пришло время принять препарат %@", comment: ""), name ?? "")
                    notification.userInfo = [kNotificationObjectId : self.id]
                    dayNotification.fireDate = medication.useDate(with: cursorDate)
                    _notifications.append(dayNotification)
                    cursorDate = cursorDate + 1.day
                }
            }
        }
        return _notifications.count > 0 ? _notifications : nil
    }
    
}

class DrugMedication: Object {
    @objc dynamic var time: String = ""
    @objc dynamic var notificationEnabled: Bool = true
    @objc dynamic var comment: String?
    let usings = List<DrugMedicationUsing>()
    
    convenience init(dateTime: Date, index: Int = 0) {
        self.init()
        let realm = try! Realm()
        let settings = realm.objects(Settings.self).first ?? Settings(byDefault: true)
        
        self.time = settings.medicationDefaultTimes[index]
    }
    
    subscript(date: Date) -> DrugMedicationUsing {
        return usings.filter({ $0.date == date }).first ?? DrugMedicationUsing(type: .pending, date: date)
    }
}

enum MedicationState: String {
    case successed
    case failed
    case pending
    case inWrongTime
    case unknow
}

class DrugMedicationUsing: Object {
    @objc dynamic var type: String = MedicationState.unknow.rawValue
    @objc dynamic var date: Date = Date()
    
    convenience init(type: MedicationState, date: Date) {
        self.init()
        self.type = type.rawValue
        self.date = date
    }
    
    var state: MedicationState {
        return MedicationState(rawValue: type)!
    }
    
    func description() -> String {
        switch MedicationState(rawValue: type)! {
        case .successed:
            return NSLocalizedString("Вовремя", comment: "")
        case .failed:
            return NSLocalizedString("Не вовремя", comment: "")
        case .pending:
            let intervaFormatter = DateComponentsFormatter()
            intervaFormatter.calendar?.locale = Locale(identifier: "ru")
            intervaFormatter.allowedUnits = [.day, .hour, .minute]
            intervaFormatter.unitsStyle = .abbreviated
            intervaFormatter.maximumUnitCount = 2
            
            let isCurrentLater = Date() - date > 0
            let intervalPhrase = isCurrentLater ? NSLocalizedString("%@ назад", comment: "") : NSLocalizedString("Через %@", comment: "")
            
            return String(format: intervalPhrase, isCurrentLater ? intervaFormatter.string(from: date, to: Date())! : intervaFormatter.string(from: Date(), to: date)!)
        case .inWrongTime:
            return NSLocalizedString("С опозданием", comment: "")
        case .unknow:
            return "Error"
        }
    }
    
    var icon: UIImage {
        switch MedicationState(rawValue: type)! {
        case .successed:
            return #imageLiteral(resourceName: "pills-journal-intime")
        case .failed:
            return #imageLiteral(resourceName: "pills-journal-failed")
        case .pending:
            return #imageLiteral(resourceName: "pills-journal-future")
        case .inWrongTime:
            return #imageLiteral(resourceName: "pills-journal-notintime")
        case .unknow:
            return UIImage()
        }
    }
    
    var isUsed: Bool {
        switch MedicationState(rawValue: type)! {
        case .successed, .failed, .inWrongTime  :
            return true
        default:
            return false
        }
    }
    
    // MARK - Public Methods
    
    var color: UIColor {
        switch MedicationState(rawValue: type)! {
        case .successed:
            return UIColor.EPDiaryMedicationState.green
        case .failed:
            return UIColor.EPDiaryMedicationState.red
        case .inWrongTime:
            return UIColor.EPDiaryMedicationState.yellow
        case .pending, .unknow:
            return UIColor.EPDiaryMedicationState.gray
        }
    }
    
    var isCrossedOut: Bool {
        switch MedicationState(rawValue: type)! {
        case .successed, .failed, .inWrongTime:
            return true
        default:
            return false
        }
    }
    
}

extension DrugMedication {
    
    func useDate(with source: Date) -> Date? {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let medicationDate = timeFormatter.date(from: time)
        let c: [Calendar.Component : Int] = [.year: source.year, .month: source.month, .hour: medicationDate!.hour, .day: source.day, .minute: medicationDate!.minute]
        return try! DateInRegion(components: c)?.absoluteDate
    }
    
}

enum DrugMNN: String, EnumCollection {
    case valpAcid = "Вальпроевая кислота"
    case carbamazepin = "Карбамазепин"
    case ocscarbasepin = "Окскарбазепин"
    case lamotrijin = "Ламотриджин"
    case laveturacetan = "Леветирацетам"
    case topiramat = "Топирамат"
    case etosycsimid = "Этосуксимид"
    case gabapentin = "Габапентин"
    case pregabalin = "Прегабалин"
    case lacosamid = "Лакосамид"
    case zonizamid = "Зонизамид"
}

enum DrugForm: String, EnumCollection {
    case gran = "Гранулы"
    case pills = "Таблетки"
    case gumPills = "Таблетки жевательные"
    case intestinalPills = "Таблетки, кишечно-растворимые"
    case longTermPills = "Таблетки пролонгированного действия"
    case capsule = "Капсулы"
    case syrup = "Сироп"
    case drops = "Капли"
}

//Drug History

class DrugDozeHistory: Object {
    @objc dynamic var startDate: Date?
    @objc dynamic var endDate: Date?
    @objc dynamic var doze: String?
}
