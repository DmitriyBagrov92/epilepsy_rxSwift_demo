//
//  CreateFitCellViewModel.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 23/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum FitParamType: String {
    case fitDate
    case fitTime
    case fitDuration
    case fitType
    case fitSubType
    case fitDescription
    case fitCreateAction
    case fitDeleteAction
}

protocol FitParamProtocol {
    var type: FitParamType { get }
    var title: String { get }
    var description: String? { get }
}

class CreateFitCellViewModel: ViewModelProtocol {

    // MARK: Public Properties - Output
    
    let param: FitParamProtocol

    let title: Driver<String>

    let description: Driver<String?>

    // MARK: Private Properties
        
    // MARK: Lyfecircle
    
    init(param: FitParamProtocol) {
        self.param = param
        
        self.title = Observable.just(param.title).asDriver(onErrorJustReturn: "Error")
        self.description = Observable.just(param.description).asDriver(onErrorJustReturn: "Error")
    }
    
}
