//
//  DiaryFitCellViewModel.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 06/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class DiaryFitCellViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Output
    
    let fitType: Driver<String?>
    
    let fitTime: Driver<String>
    
    let fitTypeColor: Driver<UIColor>
    
    // MARK - Lifecycle
    
    init(fit: Fit) {
        self.fitType = Observable.of(fit.fitType?.localizedDescription).asDriver(onErrorJustReturn: nil)
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        self.fitTime = Observable.of(timeFormatter.string(from: fit.fitDate)).asDriver(onErrorJustReturn: "Error")
        self.fitTypeColor = Observable.of(fit.fitType?.color ?? UIColor.red).asDriver(onErrorJustReturn: UIColor.red)
    }
}
