//
//  DoctorVisitCellViewModel.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 13/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import RealmSwift
import RxRealm

class DoctorVisitFullInfoCellViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Input
    
    let visitStatusButtonTap: AnyObserver<Void>
    
    let editVisitButtonTap: AnyObserver<Void>
    
    // MARK - Public Properties: Output
    
    let visitStatusButtonIsSelected: Driver<Bool>
    
    let visitStatusButtonIsHidden: Driver<Bool>
    
    let visitName: Driver<String>
    
    let visitDate: Driver<String>
    
    let visitTime: Driver<String>
    
    let visitDoctor: Driver<String>
    
    let presentVisit: Driver<DoctorVisit>
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK - Lifecycle
    
    init(visit: DoctorVisit) {
        let _updateVisitStatus = PublishSubject<Void>()
        self.visitStatusButtonTap = _updateVisitStatus.asObserver()
        
        let _editVisitAction = PublishSubject<Void>()
        self.editVisitButtonTap = _editVisitAction.asObserver()
        
        let _visitIsDone = BehaviorSubject<Bool>(value: visit.isDone)
        self.visitStatusButtonIsSelected = _visitIsDone.asDriver(onErrorJustReturn: false)
        self.visitStatusButtonIsHidden = Observable.of(visit.visitDate > Date()).asDriver(onErrorJustReturn: true)
        
        let _visitName = BehaviorSubject<String>(value: visit.name ?? "-")
        self.visitName = _visitName.asDriver(onErrorJustReturn: "Error")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let _visitDate = BehaviorSubject<String>(value: dateFormatter.string(from: visit.visitDate))
        self.visitDate = _visitDate.asDriver(onErrorJustReturn: "Error")
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let _visitTime = BehaviorSubject<String>(value: timeFormatter.string(from: visit.visitDate))
        self.visitTime = _visitTime.asDriver(onErrorJustReturn: "Error")
        
        let _visitDoctor = BehaviorSubject<String>(value: visit.doctor ?? "-")
        self.visitDoctor = _visitDoctor.asDriver(onErrorJustReturn: "Error")
        
        let _presentDoctorVisit = PublishSubject<DoctorVisit>()
        self.presentVisit = _presentDoctorVisit.asDriver(onErrorJustReturn: DoctorVisit())
        
        //User Actions
        _updateVisitStatus.bind(onNext: { () in
            guard visit.visitDate < Date() else { return }
            try! Realm().write {
                visit.isDone = !visit.isDone
            }
            _visitIsDone.onNext(visit.isDone)
        }).disposed(by: disposeBag)
        
        _editVisitAction.map({ visit }).bind(to: _presentDoctorVisit).disposed(by: disposeBag)
    }
    
}
