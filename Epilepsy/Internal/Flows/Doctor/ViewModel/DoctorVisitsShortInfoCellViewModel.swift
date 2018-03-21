//
//  DoctorVisitsShortInfoCellViewModel.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 13/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift

class DoctorVisitsShortInfoCellViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Input
    
    let visitDoneTap: AnyObserver<Void>
    
    // MARK - Public Properties: Output
    
    let visitStateIsDone: Driver<Bool>
    
    let visitName: Driver<String>
    
    let visitDate: Driver<String>
    
    let visitIsDoneText: Driver<String>
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK - Lifecycle
    
    init(visit: DoctorVisit) {
        let _visitDoneAction = PublishSubject<Void>()
        self.visitDoneTap = _visitDoneAction.asObserver()
        
        self.visitStateIsDone = Observable.from(object: visit).map({ $0.isDone }).asDriver(onErrorJustReturn: false)
        
        self.visitName = Observable.of(visit.name).map({ $0 ?? "-" }).asDriver(onErrorJustReturn: "Error")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy в HH:mm"
        self.visitDate = Observable.of(dateFormatter.string(from: visit.visitDate)).asDriver(onErrorJustReturn: "Error")
        
        self.visitIsDoneText = Observable.from(object: visit).map({ $0.isDone }).map({ $0 ? NSLocalizedString("Посетил", comment: "") : NSLocalizedString("Не посетил", comment: "")}).asDriver(onErrorJustReturn: "Error")
        
        _visitDoneAction.withLatestFrom(Observable.of(visit.isDone)).bind(onNext: { (isDone) in
            try! Realm().write {
                visit.isDone = !isDone
            }
        }).disposed(by: disposeBag)
    }
    
}
