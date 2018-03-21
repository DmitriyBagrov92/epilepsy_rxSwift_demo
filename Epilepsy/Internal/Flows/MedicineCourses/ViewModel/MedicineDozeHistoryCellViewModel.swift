//
//  MedicineDozeHistoryCellViewModel.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 16/01/2018.
//  Copyright © 2018 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MedicineDozeHistoryCellViewModel: ViewModelProtocol {

    // MARK - Public Properties: Output
    
    let dozeValue: Driver<String?>

    let startDate: Driver<String?>
    
    let endDate: Driver<String?>
    
    // MARK - Lifecycle

    init(drug: Drug, index: Int) {
        let history = drug.dozeHistory[index]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        self.dozeValue = Observable.of(history.doze).asDriver(onErrorJustReturn: "Error")
        self.startDate = Observable.of(history.startDate).map({ dateFormatter.string(from: $0!) }).asDriver(onErrorJustReturn: "Error")
        self.endDate = Observable.of(history.endDate).map({ dateFormatter.string(from: $0!) }).asDriver(onErrorJustReturn: "Error")
    }

}
