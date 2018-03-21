//
//  TermsOfUseService.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 17/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TermsOfUseService {
    
    // MARK: Public Properties - Input
    
    let termsOfUseAcceptance: AnyObserver<Bool>
    
    // MARK: Public Properties - Output

    let isTermsOfUseAccepted: Observable<Bool>
    
    // MARK: Private Properties
    
    private let storage = UserDefaults.standard
    
    private let kTermsOfUseAccepted = "TermsOfUseAccepted"
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle
    
    init() {
        let _termsOfUseAccepted = BehaviorSubject<Bool>(value: storage.bool(forKey: kTermsOfUseAccepted))
        self.isTermsOfUseAccepted = _termsOfUseAccepted.asObservable()
        self.termsOfUseAcceptance = _termsOfUseAccepted.asObserver()
        
        _termsOfUseAccepted.bind(onNext: { self.storage.set($0, forKey: self.kTermsOfUseAccepted) }).disposed(by: disposeBag)
    }
    
    // MARK: Public Methods
    
    // MARK: Private Methods
    
    
    
}
