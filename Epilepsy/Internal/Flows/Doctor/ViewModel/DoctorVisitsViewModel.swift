//
//  DoctorVisitsViewModel.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 16/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift
import RxDataSources
import SwiftDate

class DoctorVisitsViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Input
    
    let addDoctorVisitTap: AnyObserver<Void>
    
    let editDoctorVisitTap: AnyObserver<DoctorVisit>
    
    let settingsButtonTap: AnyObserver<Void>
    
    // MARK - Public Properties: Output
    
    let backgroundView: Driver<UIView?>
    
    let tableSections: Driver<[VisitsSection]>
    
    let presentDoctorVisitDetails: Driver<DoctorVisit>
    
    let presentSettings: Driver<Void>
    
    // MARK: Private Properties
    
    private let emptyVisitsViewModel: EmptyListViewModel
    
    private let disposeBag = DisposeBag()
    
    // MARK - Lifecycle
    
    init() {
        let _addDoctorVisitAction = PublishSubject<Void>()
        self.addDoctorVisitTap = _addDoctorVisitAction.asObserver()
        
        let _settingsAction = PublishSubject<Void>()
        self.settingsButtonTap = _settingsAction.asObserver()
        self.presentSettings = _settingsAction.asDriver(onErrorJustReturn: ())
        
        let _doctorVisitTranition = PublishSubject<DoctorVisit>()
        self.editDoctorVisitTap = _doctorVisitTranition.asObserver()
        self.presentDoctorVisitDetails = _doctorVisitTranition.asDriver(onErrorJustReturn: DoctorVisit())
        
        self.emptyVisitsViewModel = EmptyListViewModel(description: EmptyListDescription(icon: #imageLiteral(resourceName: "doctor-big"), description: NSLocalizedString("Приемов к врачу не запланировано. Вы можете добавить прием к врачу и получать уведомления, чтобы его не пропустить.", comment: ""), actionButtonText: NSLocalizedString("Добавить прием к врачу", comment: "")))
        let _backgroundViewController = EmptyListViewController.instance(with: self.emptyVisitsViewModel)
        
        let _backgroundView = BehaviorSubject<UIView?>(value: _backgroundViewController.view)
        self.backgroundView = _backgroundView.asDriver(onErrorJustReturn: nil)
        
        //Table Data
        let todayVisitsPredicate = NSPredicate(format: "visitDate >= %@ AND visitDate <= %@", NSDate(timeIntervalSince1970: Date().startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: Date().endOfDay.timeIntervalSince1970))
        let todayVisits = Observable.collection(from: try! Realm().objects(DoctorVisit.self).filter(todayVisitsPredicate).sorted(byKeyPath: "visitDate", ascending: true))
        
        let futureVisitsPredicate = NSPredicate(format: "visitDate >= %@", NSDate(timeIntervalSince1970: (Date() + 1.day).startOfDay.timeIntervalSince1970))
        let futureVisits = Observable.collection(from: try! Realm().objects(DoctorVisit.self).filter(futureVisitsPredicate).sorted(byKeyPath: "visitDate", ascending: true))
        
        let pastVisitsPredicate = NSPredicate(format: "visitDate <= %@", NSDate(timeIntervalSince1970: (Date() - 1.day).endOfDay.timeIntervalSince1970))
        let pastVisits = Observable.collection(from: try! Realm().objects(DoctorVisit.self).filter(pastVisitsPredicate).sorted(byKeyPath: "visitDate", ascending: true))
        
        self.tableSections = Observable.combineLatest(todayVisits, futureVisits, pastVisits).map({ (today, future, past) -> [VisitsSection] in
            var sections: [VisitsSection] = []
        
            let todayItems = Array(today).map({ DoctorVisitFullInfoCellViewModel(visit: $0) })
            let futureItems = Array(future).map({ DoctorVisitFullInfoCellViewModel(visit: $0) })
            let pastItems = Array(past).map({ DoctorVisitsShortInfoCellViewModel(visit: $0) })
            
            if todayItems.count > 0 {
                sections.append(VisitsSection(title: NSLocalizedString("СЕГОДНЯ", comment: ""), items: todayItems))
            }
            
            if futureItems.count > 0 {
                sections.append(VisitsSection(title: NSLocalizedString("БЛИЖАЙШИЕ ВИЗИТЫ К ВРАЧУ", comment: ""), items: futureItems))
            }
            
            if pastItems.count > 0 {
                sections.append(VisitsSection(title: NSLocalizedString("ПРОШЕДШИЕ ВИЗИТЫ", comment: ""), items: pastItems))
            }
            
            return sections
        }).asDriver(onErrorJustReturn: [])
        
        //User Actions
        self.tableSections.map({ $0.count == 0 }).map({ $0 ? _backgroundViewController.view : nil }).drive(_backgroundView).disposed(by: disposeBag)
        self.emptyVisitsViewModel.actionButtonTapped.drive(_addDoctorVisitAction).disposed(by: disposeBag)
        
        _addDoctorVisitAction.map({ DoctorVisit(byDefault: true) }).bind(to: _doctorVisitTranition).disposed(by: disposeBag)
    }
}

struct VisitsSection {
    
    let title: String
    
    var items: [ViewModelProtocol]
    
}

extension VisitsSection: SectionModelType {
    
    typealias Item = ViewModelProtocol
    
    init(original: VisitsSection, items: [Item]) {
        self = original
        self.items = items
    }
    
}
