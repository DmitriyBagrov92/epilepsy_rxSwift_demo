//
//  CreateFitTextInputCellViewModel.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 24/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class CreateFitTextInputCellViewModel: ViewModelProtocol {
    
    // MARK: Public Properties - Input
    
    let textInput: AnyObserver<String?>
    
    // MARK: Public Properties - Output
    
    let title: Driver<String>

    let value: Driver<String?>
    
    // MARK: Lyfecircle
    
    init(param: FitParamProtocol) {
        let _textInput = BehaviorSubject<String?>(value: param.description)
        self.textInput = _textInput.asObserver()
        self.value = _textInput.asDriver(onErrorJustReturn: nil)
        
        self.title = Observable.just(param.title).asDriver(onErrorJustReturn: "Error")
    }
    
}
