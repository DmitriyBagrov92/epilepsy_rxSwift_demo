//
//  SettingsViewModel.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 25/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift
import ActionSheetPicker_3_0
import SwiftDate

class SettingsViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Input
    
    let saveButtonAction: AnyObserver<Void>
    
    let itemSelection: AnyObserver<(IndexPath, UITableView)>
    
    let dayNotificationEnableAction: AnyObserver<Bool>
    
    // MARK - Public Properties: Output
    
    let medicationDefaultTimes: Driver<[String]>
    
    let dayNotificationTime: Driver<String>
    
    let dayNotificationEnabled: Driver<Bool>
    
    let presentBackupSettings: Driver<Settings>
    
    let presentTutorialSettingsAction: Driver<Settings>
    
    let presentWebTutorial: Driver<URL>
    
    let dismissView: Driver<Void>
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    private let kMinDrugTimes = ["5:00", "12:00", "17:00"]
    
    private let kMaxDrugTimes = ["11:30", "16:30", "23:00"]
    
    private let kMinDayNotificationTime = "17:00"
    
    private let kMaxDayNotificationTime = "23:30"
    
    private let kDayNotificationTimeStep = 30.minutes
    
    // MARK - Lifecycle
    
    init() {
        let realm = try! Realm()
        let storedSettings = realm.objects(Settings.self).first
        let isSettingsCreated = storedSettings != nil
        let settings = isSettingsCreated ? storedSettings!.detached() : Settings(byDefault: true)
        
        let _itemSelection = PublishSubject<(IndexPath, UITableView)>()
        self.itemSelection = _itemSelection.asObserver()
        
        let _presentTutorialSettingsAction = PublishSubject<Void>()
        self.presentTutorialSettingsAction = _presentTutorialSettingsAction.map({ _ in return settings }).asDriver(onErrorJustReturn: Settings())
        
        let _dayNotificationTime = BehaviorSubject<String>(value: settings.endOfDayNotificationTime)
        self.dayNotificationTime = _dayNotificationTime.asDriver(onErrorJustReturn: "Error")
        
        let _dayNotificationEnable = BehaviorSubject<Bool>(value: settings.isEndOfDayNotificationsEnabled)
        self.dayNotificationEnableAction = _dayNotificationEnable.asObserver()
        self.dayNotificationEnabled = _dayNotificationEnable.asDriver(onErrorJustReturn: false)
        
        let _presentBackupSettingsAction = PublishSubject<Void>()
        self.presentBackupSettings = _presentBackupSettingsAction.map({ _ in return settings }).asDriver(onErrorJustReturn: Settings())
        
        let _medicationDefaultTimes = BehaviorSubject<[String]>(value: Array(settings.medicationDefaultTimes))
        self.medicationDefaultTimes = _medicationDefaultTimes.asDriver(onErrorJustReturn: [])
        
        let _saveAction = PublishSubject<Void>()
        self.saveButtonAction = _saveAction.asObserver()
        self.dismissView = _saveAction.asDriver(onErrorJustReturn: ())
        
        let _presentWebTutorial = PublishSubject<URL>()
        self.presentWebTutorial = _presentWebTutorial.asDriver(onErrorJustReturn: URL(fileURLWithPath: ""))
        
        //User Actions
        
        _itemSelection.filter({ $0.0 == SettingsRowType.backup.indexPath }).map({ _ in Void() }).bind(to: _presentBackupSettingsAction).disposed(by: disposeBag)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        _itemSelection.filter({ $0.0 == SettingsRowType.tutorial.indexPath }).map({ _ in Void() }).bind(to: _presentTutorialSettingsAction).disposed(by: disposeBag)
        
        _itemSelection.filter({ $0.0 == SettingsRowType.webTutorial.indexPath }).map({ _ in return URL(string: "https://epilepsyinfo.ru")! }).bind(to: _presentWebTutorial).disposed(by: disposeBag)
        
        _itemSelection.filter({ $0.0 == SettingsRowType.officialNotification.indexPath }).map({ _ in return URL(string: "https://epilepsyinfo.ru/upload/LegalNoticeEpilepsyinfo.pdf")! }).bind(to: _presentWebTutorial).disposed(by: disposeBag)
        
        _itemSelection.filter({ [SettingsRowType.medicationDefaultTimeFirst.indexPath, SettingsRowType.medicationDefaultTimeSecond.indexPath, SettingsRowType.medicationDefaultTimeThird.indexPath].contains($0.0) })
            .bind(onNext: { indexPath, tableView in
                let previousDate = timeFormatter.date(from: settings.medicationDefaultTimes[indexPath.row])
                let actionSheet = ActionSheetDatePicker(title: "",
                                                        datePickerMode: .time,
                                                        selectedDate: previousDate,
                                                        doneBlock: { (picker, selectedDate, origin) in
                                                            settings.medicationDefaultTimes[indexPath.row] = timeFormatter.string(from: (selectedDate as! Date))
                                                            _medicationDefaultTimes.onNext(Array(settings.medicationDefaultTimes))
                },
                                                        cancel: { (picker) in
                },
                                                        origin: tableView.cellForRow(at: indexPath))
                actionSheet?.toolbarButtonsColor = UIColor.EPColors.purple
                actionSheet?.minimumDate = timeFormatter.date(from: self.kMinDrugTimes[indexPath.row])
                actionSheet?.maximumDate = timeFormatter.date(from: self.kMaxDrugTimes[indexPath.row])
                actionSheet?.show()
            }).disposed(by: disposeBag)
        
        _itemSelection.filter({ [SettingsRowType.dayNotificationTime.indexPath].contains($0.0) }).bind(onNext: { (indexPath, tableView) in
            var notificationPossibleTimeCursor = timeFormatter.date(from: self.kMinDayNotificationTime)!
            var notificationPossibleTimes: [Date] = []
            while notificationPossibleTimeCursor <= timeFormatter.date(from: self.kMaxDayNotificationTime)! {
                notificationPossibleTimes.append(notificationPossibleTimeCursor)
                notificationPossibleTimeCursor = notificationPossibleTimeCursor + self.kDayNotificationTimeStep
            }
            let notificationFormattedTimes = notificationPossibleTimes.map({ timeFormatter.string(from: $0) })
            let actionSheet = ActionSheetStringPicker(title: "",
                                                      rows: notificationFormattedTimes,
                                                      initialSelection: notificationFormattedTimes.index(of: settings.endOfDayNotificationTime) ?? 0,
                                                      doneBlock: { (picker, selectedIndex, origin) in
                                                        _dayNotificationTime.onNext(notificationFormattedTimes[selectedIndex])
            },
                                                      cancel: { (picker) in
            },
                                                      origin: tableView.cellForRow(at: indexPath))
            actionSheet?.toolbarButtonsColor = UIColor.EPColors.purple
            actionSheet?.show()
        }).disposed(by: disposeBag)
        
        _saveAction.bind(onNext: { try! realm.write { realm.add(settings, update: isSettingsCreated) }  }).disposed(by: disposeBag)
        
        //Bind User Actions to Data
        
        _dayNotificationTime.bind(onNext: { settings.endOfDayNotificationTime = $0 }).disposed(by: disposeBag)
        _dayNotificationEnable.bind(onNext: { settings.isEndOfDayNotificationsEnabled = $0 }).disposed(by: disposeBag)
    }
    
}

enum SettingsRowType: EnumCollection {
    case tutorial
    case webTutorial
    case officialNotification
    case backup
    case medicationDefaultTimeFirst
    case medicationDefaultTimeSecond
    case medicationDefaultTimeThird
    case dayNotificationTime
    
    var indexPath: IndexPath {
        switch self {
        case .tutorial:
            return IndexPath(row: 0, section: 0)
        case .webTutorial:
            return IndexPath(row: 1, section: 0)
        case .officialNotification:
            return IndexPath(row: 2, section: 0)
        case .medicationDefaultTimeFirst:
            return IndexPath(row: 0, section: 1)
        case .medicationDefaultTimeSecond:
            return IndexPath(row: 1, section: 1)
        case .medicationDefaultTimeThird:
            return IndexPath(row: 2, section: 1)
        case .backup:
            return IndexPath(row: 0, section: 5)
        case .dayNotificationTime:
            return IndexPath(row: 1, section: 4)
        }
    }
}
