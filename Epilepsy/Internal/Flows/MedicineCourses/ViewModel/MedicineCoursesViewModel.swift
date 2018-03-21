//
//  MedicineCoursesViewModel.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 27/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxDataSources
import RxCocoa
import RealmSwift
import RxRealm

class MedicineCoursesViewModel: ViewModelProtocol {
    
    // MARK: Public Properties - Input
    
    let createNewCourseTap: AnyObserver<Void>
    
    let editCourseTap: AnyObserver<Drug>
    
    // MARK: Private Properties - Output
    
    let tableSections: Driver<[MedicineCourseSection]>
    
    let presentCourseDetails: Driver<Drug>
    
    let backgroundView: Driver<UIView?>
    
    // MARK: Private Properties
    
    private let emptyListViewModel: EmptyListViewModel
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle
    
    init() {
        let _createNewCourseAction = PublishSubject<Void>()
        self.createNewCourseTap = _createNewCourseAction.asObserver()
        
        let _editCourse = PublishSubject<Drug>()
        self.editCourseTap = _editCourse.asObserver()
        self.presentCourseDetails = _editCourse.asDriver(onErrorJustReturn: Drug(date: Date()))
        
        _createNewCourseAction.map({ Drug(date: Date()) }).bind(to: _editCourse).disposed(by: disposeBag)
        
        let drugs = try! Realm().objects(Drug.self).sorted(byKeyPath: "startData", ascending: true)
        self.tableSections = Observable.collection(from: drugs).map({ (drugs) -> [MedicineCourseSection] in
            return drugs.map({ MedicineCourseSection(drug: $0) })
        }).asDriver(onErrorJustReturn: [])
        
        self.emptyListViewModel = EmptyListViewModel(description: EmptyListDescription(icon: #imageLiteral(resourceName: "drugs-list-placeholder"),description: NSLocalizedString("У вас не записаны лекарства. Вы можете добавить курс приема лекарств и получаеть уведомления, чтобы не пропустить прием.", comment: ""), actionButtonText: NSLocalizedString("Добавить лекарство", comment: "")))
        let _backgroundViewController = EmptyListViewController.instance(with: self.emptyListViewModel)
        
        let _backgroundView = BehaviorSubject<UIView?>(value: _backgroundViewController.view)
        self.backgroundView = _backgroundView.asDriver(onErrorJustReturn: nil)
        
        self.tableSections.map({ $0.count == 0 }).map({ $0 ? _backgroundViewController.view : nil }).drive(_backgroundView).disposed(by: disposeBag)
        self.emptyListViewModel.actionButtonTapped.drive(_createNewCourseAction).disposed(by: disposeBag)
    }
    
}

enum MedicineCourseItemType {
    case baseInfo
    case medicationInfo(Int)
    case medicationHistoryTitle
    case medicationHistoryInfo(Int)
}

struct MedicineCourseItem {
    
    let type: MedicineCourseItemType
    
    let drug: Drug
    
}

struct MedicineCourseSection: SectionModelType {
    
    var items: [MedicineCourseItem]
    
    
    typealias Item = MedicineCourseItem
    
    init(original: MedicineCourseSection, items: [Item]) {
        self = original
        self.items = items
    }
    
    init(drug: Drug) {
        self.items = [MedicineCourseItem(type: .baseInfo, drug: drug)]
        for i in 0 ..< drug.medications.count {
            self.items.append(MedicineCourseItem(type: .medicationInfo(i), drug: drug))
        }
        if drug.dozeHistory.count > 0 {
            self.items.append(MedicineCourseItem(type: .medicationHistoryTitle, drug: drug))
            for i in 0 ..< drug.dozeHistory.count {
                self.items.append(MedicineCourseItem(type: .medicationHistoryInfo(i), drug: drug))
            }
        }
    }
    
}


