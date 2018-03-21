//
//  DoctorVisitDetailsViewModel.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 13/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxRealm
import RxCocoa
import ActionSheetPicker_3_0
import RealmSwift
import CoreGraphics
import SwiftDate

class DoctorVisitDetailsViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Input
    
    let visitNameInput: AnyObserver<String?>
    
    let doctorNameInput: AnyObserver<String?>
    
    let notificationEnableInput: AnyObserver<Bool>
    
    let saveButtonTap: AnyObserver<Void>
    
    let removeButtonTap: AnyObserver<Void>
    
    let tableItemSelection: AnyObserver<(UITableView, IndexPath)>
    
    // MARK - Public Properties: Output
    
    let viewTitle: Driver<String>
    
    let visitName: Driver<String?>
    
    let doctorName: Driver<String?>
    
    let visitDate: Driver<String?>
    
    let visitTime: Driver<String?>
    
    let notificationEnabled: Driver<Bool>
    
    let notificationTime: Driver<String>
    
    let tableItemsCustomHeight: Driver<[IndexPath: CGFloat]>
    
    let saveButtonTitle: Driver<String>
    
    let dismissView: Driver<Void>
    
    // MARK: Private Properties
    
    private let visit: DoctorVisit
    
    private let disposeBag = DisposeBag()
    
    // MARK - Lifecycle
    
    init(visit: DoctorVisit) {
        let isVisitCreated = try! Realm().object(ofType: DoctorVisit.self, forPrimaryKey: visit.id) != nil
        
        self.visit = visit.detached()
        
        self.viewTitle = Observable.of(isVisitCreated ? NSLocalizedString("Редактирование визита", comment: "") : NSLocalizedString("Добавление визита", comment: "")).asDriver(onErrorJustReturn: "Error")
        
        let _visitName = BehaviorSubject<String?>(value: self.visit.name)
        self.visitNameInput = _visitName.asObserver()
        self.visitName = _visitName.asDriver(onErrorJustReturn: nil)
        
        let _doctorName = BehaviorSubject<String?>(value: self.visit.doctor)
        self.doctorNameInput = _doctorName.asObserver()
        self.doctorName = _doctorName.asDriver(onErrorJustReturn: nil)
        
        let _visitDate = BehaviorSubject<Date>(value: self.visit.visitDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        self.visitDate = _visitDate.map({ dateFormatter.string(from: $0) }).asDriver(onErrorJustReturn: "Error")
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        self.visitTime = _visitDate.map({ timeFormatter.string(from: $0) }).asDriver(onErrorJustReturn: "Error")
        
        let _notificationEnabled = BehaviorSubject<Bool>(value: self.visit.alertEnabled)
        self.notificationEnableInput = _notificationEnabled.asObserver()
        self.notificationEnabled = _notificationEnabled.asDriver(onErrorJustReturn: false)
        
        let _notificationTime = BehaviorSubject<Date>(value: self.visit.alertDate ?? visit.visitDate - 30.minutes)
        self.notificationTime = _notificationTime.map({ timeFormatter.string(from: $0) }).asDriver(onErrorJustReturn: "Error")
        
        let _itemSelection = PublishSubject<(UITableView, IndexPath)>()
        self.tableItemSelection = _itemSelection.asObserver()
        
        self.saveButtonTitle = Observable.of(isVisitCreated ? NSLocalizedString("Сохранить", comment: "") : NSLocalizedString("Добавить", comment: "")).asDriver(onErrorJustReturn: "Error")
        
        let _saveVisit = PublishSubject<Void>()
        self.saveButtonTap = _saveVisit.asObserver()
        
        let _removeVisit = PublishSubject<Void>()
        self.removeButtonTap = _removeVisit.asObserver()
        
        let _dismissView = PublishSubject<Void>()
        self.dismissView = _dismissView.asDriver(onErrorJustReturn: ())
        
        let _customCellHeights = BehaviorSubject<[IndexPath: CGFloat]>(value: DoctorVisitDetailsRowType.itemHeights(by: self.visit, created: isVisitCreated))
        self.tableItemsCustomHeight = _customCellHeights.asDriver(onErrorJustReturn: [:])
        
        //Attach observers to model params
        _visitName.bind(onNext: { self.visit.name = $0 }).disposed(by: disposeBag)
        _doctorName.bind(onNext: { self.visit.doctor = $0 }).disposed(by: disposeBag)
        _visitDate.bind(onNext: { self.visit.visitDate = $0 }).disposed(by: disposeBag)
        _notificationEnabled.bind(onNext: { self.visit.alertEnabled = $0 }).disposed(by: disposeBag)
        _notificationTime.bind(onNext: { self.visit.alertDate = $0 }).disposed(by: disposeBag)
        
        //Side Effects
//        _visitDate.map({ $0 - 30.minutes }).bind(to: _notificationTime).disposed(by: disposeBag)
        
        //User Actions
        _itemSelection.map( { (tableView, indexPath) -> (UITableView, DoctorVisitDetailsRowType?) in
            return (tableView, DoctorVisitDetailsRowType.cases().filter({ $0.indexPath == indexPath }).first)
        }).bind(onNext: { (tv, type) in
            guard let type = type else { return }
            switch type {
            case .visitDate:
                let datePicker = ActionSheetDatePicker(title: "",
                                                       datePickerMode: .date,
                                                       selectedDate: self.visit.visitDate,
                                                       doneBlock: { (picker, selectedDate, origin) in
                                                        //TODO: Save previous date components
                                                        _visitDate.onNext(selectedDate as! Date)
                }, cancel: { (picker) in
                }, origin: tv.cellForRow(at: type.indexPath))
                datePicker?.minimumDate = Date()
                datePicker?.toolbarButtonsColor = UIColor.EPColors.purple
                datePicker?.show()
            case .visitTime:
                let actionSheet = ActionSheetDatePicker(title: "",
                                                        datePickerMode: .time,
                                                        selectedDate: self.visit.visitDate,
                                                        doneBlock: { (picker, selectedDate, origin) in
                                                            _visitDate.onNext(selectedDate as! Date)
                },
                                                        cancel: { (picker) in
                },
                                                        origin: tv.cellForRow(at: type.indexPath))
                actionSheet?.toolbarButtonsColor = UIColor.EPColors.purple
                actionSheet?.show()
            case .notificationTime:
                let actionSheet = ActionSheetDatePicker(title: "",
                                                        datePickerMode: .time,
                                                        selectedDate: self.visit.alertDate,
                                                        doneBlock: { (picker, selectedDate, origin) in
                                                            _notificationTime.onNext(selectedDate as! Date)
                                                            
                                                            print(timeFormatter.string(from: selectedDate as! Date))
                },
                                                        cancel: { (picker) in
                },
                                                        origin: tv.cellForRow(at: type.indexPath))
                actionSheet?.maximumDate = self.visit.visitDate
                actionSheet?.toolbarButtonsColor = UIColor.EPColors.purple
                actionSheet?.show()
            default:
                ()
            }
        }).disposed(by: disposeBag)
        
        _notificationEnabled.map({ _ in DoctorVisitDetailsRowType.itemHeights(by: self.visit, created: isVisitCreated) }).bind(to: _customCellHeights).disposed(by: disposeBag)
        
        _saveVisit.bind(onNext: { () in
            try! Realm().write {
                try! Realm().add(self.visit, update: isVisitCreated)
            }
        }).disposed(by: disposeBag)
        
        _removeVisit.bind(onNext: { () in
            try! Realm().write {
                try! Realm().delete(visit)
            }
        }).disposed(by: disposeBag)
        
        Observable.merge(_saveVisit, _removeVisit).bind(to: _dismissView).disposed(by: disposeBag)
    }
    
}

enum DoctorVisitDetailsRowType: EnumCollection {
    case visitName
    case visitDoctor
    case visitDate
    case visitTime
    case notificationStatus
    case notificationTime
    case saveAction
    case removeAction
    
    var indexPath: IndexPath {
        switch self {
        case .visitDate:
            return IndexPath(row: 0, section: 2)
        case .visitTime:
            return IndexPath(row: 1, section: 2)
        case .notificationTime:
            return IndexPath(row: 1, section: 3)
        case .removeAction:
            return IndexPath(row: 3, section: 3)
        default:
            //TODO: Implemet
            return IndexPath(row: 0, section: 0)
        }
    }
    
    private func height(by visit: DoctorVisit, created: Bool) -> CGFloat {
        switch self {
        case .notificationTime:
            return visit.alertEnabled ? 44.f : 0.f
        case .removeAction:
            return created ? 74.f : 0.f
        default:
            //TODO: Implemet
            return 0.f
        }
    }
    
    static func itemHeights(by visit: DoctorVisit, created: Bool) -> [IndexPath: CGFloat] {
        let removeItem = DoctorVisitDetailsRowType.removeAction
        let notificationTimeItem = DoctorVisitDetailsRowType.notificationTime
        return [removeItem.indexPath : removeItem.height(by: visit, created: created), notificationTimeItem.indexPath : notificationTimeItem.height(by: visit, created: created)]
    }
    
}
