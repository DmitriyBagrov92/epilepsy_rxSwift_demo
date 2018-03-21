//
//  DiaryDrugCellViewModel.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 05/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import SwiftDate

class DiaryDrugCellViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Output
    
    let drugName: Driver<String?>
    
    let drugMedicationsAttributedText: Driver<[NSAttributedString?]>
    
    let drugMedicationStateDescription: Driver<String>
    
    let drugMedicationStateColor: Driver<UIColor>
    
    // MARK: Private Properties
    
    private let kNumberOfDrugTimes = 3
    
    // MARK - Lifecycle
    
    init(drug: Drug, currentDate: Date) {
        self.drugName = Observable.of(drug.name).asDriver(onErrorJustReturn: nil)
        
        let _medications = drug.medications.sorted(byKeyPath: "time", ascending: true)
        let _medicationsViewList = [0,1,2].map({ _medications[safe: $0] ?? nil })
        
        let _currentDrugMedication = _medications.reduce(_medications.first!) { (result, next) -> DrugMedication in
            let nextMedicationUsing = next[currentDate]
            if nextMedicationUsing.state == .failed {
                return next
            } else if nextMedicationUsing.state == .inWrongTime {
                return next
            } else if let medicationUseDate = result.useDate(with: currentDate), medicationUseDate < Date() {
                return next
            } else {
                return result
            }
        }
        let _currentDrugMedicationDate = _currentDrugMedication.useDate(with: currentDate)
        let _medicationUsing = _currentDrugMedication[_currentDrugMedicationDate ?? Date()]
        
        self.drugMedicationStateDescription = Observable.of(_medicationUsing.description()).asDriver(onErrorJustReturn: "Error")
        self.drugMedicationStateColor = Observable.of(_medicationUsing.color).asDriver(onErrorJustReturn: UIColor.red)
        
        self.drugMedicationsAttributedText = Observable.of(_medicationsViewList.map( { (medication) -> NSAttributedString? in
            guard let medication = medication else { return nil }
            let medicationUsing = medication[medication.useDate(with: currentDate)!]
            let attribuedString = NSMutableAttributedString(string: medication.time)
            attribuedString.addAttribute(.strikethroughStyle, value: medicationUsing.isCrossedOut ? 2 : 0, range: NSMakeRange(0, attribuedString.length))
            attribuedString.addAttribute(.foregroundColor, value: medicationUsing.color, range: NSMakeRange(0, attribuedString.length))
            return attribuedString
        })).asDriver(onErrorJustReturn: [])
    }
    
}
