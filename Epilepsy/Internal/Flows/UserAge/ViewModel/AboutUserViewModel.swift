//
//  AboutUserViewModel.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 19/03/2018.
//  Copyright © 2018 DmitriyBagrov. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift
import CoreGraphics
import ActionSheetPicker_3_0

class AboutUserViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Input
    
    let nextButtonAction: AnyObserver<Void>
    
    let birthDateChanged: AnyObserver<Date>
    
    // MARK - Public Properties: Output
    
    let pickerMaxDate: Driver<Date>
    
    let dismissAboutUser: Driver<Void>
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK - View Controller Lifecycle
    
    init(settingService: SettingService) {
        let _nextButtonAction = PublishSubject<Void>()
        self.nextButtonAction = _nextButtonAction.asObserver()
        
        let _dismissAction = PublishSubject<Void>()
        self.dismissAboutUser = _dismissAction.asDriver(onErrorJustReturn: ())
        
        self.pickerMaxDate = Observable.just(Date()).asDriver(onErrorJustReturn: Date())
        
        let _birthDateChanged = PublishSubject<Date>()
        self.birthDateChanged = _birthDateChanged.asObserver()
                
        _nextButtonAction.withLatestFrom(_birthDateChanged).bind(to: settingService.userBirthDate).disposed(by: disposeBag)
        _nextButtonAction.bind(to: _dismissAction).disposed(by: disposeBag)
    }
    
    
}
