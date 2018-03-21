//
//  MedicinesSectionHeaderViewModel.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 12/01/2018.
//  Copyright © 2018 DmitriyBagrov. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import RealmSwift

class MedicinesSectionHeaderViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Input
    
    let medicinesUseButtonAction: AnyObserver<Void>
    
    // MARK - Public Properties: Output
    
    let medicinesTime: Driver<String>
    
    let medicinesIsSelectedState: Driver<Bool>
    
    let presentAlert: Driver<UIAlertController>
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK - Lifecycle
    
    init(section: MedicinesSection) {
        let _useMedicines = PublishSubject<Void>()
        self.medicinesUseButtonAction = _useMedicines.asObserver()
        
        self.medicinesTime = Observable.of(section.time).asDriver(onErrorJustReturn: "Error")
        
        let isDrugsUsed = Observable.from(section.items).flatMap({ Observable.from(object: $0) }).map({ drug -> Bool in
            for drug in section.items {
                for medication in drug.medications {
                    if medication.time == section.time, medication.usings.contains(where: { $0.date == medication.useDate(with: section.useDate!) }) == false {
                        return false
                    }
                }
            }
            return true
        })
        self.medicinesIsSelectedState = isDrugsUsed.asDriver(onErrorJustReturn: false)
        
        let _presentAlert = PublishSubject<UIAlertController>()
        self.presentAlert = _presentAlert.asDriver(onErrorJustReturn: UIAlertController())
        
        //User Actions
        _useMedicines.map({ self.medicationAlert(for: section) }).bind(to: _presentAlert).disposed(by: disposeBag)
    }
    
}

private extension MedicinesSectionHeaderViewModel {
    
    func medicationAlert(for section: MedicinesSection) -> UIAlertController {
        let realm = try! Realm()
        let alert = UIAlertController(title: NSLocalizedString("Вовремя приняли все лекарства?", comment: ""), message: String(format: NSLocalizedString("В %@", comment: ""), section.time), preferredStyle: .alert)
        
        let successAction = UIAlertAction(title: NSLocalizedString("Да, вовремя", comment: ""), style: .default, handler: { (action) in
            for drug in section.items {
                guard let medication = drug.medications.filter({ $0.time == section.time }).first else { return }
                guard let useDate = medication.useDate(with: section.useDate!) else { return }
                let medicationUsing = medication[useDate]
                let usignIndex = medication.usings.index(of: medicationUsing)
                try! realm.write {
                    if let index = usignIndex {
                        medication.usings.replace(index: index, object: DrugMedicationUsing(type: .successed, date: useDate))
                    } else {
                        medication.usings.append(DrugMedicationUsing(type: .successed, date: useDate))
                    }
                }
            }
            
        })
        let lateAction = UIAlertAction(title: NSLocalizedString("Нет, опоздал более чем на час", comment: ""), style: .default, handler: { (action) in
            for drug in section.items {
                guard let medication = drug.medications.filter({ $0.time == section.time }).first else { return }
                guard let useDate = medication.useDate(with: section.useDate!) else { return }
                let medicationUsing = medication[useDate]
                let usignIndex = medication.usings.index(of: medicationUsing)
                try! realm.write {
                    if let index = usignIndex {
                        medication.usings.replace(index: index, object: DrugMedicationUsing(type: .inWrongTime, date: useDate))
                    } else {
                        medication.usings.append(DrugMedicationUsing(type: .inWrongTime, date: useDate))
                    }
                }
            }
        })
        
        let failedAction = UIAlertAction(title: NSLocalizedString("Пропустил", comment: ""), style: .default, handler: { (action) in
            for drug in section.items {
                guard let medication = drug.medications.filter({ $0.time == section.time }).first else { return }
                guard let useDate = medication.useDate(with: section.useDate!) else { return }
                let medicationUsing = medication[useDate]
                let usignIndex = medication.usings.index(of: medicationUsing)
                try! realm.write {
                    if let index = usignIndex {
                        medication.usings.replace(index: index, object: DrugMedicationUsing(type: .failed, date: useDate))
                    } else {
                        medication.usings.append(DrugMedicationUsing(type: .failed, date: useDate))
                    }
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Назад", comment: ""), style: .cancel, handler: nil)
        
        alert.addAction(successAction)
        alert.addAction(lateAction)
        alert.addAction(failedAction)
        alert.addAction(cancelAction)
        
        return alert
    }
    
}
