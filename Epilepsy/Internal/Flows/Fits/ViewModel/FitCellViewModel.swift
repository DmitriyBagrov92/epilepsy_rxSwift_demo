//
//  FitCellViewModel.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 23/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

extension FitType {
    
    var color: UIColor {
        switch self {
        case .unknow:
            return UIColor.lightGray
        case .generalized:
            return UIColor.EPColors.lightBlue
        case .focal:
            return UIColor.EPColors.yellow
        case .complicatedParcial:
            return UIColor.EPColors.red
        }
    }
    
}

class FitCellViewModel: ViewModelProtocol {
    
    // MARK: Public Properties - Output
    
    let fitTime: Driver<String>
    
    let fitTitle: Driver<String>
    
    let fitSubTitle: Driver<String?>
    
    let fitColor: Driver<UIColor>
    
    // MARK: Private Properties
    
    let fit: Fit
    
    // MARK: Lyfecircle
    
    init(fit: Fit) {
        self.fit = fit
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        self.fitTime = Observable.just(timeFormatter.string(from: fit.fitDate)).asDriver(onErrorJustReturn: "Error")
        
        self.fitTitle = Observable.just(fit.fitType?.localizedDescription ?? NSLocalizedString("Не знаю", comment: "")).asDriver(onErrorJustReturn: "Error")
        self.fitSubTitle = Observable.just(fit.fitSubType?.localizedDescription).asDriver(onErrorJustReturn: nil)
        self.fitColor = Observable.just(fit.fitType?.color ?? UIColor.lightGray).asDriver(onErrorJustReturn: UIColor.red)
    }
    
}
