//
//  MedicineCourseDetailsViewModel.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 27/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm
import ActionSheetPicker_3_0
import SwiftDate

class MedicineCourseDetailsViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Input
    
    let medicineTableItemSelected: AnyObserver<(UITableView, IndexPath)>
    
    let medicineNameInput: AnyObserver<String?>
    
    let medicineIsDailyInput: AnyObserver<Bool>
    
    let medicineDozeInput: AnyObserver<String?>
    
    let medicationNotificationEnableInput: AnyObserver<(Int, Bool)>
    
    let medicationCommentsInput: AnyObserver<(Int, String?)>
    
    let saveDrugAction: AnyObserver<Void>
    
    let removeDrugAction: AnyObserver<Void>
    
    // MARK - Public Properties: Output
    
    let viewTitle: Driver<String>
    
    let medicineName: Driver<String?>
    
    let medicineMNN: Driver<String>
    
    let medicineIsDaily: Driver<Bool>
    
    let medicineStartDate: Driver<String>
    
    let medicineEndDate: Driver<String>
    
    let medicineForm: Driver<String>
    
    let medicineDoze: Driver<String?>
    
    let numberOfMedicines: Driver<String>
    
    let secondMedicationSectionHidden: Driver<Bool>
    
    let thirdMedicationSectionHidden: Driver<Bool>
    
    let medicationDateTime: Driver<(Int, String)>
    
    let medicationNotificationEnabled: Driver<(Int, Bool)>
    
    let medicationComments: Driver<(Int, String?)>
    
    let removeDrugRowIsHidden: Driver<Bool>
    
    let saveDrugTitle: Driver<String>
    
    let drugValidationError: Driver<String>
    
    let viewDismiss: Driver<Void>
    
    // MARK: Private Properties
    
    private let drug: Drug
    
    private let disposeBag = DisposeBag()
    
    // MARK - Lifecycle
    
    init(drug: Drug) {
        let isDrugCreated = try! Realm().object(ofType: Drug.self, forPrimaryKey: drug.id) != nil
        
        //Create Medications nested objects copy to!
        self.drug = drug.detached()
        
        self.viewTitle = Observable.of(isDrugCreated ? NSLocalizedString("Препарат", comment: "") : NSLocalizedString("Добавить препарат", comment: "")).asDriver(onErrorJustReturn: "Error")
        
        let _medicineTableSelection = PublishSubject<(UITableView, IndexPath)>()
        self.medicineTableItemSelected = _medicineTableSelection.asObserver()
        
        let _medicineName = BehaviorSubject<String?>(value: self.drug.name)
        self.medicineNameInput = _medicineName.asObserver()
        self.medicineName = _medicineName.asDriver(onErrorJustReturn: nil)
        
        let _medicineMNNSelection = PublishSubject<UIView>()
        
        let _medicineMNN = BehaviorSubject<String>(value: self.drug.mnn)
        self.medicineMNN = _medicineMNN.asDriver(onErrorJustReturn: "Error")
        
        let _medicineIsDaily = BehaviorSubject<Bool>(value: self.drug.isDaily)
        self.medicineIsDailyInput = _medicineIsDaily.asObserver()
        self.medicineIsDaily = _medicineIsDaily.asDriver(onErrorJustReturn: false)
        
        let _medicineStartDateSelection = PublishSubject<UIView>()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        let _medicineStartDate = BehaviorSubject<Date>(value: self.drug.startData)
        self.medicineStartDate = _medicineStartDate.map({ dateFormatter.string(from: $0) }).asDriver(onErrorJustReturn: "Error")
        
        //TODO: Add new doze start date to ui, if startDate != newDozeDate
        let _medicineNextDozeStartDate = BehaviorSubject<Date>(value: self.drug.nextDozeStartDate)
        
        let _medicineEndDateSelection = PublishSubject<UIView>()
        
        let _medicineEndDate = BehaviorSubject<Date>(value: self.drug.endData)
        self.medicineEndDate = Observable.combineLatest(_medicineEndDate, _medicineIsDaily).map({ (endDate, isDaily) -> String in
            if isDaily {
                return "-"
            } else {
                return dateFormatter.string(from: endDate)
            }
        }).asDriver(onErrorJustReturn: "Error")
        
        let _medicineFormSelection = PublishSubject<UIView>()
        
        let _medicineForm = BehaviorSubject<String>(value: self.drug.form)
        self.medicineForm = _medicineForm.asDriver(onErrorJustReturn: "Error")
        
        let _medicineDoze = BehaviorSubject<String?>(value: self.drug.dozeType)
        self.medicineDozeInput = _medicineDoze.asObserver()
        self.medicineDoze = _medicineDoze.asDriver(onErrorJustReturn: nil)
        
        let _numberOfMedicationsSelection = PublishSubject<UIView>()
        
        let _numberOfMedicines = BehaviorSubject<Int>(value: self.drug.medications.count)
        self.numberOfMedicines = _numberOfMedicines.map({ String($0) }).asDriver(onErrorJustReturn: "Error")
        
        let _isSecondMedicationHidden = self.drug.medications.count < 2
        let _secondMedicationSectionHidden = BehaviorSubject<Bool>(value: _isSecondMedicationHidden)
        self.secondMedicationSectionHidden = _secondMedicationSectionHidden.asDriver(onErrorJustReturn: true)
        
        let _isThirdMedicationHidden = self.drug.medications.count < 3
        let _thirdMedicationSectionHidden = BehaviorSubject<Bool>(value: _isThirdMedicationHidden)
        self.thirdMedicationSectionHidden = _thirdMedicationSectionHidden.asDriver(onErrorJustReturn: true)
        
        let _medicationDateTimeSelection = PublishSubject<(Int, UIView)>()
        
        self.removeDrugRowIsHidden = BehaviorSubject<Bool>(value: !isDrugCreated).asDriver(onErrorJustReturn: true)
        
        //TODO: Start with collection
        let _medicineDateTimeStartValues = drug.medications.map({ (drug.medications.index(of: $0)!, $0.time) })
        let _medictionDateTime = PublishSubject<(Int, String)>()
        self.medicationDateTime = Observable.merge(Observable.from(_medicineDateTimeStartValues), _medictionDateTime).asDriver(onErrorJustReturn: (0, "Error"))
        
        let _medicineNotificationEnabledStartValues = drug.medications.map({ (drug.medications.index(of: $0)!, $0.notificationEnabled) })
        let _medicationNotificationEnabled = PublishSubject<(Int, Bool)>()
        self.medicationNotificationEnableInput = _medicationNotificationEnabled.asObserver()
        self.medicationNotificationEnabled = Observable.merge(Observable.from(_medicineNotificationEnabledStartValues), _medicationNotificationEnabled).asDriver(onErrorJustReturn: (0, false))
        
        let _medicineCommentsStartValues = drug.medications.map({ (drug.medications.index(of: $0)!, $0.comment) })
        let _medicationComments = PublishSubject<(Int, String?)>()
        self.medicationCommentsInput = _medicationComments.asObserver()
        self.medicationComments = Observable.merge(Observable.from(_medicineCommentsStartValues), _medicationComments).asDriver(onErrorJustReturn: (0, "Error"))
        
        let _saveDrug = PublishSubject<Void>()
        self.saveDrugAction = _saveDrug.asObserver()
        
        self.saveDrugTitle = Observable.of(isDrugCreated ? NSLocalizedString("Сохранить", comment: "") : NSLocalizedString("Добавить", comment: "")).asDriver(onErrorJustReturn: "Error")
        
        let _validationError = PublishSubject<String>()
        self.drugValidationError = _validationError.asDriver(onErrorJustReturn: "Error")
        
        let _viewDismiss = PublishSubject<Void>()
        self.viewDismiss = _viewDismiss.asDriver(onErrorJustReturn: ())
        
        let _removeDrug = PublishSubject<Void>()
        self.removeDrugAction = _removeDrug.asObserver()
        
        //bind table item selection
        
        _medicineTableSelection.map({ ($0.0, MedicineCoursesCellTypes.indexPaths[$0.1]) }).bind(onNext: { (tableView, type) in
            guard let type = type else { return }
            switch type {
            case .mnn:
                _medicineMNNSelection.onNext(tableView.cellForRow(at: type.indexPath!)!)
            case .startDate:
                _medicineStartDateSelection.onNext(tableView.cellForRow(at: type.indexPath!)!)
            case .endDate:
                _medicineEndDateSelection.onNext(tableView.cellForRow(at: type.indexPath!)!)
            case .form:
                _medicineFormSelection.onNext(tableView.cellForRow(at: type.indexPath!)!)
            case .numberOfMedications:
                _numberOfMedicationsSelection.onNext(tableView.cellForRow(at: type.indexPath!)!)
            case .firstMedicationDateTime:
                _medicationDateTimeSelection.onNext((0, tableView.cellForRow(at: type.indexPath!)!))
            case .secondMedicationDateTime:
                _medicationDateTimeSelection.onNext((1, tableView.cellForRow(at: type.indexPath!)!))
            case .thirdMedicationDateTime:
                _medicationDateTimeSelection.onNext((2, tableView.cellForRow(at: type.indexPath!)!))
            }
        }).disposed(by: disposeBag)
        
        //Bind Input to save data in copied object
        
        _medicineName.bind(onNext: { self.drug.name = $0 }).disposed(by: disposeBag)
        _medicineMNN.bind(onNext: { self.drug.mnn = $0 }).disposed(by: disposeBag)
        _medicineIsDaily.bind(onNext: { isDaily in
            self.drug.isDaily = isDaily
            _medicineEndDate.onNext(self.drug.endData)
        }).disposed(by: disposeBag)
        _medicineStartDate.bind(onNext: { startDate in
            self.drug.startData = startDate
            if startDate > self.drug.endData {
                _medicineEndDate.onNext(startDate)
            }
        }).disposed(by: disposeBag)
        _medicineEndDate.bind(onNext: { self.drug.endData = $0 }).disposed(by: disposeBag)
        _medicineForm.bind(onNext: { self.drug.form = $0 }).disposed(by: disposeBag)
        _medicineDoze.bind(onNext: { self.drug.dozeType = $0 }).disposed(by: disposeBag)
        _numberOfMedicines.bind(onNext: { medicinesCount in
            while self.drug.medications.count > medicinesCount {
                self.drug.medications.removeLast()
            }
            for i in self.drug.medications.count ..< medicinesCount {
                let defaultMedication = DrugMedication(dateTime: Date(), index: i)
                self.drug.medications.append(defaultMedication)
                _medictionDateTime.onNext((i, defaultMedication.time))
            }
            _secondMedicationSectionHidden.onNext(medicinesCount < 2)
            _thirdMedicationSectionHidden.onNext(medicinesCount < 3)
        }).disposed(by: disposeBag)
        
        _medictionDateTime.bind(onNext: { (index, time) in
            self.drug.medications[safe: index]?.time = time
        }).disposed(by: disposeBag)
        _medicationNotificationEnabled.bind(onNext: { (index, isEnabled) in
            self.drug.medications[safe: index]?.notificationEnabled = isEnabled
        }).disposed(by: disposeBag)
        _medicationComments.bind(onNext: { (index, comment) in
            self.drug.medications[safe: index]?.comment = comment
        }).disposed(by: disposeBag)
        
        _medicineStartDate.bind(onNext: { if isDrugCreated == false { self.drug.nextDozeStartDate = $0 }}).disposed(by: disposeBag)
        
        //Table Cell Items Selection
        
        _medicineMNNSelection.bind(onNext: { (cell) in
            let actionSheet = ActionSheetStringPicker(title: "",
                                                      rows: DrugMNN.cases().map({ $0.rawValue }),
                                                      initialSelection: 0, doneBlock: { (picker, selectedIndex, origin) in
                                                        _medicineMNN.onNext(Array(DrugMNN.cases())[selectedIndex].rawValue)
            }, cancel: { (picker) in
            }, origin: cell)
            actionSheet?.toolbarButtonsColor = UIColor.EPColors.purple
            actionSheet?.show()
        }).disposed(by: disposeBag)
        
        _medicineStartDateSelection.bind(onNext: { (cell) in
            let actionSheet = ActionSheetDatePicker(title: "",
                                                    datePickerMode: .date,
                                                    selectedDate: self.drug.startData,
                                                    doneBlock: { (picker, selectedDate, origin) in
                                                        _medicineStartDate.onNext(selectedDate as! Date)
            },
                                                    cancel: { (picker) in
            },
                                                    origin: cell)
            actionSheet?.toolbarButtonsColor = UIColor.EPColors.purple
//            actionSheet?.minimumDate = Date().startOfDay
            actionSheet?.show()
        }).disposed(by: disposeBag)
        
        _medicineEndDateSelection.withLatestFrom(Observable.combineLatest(_medicineIsDaily, _medicineStartDate, _medicineEndDateSelection)).bind(onNext: { (isDaily, startDate, cell) in
            guard isDaily == false else { return }
            let actionSheet = ActionSheetDatePicker(title: "",
                                                    datePickerMode: .date,
                                                    selectedDate: self.drug.endData ?? Date(),
                                                    doneBlock: { (picker, selectedDate, origin) in
                                                        _medicineEndDate.onNext(selectedDate as! Date)
            },
                                                    cancel: { (picker) in
            },
                                                    origin: cell)
            actionSheet?.minimumDate = startDate
            actionSheet?.toolbarButtonsColor = UIColor.EPColors.purple
            actionSheet?.show()
        }).disposed(by: disposeBag)
        
        _medicineFormSelection.bind(onNext: { (cell) in
            let actionSheet = ActionSheetStringPicker(title: "",
                                                      rows: DrugForm.cases().map({ $0.rawValue }),
                                                      initialSelection: 0, doneBlock: { (picker, selectedIndex, origin) in
                                                        _medicineForm.onNext(Array(DrugForm.cases())[selectedIndex].rawValue)
            }, cancel: { (picker) in
            }, origin: cell)
            actionSheet?.toolbarButtonsColor = UIColor.EPColors.purple
            actionSheet?.show()
        }).disposed(by: disposeBag)
        
        _numberOfMedicationsSelection.bind(onNext: { (cell) in
            let actionSheet = ActionSheetStringPicker(title: "",
                                                      rows: ["1", "2", "3"],
                                                      initialSelection: self.drug.medications.count - 1,
                                                      doneBlock: { (picker, selectedIndex, origin) in
                                                        _numberOfMedicines.onNext(selectedIndex + 1)
            }, cancel: { (picker) in
            }, origin: cell)
            actionSheet?.toolbarButtonsColor = UIColor.EPColors.purple
            actionSheet?.show()
        }).disposed(by: disposeBag)
        
        _medicationDateTimeSelection.bind(onNext: { (index, cell) in
            guard let medication = self.drug.medications[safe: index] else { return }
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let actionSheet = ActionSheetDatePicker(title: "",
                                                    datePickerMode: .time,
                                                    selectedDate: timeFormatter.date(from: medication.time)!,
                                                    doneBlock: { (picker, selectedDate, origin) in
                                                        _medictionDateTime.onNext((index, timeFormatter.string(from: selectedDate as! Date)))
            },
                                                    cancel: { (picker) in
            },
                                                    origin: cell)
            actionSheet?.toolbarButtonsColor = UIColor.EPColors.purple
            actionSheet?.show()
        }).disposed(by: disposeBag)
        
        _saveDrug.bind(onNext: { () in
            if let error = self.drug.isValid {
                _validationError.onNext(error.localizedDescription)
            } else {
                _medicineName.dispose()
                _medicineDoze.dispose()
                _medicineIsDaily.dispose()
                _medicationNotificationEnabled.dispose()
                _medicationComments.dispose()
                if isDrugCreated {
                    self.drug.insertNewDozeHistoryIfNeed(drug.dozeType)
                
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(self.drug, update: true)
                    }
                } else {
                    Observable.of(self.drug).subscribe(Realm.rx.add()).disposed(by: self.disposeBag)
                }
                _viewDismiss.onNext(())
            }
        }).disposed(by: disposeBag)
        
        _removeDrug.bind(onNext: { () in
            _medicineName.dispose()
            _medicineDoze.dispose()
            _medicineIsDaily.dispose()
            _medicationNotificationEnabled.dispose()
            _medicationComments.dispose()
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.object(ofType: Drug.self, forPrimaryKey: drug.id)!)
            }
            _viewDismiss.onNext(())
        }).disposed(by: disposeBag)
    }
    
}

enum MedicineCoursesCellTypes: String {
    case mnn
    case startDate
    case endDate
    case form
    case numberOfMedications
    case firstMedicationDateTime
    case secondMedicationDateTime
    case thirdMedicationDateTime
    
    static var indexPaths: [IndexPath: MedicineCoursesCellTypes] {
        return [IndexPath(row: 0, section: 1) : .mnn,
                IndexPath(row: 1, section: 2) : .startDate,
                IndexPath(row: 2, section: 2) : .endDate,
                IndexPath(row: 0, section: 3) : .form,
                IndexPath(row: 0, section: 4) : .numberOfMedications,
                IndexPath(row: 0, section: 5) : .firstMedicationDateTime,
                IndexPath(row: 4, section: 5) : .secondMedicationDateTime,
                IndexPath(row: 8, section: 5) : .thirdMedicationDateTime]
        
    }
    
    var indexPath: IndexPath? {
        return MedicineCoursesCellTypes.indexPaths.filter({ $0.value == self }).first?.key
    }
}
