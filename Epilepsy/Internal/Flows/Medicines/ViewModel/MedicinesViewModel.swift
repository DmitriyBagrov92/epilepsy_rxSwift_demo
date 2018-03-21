//
//  MedicinesViewModel.swift
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
import ActionSheetPicker_3_0
import SwiftDate

class MedicinesViewModel: ViewModelProtocol {
    
    // MARK: Public Properties - Input
    
    let coursesButtonTap: AnyObserver<Void>
    
    let medicineItemSelection: AnyObserver<(MedicinesSection, Drug)>
    
    let medicinesDate: AnyObserver<Date>
    
    let medicinesNextDateAction: AnyObserver<Void>
    
    let medicinesPreviousDateAction: AnyObserver<Void>
    
    let settingsButtonTap: AnyObserver<Void>
    
    let calendarButtonTap: AnyObserver<Void>
    
    // MARK: Public Properties - Output
    
    let coursesScreenPresent: Driver<Void>
    
    let tableSections: Driver<[MedicinesSection]>
    
    let currentDate: Driver<String>
    
    let backgroundView: Driver<UIView?>
    
    let createDrugAction: Driver<Date>
    
    let presentSettigns: Driver<Void>
    
    let presentCalendar: Driver<Date>
    
    let presentAlertActios: Driver<(String, [UIAlertAction])>
    
    // MARK: Private Properties
    
    private let emptyListViewModel: EmptyListViewModel
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle
    
    init() {
        let realm = try! Realm()
        
        let _coursesButtonAction = PublishSubject<Void>()
        self.coursesButtonTap = _coursesButtonAction.asObserver()
        self.coursesScreenPresent = _coursesButtonAction.asDriver(onErrorJustReturn: ())
        
        let _medicinesDate = BehaviorSubject<Date>(value: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        self.medicinesDate = _medicinesDate.asObserver()
        self.currentDate = _medicinesDate.map({ $0.isToday ? NSLocalizedString("Сегодня", comment: "") : dateFormatter.string(from: $0) }).asDriver(onErrorJustReturn: "Error")
        
        let _medicineItemSelection = PublishSubject<(MedicinesSection, Drug)>()
        self.medicineItemSelection = _medicineItemSelection.asObserver()
        
        let _medicinesNextDate = PublishSubject<Void>()
        self.medicinesNextDateAction = _medicinesNextDate.asObserver()
        
        let _medicinesPreviousDate = PublishSubject<Void>()
        self.medicinesPreviousDateAction = _medicinesPreviousDate.asObserver()
        
        self.emptyListViewModel = EmptyListViewModel(description: EmptyListDescription(icon: #imageLiteral(resourceName: "drugs-list-placeholder"), description: NSLocalizedString("В данный день принимать лекарства не нужно", comment: ""), actionButtonText: NSLocalizedString("Добавить препарат", comment: "")))
        let _backgroundViewController = EmptyListViewController.instance(with: self.emptyListViewModel)
        
        let _backgroundView = BehaviorSubject<UIView?>(value: _backgroundViewController.view)
        self.backgroundView = _backgroundView.asDriver(onErrorJustReturn: nil)
        
        self.createDrugAction = self.emptyListViewModel.actionButtonTapped.withLatestFrom(_medicinesDate.asDriver(onErrorJustReturn: Date()))
        
        let _settingsAction = PublishSubject<Void>()
        self.settingsButtonTap = _settingsAction.asObserver()
        self.presentSettigns = _settingsAction.asDriver(onErrorJustReturn: ())
        
        let _calendarAction = PublishSubject<Void>()
        self.calendarButtonTap = _calendarAction.asObserver()
        self.presentCalendar = _calendarAction.withLatestFrom(_medicinesDate).asDriver(onErrorJustReturn: Date())
        
        let _alertActions = PublishSubject<(String, [UIAlertAction])>()
        self.presentAlertActios = _alertActions.asDriver(onErrorJustReturn: ("",[]))
        
        //User Actions
        
        _medicinesNextDate.withLatestFrom(_medicinesDate).map({ $0 + 1.day }).bind(to: _medicinesDate).disposed(by: disposeBag)
        _medicinesPreviousDate.withLatestFrom(_medicinesDate).map({ $0 - 1.day }).bind(to: _medicinesDate).disposed(by: disposeBag)
        _medicinesDate.map({ $0 < Date().startOfDay }).bind(to: self.emptyListViewModel.actionButtonIsHiddenState).disposed(by: disposeBag)
        
        //Data for display
        
        let drugsChanged = _medicinesDate.map({ NSPredicate(format: "(startData <= %@ AND isDaily = true) OR (isDaily = false AND endData >= %@ AND startData <= %@)", NSDate(timeIntervalSince1970: $0.endOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: $0.startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: $0.endOfDay.timeIntervalSince1970)) })
            .map({ try! Realm().objects(Drug.self).filter($0) }).flatMapLatest({ Observable.collection(from: $0) })
        
        self.tableSections = Observable.combineLatest(drugsChanged, _medicinesDate).map({ (drugs, date) -> [MedicinesSection] in
            var sections: [MedicinesSection] = []
            for drug in drugs {
                for medication in drug.medications {
                    if let indexOfSection = sections.index(where: { $0.time == medication.time }) {
                        sections[indexOfSection].items.append(drug)
                    } else {
                        sections.append(MedicinesSection(time: medication.time, drugs: [drug], useDate: medication.useDate(with: date)))
                    }
                }
            }
            return sections.sorted(by: { $0.time < $1.time })
        }).asDriver(onErrorJustReturn: [])
        
        self.tableSections.map({ $0.count == 0 }).map({ $0 ? _backgroundViewController.view : nil }).drive(_backgroundView).disposed(by: disposeBag)
        
        _medicineItemSelection.withLatestFrom(Observable.combineLatest(_medicineItemSelection, _medicinesDate)).filter({ $0.1 < Date() }).bind(onNext: { selection, date in
            guard let medication = selection.1.medications.filter({ $0.time == selection.0.time }).first else { return }
            guard let useDate = medication.useDate(with: date) else { return }
            let medicationUsing = medication[useDate]
            let usignIndex = medication.usings.index(of: medicationUsing)
            
            let successAction = UIAlertAction(title: NSLocalizedString("Да, вовремя", comment: ""), style: .default, handler: { (action) in
                try! realm.write {
                    if let index = usignIndex {
                        medication.usings.replace(index: index, object: DrugMedicationUsing(type: .successed, date: useDate))
                    } else {
                        medication.usings.append(DrugMedicationUsing(type: .successed, date: useDate))
                    }
                }
            })
            let lateAction = UIAlertAction(title: NSLocalizedString("Нет, опоздал более чем на час", comment: ""), style: .default, handler: { (action) in
                try! realm.write {
                    if let index = usignIndex {
                        medication.usings.replace(index: index, object: DrugMedicationUsing(type: .inWrongTime, date: useDate))
                    } else {
                        medication.usings.append(DrugMedicationUsing(type: .inWrongTime, date: useDate))
                    }
                }
            })
            
            let failedAction = UIAlertAction(title: NSLocalizedString("Пропустил", comment: ""), style: .default, handler: { (action) in
                try! realm.write {
                    if let index = usignIndex {
                        medication.usings.replace(index: index, object: DrugMedicationUsing(type: .failed, date: useDate))
                    } else {
                        medication.usings.append(DrugMedicationUsing(type: .failed, date: useDate))
                    }
                }
            })
            let cancelAction = UIAlertAction(title: NSLocalizedString("Назад", comment: ""), style: .cancel, handler: nil)
            
            _alertActions.onNext((selection.1.name ?? NSLocalizedString("Препарат", comment: ""), [successAction, lateAction, failedAction, cancelAction]))
        }).disposed(by: disposeBag)
    }
    
}

struct MedicinesSection: SectionModelType {
    
    // MARK - Public Properties
    
    var time: String
    
    var useDate: Date?
    
    var items: [Drug]
    
    // MARK - SectionModelType Properties
    
    typealias Item = Drug
    
    // MARK - Lifecycle
    
    init(time: String, drugs: [Drug], useDate: Date?) {
        self.time = time
        self.items = drugs
        self.useDate = useDate
    }
    
    init(original: MedicinesSection, items: [Item]) {
        self = original
        self.items = items
    }
    
}
