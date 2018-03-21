//
//  DiaryViewModel.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 16/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxDataSources
import RxCocoa
import RealmSwift
import RxRealm
import SwiftDate

class DiaryViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Input
    
    let selectDate: AnyObserver<Date>
    
    let nextDayAction: AnyObserver<Void>
    
    let previousDayAction: AnyObserver<Void>
    
    let calendarButtonTap: AnyObserver<Void>
    
    let healthSliderValue: AnyObserver<Float>
    
    let healthSliderInputEnd: AnyObserver<Void>
    
    let settingsButtonTap: AnyObserver<Void>
    
    let drugSelected: AnyObserver<Drug>
    
    let fitSelected: AnyObserver<Fit>

    let visitSelected: AnyObserver<DoctorVisit>
    
    // MARK - Public Properties: Output
    
    let selectedDateText: Driver<String>
    
    let selectedDate: Driver<Date>
    
    let tableSections: Driver<[DiaryTableSection]>
    
    let savedHealthValue: Driver<Float>
    
    let healthValueText: Driver<String?>
    
    let healthDescriptionText: Driver<String>
    
    let presentCalendar: Driver<Date>
    
    let presentFit: Driver<Fit>
    
    let presentVisit: Driver<DoctorVisit>
    
    let presentSettings: Driver<Void>
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK - Lifecycle
    
    init() {
        let _refreshTimer = Observable<Int>.interval(60, scheduler: MainScheduler.instance)
        
        let _date = BehaviorSubject<Date>(value: Date())
        self.selectDate = _date.asObserver()
        self.selectedDate = _date.asDriver(onErrorJustReturn: Date())
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        self.selectedDateText = _date.map({ $0.isToday ? NSLocalizedString("Сегодня", comment: "") : dateFormatter.string(from: $0) }).asDriver(onErrorJustReturn: "Error")
        
        let _nextDay = PublishSubject<Void>()
        self.nextDayAction = _nextDay.asObserver()
        _nextDay.withLatestFrom(_date).map({ $0 + 1.day }).bind(to: _date).disposed(by: disposeBag)
        
        let _previousDay = PublishSubject<Void>()
        self.previousDayAction = _previousDay.asObserver()
        _previousDay.withLatestFrom(_date).map({ $0 - 1.day }).bind(to: _date).disposed(by: disposeBag)
        
        let defaultHealthValue = Float(5.0)
        
        let _healthValue = BehaviorSubject<Int?>(value: nil)
        
        let _healthSliderInput = PublishSubject<Float>()
        self.healthSliderValue = _healthSliderInput.asObserver()
        
        let _healthSliderInputEnd = PublishSubject<Void>()
        self.healthSliderInputEnd = _healthSliderInputEnd.asObserver()
        
        self.healthValueText = _healthValue.map({ $0 == nil ? nil : String($0!) }).asDriver(onErrorJustReturn: nil)
        self.healthDescriptionText = _healthValue.map({ $0 == nil ? NSLocalizedString("Не отмечено", comment: "") : NSLocalizedString("/10", comment: "") }).asDriver(onErrorJustReturn: "Error")
        self.savedHealthValue = _healthValue.map({ $0 == nil ? defaultHealthValue : Float($0!) }).asDriver(onErrorJustReturn: defaultHealthValue)
        
        let _drugSelected = PublishSubject<Drug>()
        self.drugSelected  = _drugSelected.asObserver()
        
        let _fitAction = PublishSubject<Fit>()
        self.fitSelected = _fitAction.asObserver()
        self.presentFit = _fitAction.asDriver(onErrorJustReturn: Fit())
        
        let _visitAction = PublishSubject<DoctorVisit>()
        self.visitSelected = _visitAction.asObserver()
        self.presentVisit = _visitAction.asDriver(onErrorJustReturn: DoctorVisit())
        
        _date.map({ try! Realm().objects(Health.self).filter(NSPredicate(format: "date >= %@ AND date <= %@", NSDate(timeIntervalSince1970: $0.startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: $0.endOfDay.timeIntervalSince1970))) })
            .map({ $0.count == 0 ? nil : $0.first!.value  }).bind(to: _healthValue).disposed(by: disposeBag)
        
        _healthSliderInputEnd.withLatestFrom(Observable.combineLatest(_date, _healthSliderInput)).bind(onNext: { (date, sliderValue) in
            let savedHealthResult = try! Realm().objects(Health.self).filter(NSPredicate(format: "date >= %@ AND date <= %@", NSDate(timeIntervalSince1970: date.startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: date.endOfDay.timeIntervalSince1970)))
            if savedHealthResult.count != 0, let savedHealth = savedHealthResult.first {
                try! Realm().write {
                    savedHealth.value = Int(sliderValue)
                }
            } else {
                let newHealth = Health(date: date, value: Int(sliderValue))
                try! Realm().write {
                    try! Realm().add(newHealth)
                }
            }
        }).disposed(by: disposeBag)
        
        _healthSliderInput.map({ Int($0) }).bind(to: _healthValue).disposed(by: disposeBag)
        
        //Auto update by timer

        _refreshTimer.withLatestFrom(_date).map({ $0.isToday ? Date() : $0 }).bind(to: _date).disposed(by: disposeBag)
        
        //Data for Table
        
        let _drugsObservable = _date.map({ NSPredicate(format: "(startData <= %@ AND isDaily = true ) OR (isDaily = false AND endData >= %@ AND startData <= %@)", NSDate(timeIntervalSince1970: $0.endOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: $0.startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: $0.endOfDay.timeIntervalSince1970)) })
            .map({ try! Realm().objects(Drug.self).filter($0) }).flatMapLatest({ Observable.collection(from: $0) })
        
        let _fitsObservable = _date.map({ NSPredicate(format: "fitDate >= %@ AND fitDate <= %@", NSDate(timeIntervalSince1970: $0.startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: $0.endOfDay.timeIntervalSince1970)) })
            .map({ try! Realm().objects(Fit.self).filter($0).sorted(byKeyPath: "fitDate", ascending: true) }).flatMapLatest({ Observable.collection(from: $0) })
        
        let _visitsObservable = _date.map({ NSPredicate(format: "visitDate >= %@ AND visitDate <= %@", NSDate(timeIntervalSince1970: $0.startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: $0.endOfDay.timeIntervalSince1970)) })
            .map({ try! Realm().objects(DoctorVisit.self).filter($0).sorted(byKeyPath: "visitDate", ascending: false) }).flatMapLatest({ Observable.collection(from: $0) })
                
        self.tableSections = Observable.combineLatest(_date, _drugsObservable, _fitsObservable, _visitsObservable).map( { date, drugs, fits, visits in
            return DiaryTableSectionType.cases().map({ type -> DiaryTableSection in
                switch type {
                case .chart:
                    var _chartDate = Date()
                    if date > Date().endOfDay {
                        _chartDate = date.startOfDay
                    } else if date < Date().startOfDay {
                        _chartDate = date.endOfDay
                    }
                    return DiaryTableSection(type: .chart, date: _chartDate, items: [(drugs, fits, visits)])
                case .drugs:
                    return DiaryTableSection(type: .drugs, date: date, items: drugs.count == 0 ? [nil] : Array(drugs))
                case .fits:
                    return DiaryTableSection(type: .fits, date: date, items: fits.count == 0 ? [nil] : Array(fits))
                case .doctorVisits:
                    return DiaryTableSection(type: .doctorVisits, date: date, items: visits.count == 0 ? [nil] : Array(visits))
                }
            })
        }).asDriver(onErrorJustReturn: [])
        
        let _calendarAction = PublishSubject<Void>()
        self.calendarButtonTap = _calendarAction.asObserver()
        self.presentCalendar = _calendarAction.withLatestFrom(_date).asDriver(onErrorJustReturn: Date())
        
        let _settingsAction = PublishSubject<Void>()
        self.settingsButtonTap = _settingsAction.asObserver()
        self.presentSettings = _settingsAction.asDriver(onErrorJustReturn: ())
        
        //User Actions
        //TODO: Implement _drugSelected.
    }
    
}

enum DiaryTableSectionType: String, EnumCollection {
    case chart
    case drugs
    case fits
    case doctorVisits
}

extension DiaryTableSectionType {
    
    var title: String? {
        switch self {
        case .chart:
            return nil
        case .drugs:
            return NSLocalizedString("Прием препаратов", comment: "")
        case .fits:
            return NSLocalizedString("Приступы", comment: "")
        case .doctorVisits:
            return NSLocalizedString("Запись к врачу", comment: "")
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .chart:
            return nil
        case .drugs:
            return #imageLiteral(resourceName: "drugs-active")
        case .fits:
            return #imageLiteral(resourceName: "attack")
        case .doctorVisits:
            return #imageLiteral(resourceName: "doctor")
        }
    }
    
    var emptyDescription: String? {
        switch self {
        case .chart:
            return nil
        case .drugs:
            return NSLocalizedString("Принимать лекарства не нужно", comment: "")
        case .fits:
            return NSLocalizedString("Приступов не зафиксированно", comment: "")
        case .doctorVisits:
            return NSLocalizedString("Посещение врача не запланировано", comment: "")
        }
    }
    
}

struct DiaryTableSection: SectionModelType {
    
    let type: DiaryTableSectionType
    
    let date: Date
    
    // MARK - SectionModelType Properties
    
    var items: [Any?]
    
    typealias Item = Any?
    
    // MARK - Lifecycle
    
    init(original: DiaryTableSection, items: [Any?]) {
        self = original
        self.items = items
    }
    
    init(type: DiaryTableSectionType, date: Date, items: [Any?]) {
        self.type = type
        self.date = date
        self.items = items
    }
    
}
