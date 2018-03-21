//
//  BackupViewModel.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 19/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift
import CoreGraphics
import ActionSheetPicker_3_0

class BackupViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Input
    
    let enableEmailBackupSentSwitch: AnyObserver<Bool>
    
    let enableICloudBackupSentSwitch: AnyObserver<Bool>
    
    let tableViewCellSelection: AnyObserver<(IndexPath, UITableView)>
    
    // MARK - Public Properties: Output
    
    let isICloudBackupEnabled: Driver<Bool>
    
    let iCloudBackupInterval: Driver<String>
    
    let isEmailBackupSentEnabled: Driver<Bool>
    
    let userEmail: Driver<String?>
    
    let emailBackupInterval: Driver<String>
    
    let customCellHeights: Driver<([IndexPath: CGFloat])>
    
    let sectionFooters: Driver<[Int: String]>
    
    let presentAlert: Driver<UIAlertController>
    
    // MARK: Private Properties
    
    private let emailInputCancel: AnyObserver<Void>
    
    private let emailInputError: AnyObserver<EPError>
    
    private let enableEmailBackup: AnyObserver<String>
    
    private let disposeBag = DisposeBag()
    
    // MARK - Lifecycle
    
    init(settings: Settings) {
        let _iCloudBackupEnabled = BehaviorSubject<Bool>(value: settings.isBackupICloudEnabled && settings.isICloudAvailable)
        self.isICloudBackupEnabled = _iCloudBackupEnabled.asDriver(onErrorJustReturn: false)
        
        let _enableICloudBackupAction = PublishSubject<Bool>()
        self.enableICloudBackupSentSwitch = _enableICloudBackupAction.asObserver()
        
        let _iCloudBackupInterval = BehaviorSubject<BackgroundFetchMinimumInterval>(value: BackgroundFetchMinimumInterval(rawValue: settings.backupICloudTimeInterval)!)
        self.iCloudBackupInterval = _iCloudBackupInterval.map({ $0.localizedDescription }).asDriver(onErrorJustReturn: "Error")
        
        let _enableEmailBackupAction = PublishSubject<Bool>()
        self.enableEmailBackupSentSwitch = _enableEmailBackupAction.asObserver()
        
        let _emailBackupSettingsValue = BehaviorSubject<Bool>(value: settings.isBackupEmailSendEnabled)
        self.isEmailBackupSentEnabled = _emailBackupSettingsValue.asDriver(onErrorJustReturn: false)
        
        let _customCellHeights = BehaviorSubject<([IndexPath: CGFloat])>(value: BackupTableRowType.rowHeights(by: settings))
        self.customCellHeights = _customCellHeights.asDriver(onErrorJustReturn: [:])
        
        let _emailValue = BehaviorSubject<String?>(value: settings.userEmail)
        self.userEmail = _emailValue.asDriver(onErrorJustReturn: nil)
        
        let _enableEmailBackup = PublishSubject<String>()
        self.enableEmailBackup = _enableEmailBackup.asObserver()
        
        let _emailBackupInterval = BehaviorSubject<BackgroundFetchMinimumInterval>(value: BackgroundFetchMinimumInterval(rawValue: settings.backupEmailTimeInterval)!)
        self.emailBackupInterval = _emailBackupInterval.map({ $0.localizedDescription }).asDriver(onErrorJustReturn: "Error")
        
        let _presentAlert = PublishSubject<UIAlertController>()
        self.presentAlert = _presentAlert.asDriver(onErrorJustReturn: UIAlertController(nibName: nil, bundle: nil))
        
        let _emailInputError = PublishSubject<EPError>()
        self.emailInputError = _emailInputError.asObserver()
        
        let _emailInputCancel = PublishSubject<Void>()
        self.emailInputCancel = _emailInputCancel.asObserver()
        
        let _sectionFooters = BehaviorSubject<[Int: String]>(value: BackupTableRowType.sectionFooters(by: settings))
        self.sectionFooters = _sectionFooters.asDriver(onErrorJustReturn: [:])
        
        let _cellSelection = PublishSubject<(IndexPath, UITableView)>()
        self.tableViewCellSelection = _cellSelection.asObserver()
        
        //User Actions
        
        _enableICloudBackupAction.bind(onNext: { (isEnabled) in
            if isEnabled && settings.isICloudAvailable == false {
                _presentAlert.onNext(self.alertController(with: EPError.ICloudIsUnavailable))
                _iCloudBackupEnabled.onNext(false)
            } else {
                _iCloudBackupEnabled.onNext(isEnabled)
            }
        }).disposed(by: disposeBag)
        
        _enableEmailBackupAction.bind(onNext: { (isEnabled) in
            if isEnabled && settings.userEmail == nil {
                _presentAlert.onNext(self.alertControllerForUserEmailInput(with: settings))
            } else {
                _emailBackupSettingsValue.onNext(isEnabled)
            }
        }).disposed(by: disposeBag)
        
        _cellSelection.map({ indexPath, tableView in return (BackupTableRowType.cases().first(where: { indexPath == $0.indexPath }), tableView) }).bind(onNext: { (type, tableView) in
            guard let type = type else { return }
            switch type {
            case .iCLoudFrequency:
                let frequency = BackgroundFetchMinimumInterval(rawValue: settings.backupICloudTimeInterval) ?? BackgroundFetchMinimumInterval.week
                let possibleFrequency = Array(BackgroundFetchMinimumInterval.cases())
                let actionSheet = ActionSheetStringPicker(title: "",
                                                          rows: possibleFrequency.map({  $0.localizedDescription }),
                                                          initialSelection: possibleFrequency.index(of: frequency) ?? 0,
                                                          doneBlock: { (picker, selectedIndex, origin) in
                                                            _iCloudBackupInterval.onNext(possibleFrequency[selectedIndex])
                }, cancel: { (picker) in
                }, origin: tableView.cellForRow(at: type.indexPath))
                actionSheet?.toolbarButtonsColor = UIColor.EPColors.purple
                actionSheet?.show()
            case .userEmail:
                _presentAlert.onNext(self.alertControllerForUserEmailInput(with: settings))
            case .emailFrequency:
                let frequency = BackgroundFetchMinimumInterval(rawValue: settings.backupEmailTimeInterval) ?? BackgroundFetchMinimumInterval.week
                let possibleFrequency = Array(BackgroundFetchMinimumInterval.cases())
                let actionSheet = ActionSheetStringPicker(title: "",
                                                          rows: possibleFrequency.map({  $0.localizedDescription }),
                                                          initialSelection: possibleFrequency.index(of: frequency) ?? 0,
                                                          doneBlock: { (picker, selectedIndex, origin) in
                                                            _emailBackupInterval.onNext(possibleFrequency[selectedIndex])
                }, cancel: { (picker) in
                }, origin: tableView.cellForRow(at: type.indexPath))
                actionSheet?.toolbarButtonsColor = UIColor.EPColors.purple
                actionSheet?.show()
            default: ()
            }
        }).disposed(by: disposeBag)
        
        //Side Effects
        
        _iCloudBackupEnabled.bind(onNext: { settings.isBackupICloudEnabled = $0 }).disposed(by: disposeBag)
        _iCloudBackupInterval.bind(onNext: { settings.backupICloudTimeInterval = $0.rawValue }).disposed(by: disposeBag)
        
        _emailBackupSettingsValue.bind(onNext: { settings.isBackupEmailSendEnabled = $0 }).disposed(by: disposeBag)
        _emailBackupSettingsValue.map({ _ in BackupTableRowType.rowHeights(by: settings) }).bind(to: _customCellHeights).disposed(by: disposeBag)
        
        _emailValue.bind(onNext: { settings.userEmail = $0 }).disposed(by: disposeBag)
        
        _enableEmailBackup.map({ _ in return true }).bind(to: _emailBackupSettingsValue).disposed(by: disposeBag)
        _enableEmailBackup.bind(to: _emailValue).disposed(by: disposeBag)
        
        _emailBackupInterval.bind(onNext: { settings.backupEmailTimeInterval = $0.rawValue }).disposed(by: disposeBag)
        
        _emailInputError.map({ _ in return false }).bind(to: _emailBackupSettingsValue).disposed(by: disposeBag)
        _emailInputError.map( { self.alertController(with: $0) }).bind(to: _presentAlert).disposed(by: disposeBag)
        
        _emailInputCancel.map({ _ in return settings.userEmail?.isEmail ?? false }).bind(to: _emailBackupSettingsValue).disposed(by: disposeBag)
    }
    
    // MARK: Private Methods
    
    private func alertControllerForUserEmailInput(with settings: Settings) -> UIAlertController {
        let controller = UIAlertController(title: NSLocalizedString("E-mail", comment: ""), message: NSLocalizedString("Введите вашу электронную почту", comment: ""), preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("e-mail", comment: "")
            textField.keyboardType = .emailAddress
            textField.text = settings.userEmail
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Отмена", comment: ""), style: .cancel) { action in
            self.emailInputCancel.onNext(())
        }
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action) in
            let email = controller.textFields?.first?.text
            if email?.isEmail == true {
                self.enableEmailBackup.onNext(email!)
            } else {
                self.emailInputError.onNext(EPError.IncorrectEmailInput)
            }
        }
        controller.addAction(cancelAction)
        controller.addAction(okAction)
        return controller
    }
    
    private func alertController(with error: EPError) -> UIAlertController {
        let controller = UIAlertController(title: NSLocalizedString("Ошибка", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
        return controller
    }
    
}

enum BackupTableRowType: String, EnumCollection {
    case iCLoudFrequency
    case userEmail
    case emailFrequency
    
    var indexPath: IndexPath {
        switch self {
        case .iCLoudFrequency:
            return IndexPath(row: 1, section: 0)
        case .userEmail:
            return IndexPath(row: 1, section: 1)
        case .emailFrequency:
            return IndexPath(row: 2, section: 1)
        }
    }
    
    static func rowHeights(by settings: Settings) -> [IndexPath: CGFloat] {
        return [BackupTableRowType.userEmail.indexPath : settings.isBackupEmailSendEnabled ? 44.f : 0.f,
                BackupTableRowType.emailFrequency.indexPath : settings.isBackupEmailSendEnabled ? 44.f : 0.f]
    }
    
    static func sectionFooters(by settings: Settings) -> [Int: String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy в HH:mm"
        return [0 : NSLocalizedString("Я согласен с тем, что данные отправляются во внешние независимые от Приложения источники.", comment: ""),
                1 : String(format: NSLocalizedString("Последнее резервное копирование:\nв iCloud %@\nпо E-mail %@", comment: ""),
                           settings.lastICloudBackupDate == nil ? NSLocalizedString("не производилось", comment: "") : dateFormatter.string(from: settings.lastICloudBackupDate!),
                           settings.lastEmailBackupDate == nil ? NSLocalizedString("не производилось", comment: "") : dateFormatter.string(from: settings.lastEmailBackupDate!) )]
    }
}
