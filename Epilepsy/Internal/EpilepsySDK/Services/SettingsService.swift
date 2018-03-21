//
//  SettingsService.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 19/03/2018.
//  Copyright © 2018 DmitriyBagrov. All rights reserved.
//
import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import UIKit
import CloudKit
import SMTPLite
import RxRealm

class SettingService {

    // MARK - Public Properties: Input
    
    let userBirthDate: AnyObserver<Date?>
    
    // MARK - Public Properties - Output
    
    let isAboutUserSkipped: Observable<Bool>
    
    // MARK: Private Properties
    
    let settings: Settings
    
    private let realm: Realm
    
    private let disposeBag = DisposeBag()
    
    // MARK - View Controller Lifecycle
    
    init() {
        self.realm = try! Realm()
        let isSettingsCreated = realm.objects(Settings.self).count > 0
        self.settings = realm.objects(Settings.self).first ?? Settings(byDefault: true)
        
        let _isAboutUserBirthDate = BehaviorSubject<Date?>(value: settings.userBirthDate)
        self.userBirthDate = _isAboutUserBirthDate.asObserver()
        self.isAboutUserSkipped = _isAboutUserBirthDate.map({ $0 != nil }).asObservable()
        
        _isAboutUserBirthDate.bind(onNext: { (newDate) in
            try! self.realm.write {
                self.settings.userBirthDate = newDate
                self.realm.add(self.settings, update: isSettingsCreated)
            }
            
        }).disposed(by: disposeBag)
    }
    
}

