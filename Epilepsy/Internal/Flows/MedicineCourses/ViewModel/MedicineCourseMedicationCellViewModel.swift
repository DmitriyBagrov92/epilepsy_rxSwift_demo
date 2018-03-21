//
//  MedicineCourseMedicationCellViewModel.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 02/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MedicineCourseMedicationCellViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Output
    
    let medicationName: Driver<String>
    
    let medicationComment: Driver<String?>
    
    let medicationIsNotificationImageHidden: Driver<Bool>
    
    let medicationTime: Driver<String>
    
    // MARK - Lifecycle
    
    init(index: Int, drug: Drug) {
        let medicationNames = [NSLocalizedString("Первый прием", comment: ""),
        NSLocalizedString("Второй прием", comment: ""),
        NSLocalizedString("Третий прием", comment: "")]
        let medication = drug.medications[index]
        
        self.medicationName = Observable.of(index).map({ medicationNames[$0] }).asDriver(onErrorJustReturn: "Error")
        
        self.medicationComment = Observable.of(medication.comment).asDriver(onErrorJustReturn: nil)
        self.medicationIsNotificationImageHidden = Observable.of(medication.notificationEnabled).map({ !$0 }).asDriver(onErrorJustReturn: true)
        self.medicationTime = Observable.of(medication.time).asDriver(onErrorJustReturn: "Error")
    }
    
}
