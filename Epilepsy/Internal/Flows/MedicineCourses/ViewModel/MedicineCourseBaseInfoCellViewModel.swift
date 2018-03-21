//
//  MedicineCourseBaseInfoCellViewModel.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 02/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MedicineCourseBaseInfoCellViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Input
    
    let editDrugButtonTap: AnyObserver<Void>
    
    // MARK - Public Properties: Output
    
    let drugName: Driver<String?>
    
    let drugDate: Driver<String>
    
    let drugDoze: Driver<String?>
    
    let drugForm: Driver<String>
    
    let nextDozeInfoHidden: Driver<Bool>
    
    let nextDozeDate: Driver<String?>
    
    let presentDrugEditing: Driver<Drug>
    
    // MARK - Lifecycle
    
    init(drug: Drug) {
        self.drugName = Observable.of(drug.name).asDriver(onErrorJustReturn: "Error")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        self.drugDate = Observable.of((drug.startData, drug.endData, drug.isDaily)).map({ (startDate, endDate, isDaily) -> String in
            var drugDates = dateFormatter.string(from: startDate)
            if isDaily {
                drugDates = drugDates + " - " + dateFormatter.string(from: endDate)
            }
            return drugDates
        }).asDriver(onErrorJustReturn: "Error")
        self.drugDoze = Observable.of(drug.dozeType).asDriver(onErrorJustReturn: nil)
        self.drugForm = Observable.of(drug.form).asDriver(onErrorJustReturn: "Error")
        
        self.nextDozeDate = Observable.of(drug.nextDozeStartDate).map({ dateFormatter.string(from: $0) }).asDriver(onErrorJustReturn: "Error")
        self.nextDozeInfoHidden = Observable.of(drug.nextDozeStartDate.isInSameDayOf(date: drug.startData)).asDriver(onErrorJustReturn: true)
        
        let _editDrug = PublishSubject<Void>()
        self.editDrugButtonTap = _editDrug.asObserver()
        self.presentDrugEditing = _editDrug.withLatestFrom(Observable.of(drug)).asDriver(onErrorJustReturn: Drug(date: Date()))
    }
    
}
