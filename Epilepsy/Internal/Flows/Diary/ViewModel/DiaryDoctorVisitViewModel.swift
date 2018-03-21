//
//  DiaryDoctorVisitViewModel.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 14/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxRealm
import RealmSwift

class DiaryDoctorVisitViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Output
    
    let visitName: Driver<String>
    
    let visitTime: Driver<String>
    
    let visitDoctor: Driver<String>
    
    // MARK - Lifecycle
    
    init(visit: DoctorVisit) {
        let visitObservable = Observable.from(object: visit)
        self.visitName = visitObservable.map({ $0.name ?? "-" }).asDriver(onErrorJustReturn: "Error")
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        self.visitTime = visitObservable.map({ timeFormatter.string(from: $0.visitDate) }).asDriver(onErrorJustReturn: "Error")
        
        self.visitDoctor = visitObservable.map({ $0.doctor ?? "-" }).asDriver(onErrorJustReturn: "Error")
    }
    
}
