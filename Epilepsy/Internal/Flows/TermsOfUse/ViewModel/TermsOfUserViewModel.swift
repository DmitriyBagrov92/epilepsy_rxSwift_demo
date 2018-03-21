//
//  TermsOfUserViewModel.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 17/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TermsOfUserViewModel: ViewModelProtocol {
    
    // MARK: Public Properties - Input
    
    let agreeAction: AnyObserver<Void>
    
    // MARK: Public Properties - Output
    
    let dismissTermsView: Observable<Void>
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle
    
    init(termsService: TermsOfUseService) {
        let _agreeAction = PublishSubject<Void>()
        self.agreeAction = _agreeAction.asObserver()
        self.dismissTermsView = _agreeAction.asObservable()
        _agreeAction.map({ return true }).bind(to: termsService.termsOfUseAcceptance).disposed(by: disposeBag)
    }
}
