//
//  Fit.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 17/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RealmSwift

class Fit: Object {
    @objc dynamic var id: String = String.random(with: 16)
    @objc dynamic var fitDate: Date = Date()
    @objc dynamic var duration: Double = 0.0
    @objc dynamic var type: Int = 0
    @objc dynamic var subType: Int = 0
    @objc dynamic var fitDescription: String?
    
    override class func primaryKey() -> String {
        return "id"
    }
}

enum FitType: Int, EnumCollection {
    case unknow
    case generalized
    case focal
    case complicatedParcial
    
    var localizedDescription: String {
        switch self {
        case .unknow:
            return NSLocalizedString("Не знаю", comment: "")
        case .generalized:
            return NSLocalizedString("Генерализированный", comment: "")
        case .focal:
            return NSLocalizedString("Фокальный", comment: "")
        case .complicatedParcial:
            return NSLocalizedString("Сложный парциальный", comment: "")
            
        }
    }
}

enum FitSubType {
    case generalizedSubType(Int)
    case focalSubType(Int)
    
    var cases: [String]? {
        switch self {
        case .generalizedSubType(_):
            return FitGeneralizedSubType.cases().map({ $0.localizedDescription! })
        case .focalSubType(_):
            return FitFocalSubType.cases().map({ $0.localizedDescription! })
        }
    }
    
    var localizedDescription: String? {
        switch self {
        case let .generalizedSubType(subType):
            return FitGeneralizedSubType(rawValue: subType)?.localizedDescription
        case let .focalSubType(subType):
            return FitFocalSubType(rawValue: subType)?.localizedDescription
        }
    }
}

enum FitGeneralizedSubType: Int, EnumCollection, Localizable {
    case tonicClonicConvulsions
    case clonicConvulsions
    case absans
    case tonicConvulsions
    case mioclonic
    case mioclonicEye
    case mioclonicAtonic
    case negativeMioClonus
    case atonic
    case reflect
    
    var localizedDescription: String? {
        switch self {
        case .tonicClonicConvulsions:
            return NSLocalizedString("Тонико-клонические судороги", comment: "")
        case .clonicConvulsions:
            return NSLocalizedString("Клонические судороги", comment: "")
        case .absans:
            return NSLocalizedString("Абсанс", comment: "")
        case .tonicConvulsions:
            return NSLocalizedString("Тонические судороги", comment: "")
        case .mioclonic:
            return NSLocalizedString("Миоклонический", comment: "")
        case .mioclonicEye:
            return NSLocalizedString("Миоклония век", comment: "")
        case .mioclonicAtonic:
            return NSLocalizedString("Миоклонически-атонический", comment: "")
        case .negativeMioClonus:
            return NSLocalizedString("Негативный моиклонус", comment: "")
        case .atonic:
            return NSLocalizedString("Атонический", comment: "")
        case .reflect:
            return NSLocalizedString("Рефлекторный", comment: "")
        }
    }
}

enum FitFocalSubType: Int, EnumCollection, Localizable {
    case focalSensor
    case focalMotor
    case gemiclonic
    case secondarygenegalized
    case reflect
    
    var localizedDescription: String? {
        switch self {
        case .focalSensor:
            return NSLocalizedString("Фокальный сенсорный", comment: "")
        case .focalMotor:
            return NSLocalizedString("Фокальный моторный", comment: "")
        case .gemiclonic:
            return NSLocalizedString("Гемиклонический", comment: "")
        case .secondarygenegalized:
            return NSLocalizedString("Вторично-генерализованный", comment: "")
        case .reflect:
            return NSLocalizedString("Рефлекторный", comment: "")
        }
    }
}

extension Fit {
    
    var fitType: FitType? {
        return FitType(rawValue: type)
    }
    
    var fitSubType: FitSubType? {
        guard let fitType = fitType else { return nil }
        switch fitType {
        case .generalized:
            return FitSubType.generalizedSubType(subType)
        case .focal:
            return FitSubType.focalSubType(subType)
        default:
            return nil
        }
        
    }
    
    var formattedDuration: String {
        if duration == 0 {
            return NSLocalizedString("Несколько секунд", comment: "")
        } else if duration <= 60 {
            return String(format: NSLocalizedString("%0.0f секунд", comment: ""), duration)
        } else {
            let hours = duration / 3600
            let minutes = (duration / 60).truncatingRemainder(dividingBy: 60)
            let hoursString = hours < 1 ? "" : String(format: "%0.0f ", hours) + Int(hours).plural(with: .hour)
            let minutesString = String(format: "%0.0f ", minutes) +  Int(minutes).plural(with: .minute)
            return hoursString + " " + minutesString
        }
    }
    
}
