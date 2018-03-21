//
//  DiaryCalendarViewModel.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 07/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import RxDataSources
import SwiftDate

class DiaryCalendarViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Input
    
    let todayButtonTap : AnyObserver<Void>
    
    let changeDate: AnyObserver<Date>
    
    let calendarDateInterval: AnyObserver<(Date, Date)>
    
    // MARK - Public Properties: Output
    
    let selectedDate: Driver<Date>
    
    let calendarHeaderText: Driver<String?>
    
    let calendarDayText: Driver<String?>
    
    let calendarDots: Driver<[Date: [UIColor]]>
    
//    let tableSections: Driver<[DiaryTableSection]>
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
        
    // MARK - Lifecycle
    
    init(selectedDate: Date = Date()) {
        let _todayAction = PublishSubject<Void>()
        self.todayButtonTap = _todayAction.asObserver()
        
        let _date = BehaviorSubject<Date>(value: selectedDate)
        self.changeDate = _date.asObserver()
        self.selectedDate = _date.asDriver(onErrorJustReturn: selectedDate)
        
        let _calendarDateInterval = BehaviorSubject<(Date, Date)>(value: (selectedDate.startOf(component: .month) - 2.month, selectedDate.endOf(component: .month) + 2.month))
        self.calendarDateInterval = _calendarDateInterval.asObserver()
        
        let headerDateFormatter = DateFormatter()
        headerDateFormatter.dateFormat = "MMMM yyyy"
        self.calendarHeaderText = _date.map({ headerDateFormatter.string(from: $0) }).asDriver(onErrorJustReturn: "Error")
        
        let dayDateFormatter = DateFormatter()
        dayDateFormatter.dateFormat = "dd MMMM yyyy года"
        self.calendarDayText = _date.map({ dayDateFormatter.string(from: $0) }).asDriver(onErrorJustReturn: "Error")
        
        //User Actions
        _todayAction.map({ Date() }).bind(to: _date).disposed(by: disposeBag)
        
        //Data Observers
        
//        let _drugsObservable = _date.map({ NSPredicate(format: "(startData <= %@ AND isDaily = true ) OR (isDaily = false AND endData >= %@ AND startData <= %@)", NSDate(timeIntervalSince1970: $0.endOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: $0.startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: $0.endOfDay.timeIntervalSince1970)) })
//            .map({ try! Realm().objects(Drug.self).filter($0) }).flatMapLatest({ Observable.collection(from: $0) })
//
//        let _fitsObservable = _date.map({ NSPredicate(format: "fitDate >= %@ AND fitDate <= %@", NSDate(timeIntervalSince1970: $0.startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: $0.endOfDay.timeIntervalSince1970)) })
//            .map({ try! Realm().objects(Fit.self).filter($0).sorted(byKeyPath: "fitDate", ascending: true) }).flatMapLatest({ Observable.collection(from: $0) })
//
//        let _visitsObservable = _date.map({ NSPredicate(format: "visitDate >= %@ AND visitDate <= %@", NSDate(timeIntervalSince1970: $0.startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: $0.endOfDay.timeIntervalSince1970)) })
//            .map({ try! Realm().objects(DoctorVisit.self).filter($0).sorted(byKeyPath: "visitDate", ascending: false) }).flatMapLatest({ Observable.collection(from: $0) })
//
//        //TODO: Add Doctor Visits Observable
//
//        self.tableSections = Observable.combineLatest(_drugsObservable, _fitsObservable, _visitsObservable, _date).map( { drugs, fits, visits, date in
//            return DiaryTableSectionType.cases().filter({ $0 != .chart }).map({ type -> DiaryTableSection in
//                switch type {
//                case .drugs:
//                    return DiaryTableSection(type: .drugs, date: date, items: drugs.count == 0 ? [nil] : Array(drugs))
//                case .fits:
//                    return DiaryTableSection(type: .fits, date: date, items: fits.count == 0 ? [nil] : Array(fits))
//                case .doctorVisits:
//                    return DiaryTableSection(type: .doctorVisits, date: date, items: visits.count == 0 ? [nil] : Array(visits))
//                default:
//                    return DiaryTableSection(type: .chart, date: date, items: [])
//                }
//            })
//        }).asDriver(onErrorJustReturn: [])
        
        let _calendarDrugs = _calendarDateInterval.map({ NSPredicate(format: "(startData <= %@ AND isDaily = true ) OR (isDaily = false AND endData >= %@ AND startData <= %@)", NSDate(timeIntervalSince1970: $0.1.endOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: $0.0.startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: $0.1.endOfDay.timeIntervalSince1970)) })
            .map({ try! Realm().objects(Drug.self).filter($0) }).flatMapLatest({ Observable.collection(from: $0) })
        
        let _calendarFits = _calendarDateInterval.map({ NSPredicate(format: "fitDate >= %@ AND fitDate <= %@", NSDate(timeIntervalSince1970: $0.0.startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: $0.1.endOfDay.timeIntervalSince1970))  })
            .map({ try! Realm().objects(Fit.self).filter($0) }).flatMapLatest({ Observable.collection(from: $0) })
        
        let _calendarVisits = _calendarDateInterval.map({ NSPredicate(format: "visitDate >= %@ AND visitDate <= %@", NSDate(timeIntervalSince1970: $0.0.startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: $0.1.endOfDay.timeIntervalSince1970))  })
            .map({ try! Realm().objects(DoctorVisit.self).filter($0) }).flatMapLatest({ Observable.collection(from: $0) })
        
        self.calendarDots = _calendarDateInterval.withLatestFrom(Observable.combineLatest(_calendarDrugs, _calendarFits, _calendarVisits, _calendarDateInterval)).map( { (drugs, fits, visits, interval) -> [Date: [UIColor]] in
            var dots: [Date: [UIColor]] = [:]
            
            //Append Fits
            for fit in fits {
                if dots.keys.contains(fit.fitDate.startOfDay) == false {
                    dots[fit.fitDate.startOfDay] = [UIColor.EPColors.red]
                }
            }
            
            //Append Drugs
            for drug in drugs {
                var drugCursorDate = drug.startData > interval.0 ? drug.startData.startOfDay : interval.0.startOfDay
                let drugEndDate = drug.isDaily ? interval.1.startOfDay : drug.endData.startOfDay < interval.1 ? drug.endData.startOfDay : interval.1
                while drugCursorDate <= drugEndDate {
                    let lastMedicationUsing = drug.medications.last![drugCursorDate]
                    
                    if dots.keys.contains(drugCursorDate), dots[drugCursorDate]?.contains(lastMedicationUsing.color) == false {
                        dots[drugCursorDate]?.append(lastMedicationUsing.color)
                    } else if dots.keys.contains(drugCursorDate) == false {
                        dots[drugCursorDate] = [lastMedicationUsing.color]
                    }
                    
                    drugCursorDate = drugCursorDate + 1.day
                }
            }
            
            //Append Doctor Visits
            for visit in visits {
                if dots[visit.visitDate.startOfDay] == nil {
                    dots[visit.visitDate.startOfDay] = [UIColor.EPColors.lightBlue]
                } else if dots[visit.visitDate.startOfDay]?.contains(UIColor.EPColors.lightBlue) == false {
                    dots[visit.visitDate.startOfDay]?.append(UIColor.EPColors.lightBlue)
                }
            }
            
            return dots
        }).asDriver(onErrorJustReturn: [:])
    }
    
}
