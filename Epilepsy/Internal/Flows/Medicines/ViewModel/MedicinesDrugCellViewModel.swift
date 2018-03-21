//
//  MedicinesDrugCellViewModel.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 01/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class MedicinesDrugCellViewModel {

    // MARK - Public Properties: Output
    
    let medicationIsUsedImage: Driver<UIImage>
    
    let medicationName: Driver<String>
    
    let medicationStateIsHidden: Driver<Bool>
    
    let medicationStateText: Driver<String?>
    
    let medicationStateColor: Driver<UIColor>
    
    // MARK - Lifecycle
    
    init(section: MedicinesSection, drug: Drug) {
        let medicationUsing = drug.medications.filter({ $0.time == section.time }).first?.usings.filter({ section.useDate == $0.date }).first
        
        let image = medicationUsing?.isUsed == true ?  #imageLiteral(resourceName: "check_no_border_selected") : #imageLiteral(resourceName: "check_no_border")
        self.medicationIsUsedImage = Observable.of(image).asDriver(onErrorJustReturn: #imageLiteral(resourceName: "check_no_border"))
        
        self.medicationName = Observable.of(drug.name!).asDriver(onErrorJustReturn: "Error")
        
        self.medicationStateIsHidden = Observable.of(medicationUsing == nil).asDriver(onErrorJustReturn: true)
        
        self.medicationStateText = Observable.of(medicationUsing?.description()).asDriver(onErrorJustReturn: nil)
        
        self.medicationStateColor = Observable.of(medicationUsing?.color ?? UIColor.clear).asDriver(onErrorJustReturn: UIColor.clear)
    }

}
