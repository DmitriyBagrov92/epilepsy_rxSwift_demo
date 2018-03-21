//
//  CreateFitViewModel.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 20/11/2017.
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
import RxKeyboard

class FitDetailsViewModel: ViewModelProtocol {
    
    // MARK: Public Properties - Input
    
    let createFitAction: AnyObserver<Void>
    
    let createFitParamTapped: AnyObserver<(UITableView, IndexPath, FitParam)>
    
    let createFitDescriptionInput: AnyObserver<String?>
    
    let removeFitTap: AnyObserver<Void>
    
    // MARK: Public Properties - Output
    
    let viewTitle: Driver<String>
    
    let saveFitButtonText: Driver<String>
    
    let tableSections: Observable<[FitParamsSection]>
    
    let tableViewItemDeselect: Driver<IndexPath>
    
    let dismissView: Observable<Void>
    
    let tableViewContentInset: Driver<UIEdgeInsets>
    
    // MARK: Private Properties
    
    private let fit: Fit
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle
    
    init(fit: Fit) {
        let isFitCreated = try! Realm().object(ofType: Fit.self, forPrimaryKey: fit.id) != nil
        self.saveFitButtonText = Observable.of(isFitCreated).map({ $0 ? NSLocalizedString("Сохранить", comment: "") : NSLocalizedString("Зафиксировать", comment: "")  }).asDriver(onErrorJustReturn: "Error")
        
        self.fit = fit.detached()
        
        let _createFitAction = PublishSubject<Void>()
        self.createFitAction = _createFitAction.asObserver()
        
        let _dismissViewAction = PublishSubject<Void>()
        self.dismissView = _dismissViewAction.asObservable()
        
        let _removeFitAction = PublishSubject<Void>()
        self.removeFitTap = _removeFitAction.asObserver()
        
        let _createFitParamTapped = PublishSubject<(UITableView, IndexPath, FitParam)>()
        self.createFitParamTapped = _createFitParamTapped.asObserver()
        
        let _tableSections = BehaviorSubject<[FitParamsSection]>(value: FitParamsSection.sections(of: self.fit, isCreated: isFitCreated))
        self.tableSections = _tableSections.asObservable()
        
        let _tableViewItemDeselect = PublishSubject<IndexPath>()
        self.tableViewItemDeselect = _tableViewItemDeselect.asDriver(onErrorJustReturn: IndexPath(row: 0, section: 0))
        
        let _createFitDescriptionInput = PublishSubject<String?>()
        self.createFitDescriptionInput = _createFitDescriptionInput.asObserver()
        
        self.tableViewContentInset = RxKeyboard.instance.frame.map({ UIEdgeInsetsMake(0, 0, $0.height, 0) })
        
        self.viewTitle = Observable.of(isFitCreated).map({ $0 ? NSLocalizedString("Приступ", comment: "") : NSLocalizedString("Зафиксировать приступ", comment: "") }).asDriver(onErrorJustReturn: "Error")
        
        _createFitDescriptionInput.bind(onNext: { (description) in
            self.fit.fitDescription = description
        }).disposed(by: disposeBag)
        
        _createFitParamTapped.bind(onNext: { [weak self] (tv, ip, param) in
            guard let welf = self else { return }
            _tableViewItemDeselect.onNext(ip)
            switch param.type {
            case .fitDate:
                let actionSheet = ActionSheetDatePicker(title: "",
                                                        datePickerMode: .date,
                                                        selectedDate: self?.fit.fitDate,
                                                        doneBlock: { (picker, selectedDate, origin) in
                                                            guard let welf = self else { return }
                                                            welf.fit.fitDate = selectedDate as! Date
                                                            _tableSections.onNext(FitParamsSection.sections(of: welf.fit, isCreated: isFitCreated))
                },
                                                        cancel: { (picker) in
                },
                                                        origin: tv.cellForRow(at: ip))
                actionSheet?.maximumDate = Date()
                actionSheet?.toolbarButtonsColor = UIColor.EPColors.purple
                actionSheet?.show()
            case .fitTime:
                let actionSheet = ActionSheetDatePicker(title: "",
                                                        datePickerMode: .time, selectedDate: self?.fit.fitDate,
                                                        doneBlock: { (picker, selectedDate, origin) in
                                                            guard let welf = self else { return }
                                                            welf.fit.fitDate = selectedDate as! Date
                                                            _tableSections.onNext(FitParamsSection.sections(of: welf.fit, isCreated: isFitCreated))
                },
                                                        cancel: { (picker) in
                },
                                                        origin: tv.cellForRow(at: ip))
                actionSheet?.maximumDate = Date()
                actionSheet?.toolbarButtonsColor = UIColor.EPColors.purple
                actionSheet?.show()
            case .fitDuration:
//                let hours = Array(0...23)
                let minutes = [0, 0.5] + Array(1...59).map({ Double($0) })
                let printableMinutes = minutes.map({ (second) -> String in
                    if second == 0 {
                        return NSLocalizedString("Несколько секунд", comment: "")
                    } else if second == 0.5 {
                        return NSLocalizedString("30 секунд", comment: "")
                    } else {
                        return String(format: "%0.0f", second) + " " + Int(second).plural(with: .minute)
                    }
                })
                let actionSheet = ActionSheetMultipleStringPicker(title: "",
                                                                  rows: [printableMinutes],
                                                                  initialSelection: [0, 0],
                                                                  doneBlock: { (picker, selectedIndexes, origin) in
                                                                    let selectedMinutes = minutes[selectedIndexes?.last as! Int]
                                                                    welf.fit.duration = selectedMinutes * 60
                                                                    _tableSections.onNext(FitParamsSection.sections(of: welf.fit, isCreated: isFitCreated))
                },
                                                                  cancel: { (picker) in
                },
                                                                  origin: tv.cellForRow(at: ip))
                actionSheet?.toolbarButtonsColor = UIColor.EPColors.purple
                actionSheet?.show()
            case .fitType:
                let actionSheet = ActionSheetStringPicker(title: "",
                                                          rows: FitType.cases().map({ $0.localizedDescription }),
                                                          initialSelection: welf.fit.type,
                                                          doneBlock: { (picker, selectedIndex, origin) in
                                                            welf.fit.type = selectedIndex
                                                            welf.fit.subType = 0
                                                            _tableSections.onNext(FitParamsSection.sections(of: welf.fit, isCreated: isFitCreated))
                }, cancel: { (picker) in
                }, origin: tv.cellForRow(at: ip))
                actionSheet?.toolbarButtonsColor = UIColor.EPColors.purple
                actionSheet?.show()
            case .fitSubType:
                guard let subTypeCases = welf.fit.fitSubType?.cases else { return }
                let actionSheet = ActionSheetStringPicker(title: "",
                                                          rows: subTypeCases,
                                                          initialSelection: welf.fit.subType,
                                                          doneBlock: { (picker, selectedIndex, origin) in
                                                            welf.fit.subType = selectedIndex
                                                            _tableSections.onNext(FitParamsSection.sections(of: welf.fit, isCreated: isFitCreated))
                }, cancel: { (picker) in
                }, origin: tv.cellForRow(at: ip))
                actionSheet?.toolbarButtonsColor = UIColor.EPColors.purple
                actionSheet?.show()
            default: ()
            }
        }).disposed(by: disposeBag)
        
        _createFitAction.withLatestFrom(Observable.just(self.fit)).bind(onNext: { (fit) in
            _createFitDescriptionInput.dispose()
            try! Realm().write {
                try! Realm().add(fit, update: isFitCreated)
            }
        }).disposed(by: disposeBag)
        
        _removeFitAction.bind(onNext: { () in
            try! Realm().write {
                try! Realm().delete(fit)
            }
        }).disposed(by: disposeBag)
        
        _createFitAction.bind(to: _dismissViewAction).disposed(by: disposeBag)
        _removeFitAction.bind(to: _dismissViewAction).disposed(by: disposeBag)
    }
    
}

struct FitParamsSection {
    
    var title: String
    
    var items: [FitParam]
    
    static func sections(of fit: Fit, isCreated: Bool) -> [FitParamsSection] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        var sections = [FitParamsSection(title: NSLocalizedString("ДАТА И ВРЕМЯ", comment: ""), items: [FitParam(type: .fitDate, title: NSLocalizedString("Дата приступа", comment: ""), description: dateFormatter.string(from: fit.fitDate)),
                                                                                                          FitParam(type: .fitTime, title: NSLocalizedString("Время приступа", comment: ""), description: timeFormatter.string(from: fit.fitDate)),
                                                                                                          FitParam(type: .fitDuration, title: NSLocalizedString("Длительность", comment: ""), description: fit.formattedDuration)]),
                FitParamsSection(title: NSLocalizedString("ПРИСТУП", comment: ""), items:[FitParam(type: .fitType, title: NSLocalizedString("Тип приступа", comment: ""), description: String(fit.fitType?.localizedDescription ?? "")),
                                                                                                 FitParam(type: .fitSubType, title: NSLocalizedString("Подтип приступа", comment: ""), description: String(fit.fitSubType?.localizedDescription ?? "")),
                                                                                                 FitParam(type: .fitDescription, title: NSLocalizedString("Опишите приступ", comment: ""), description: fit.fitDescription),
                                                                                                 FitParam(type: .fitCreateAction, title: NSLocalizedString("", comment: ""), description: nil)])
        ]
        if isCreated {
            sections[1].items.append(FitParam(type: .fitDeleteAction, title: NSLocalizedString("", comment: ""), description: nil))
        }
        return sections
    }
}

extension FitParamsSection: SectionModelType {
    
    typealias Item = FitParam
    
    init(original: FitParamsSection, items: [Item]) {
        self = original
        self.items = items
    }
    
}

struct FitParam: FitParamProtocol {
    
    // MARK: FitParamProtocol Porperties
    
    var type: FitParamType
    
    var title: String
    
    var description: String?
    
}
