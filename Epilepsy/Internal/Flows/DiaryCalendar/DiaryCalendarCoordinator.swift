//
//  DiaryCalendarCoordinator.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 07/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

class DiaryCalendarCoordinator: CoordinatorProtocol {
    
    // MARK: Public Properties - Output
    
    let calendarDate: Driver<Date>
    
    // MARK: Private Properties
    
    private let startDate: Date
    
    private let calendarDateObserver: AnyObserver<Date>
    
    private var disposeBag = DisposeBag()
    
    // MARK - Lifecycle
    
    init(startDate: Date) {
        self.startDate = startDate
        
        let _calendarDate = PublishSubject<Date>()
        self.calendarDate = _calendarDate.asDriver(onErrorJustReturn: Date())
        self.calendarDateObserver = _calendarDate.asObserver()
    }
    
    // MARK: CoordinatorProtocol Methods
    
    func start(from viewController: UIViewController) -> Observable<Void> {
        let nvc = viewController as! UINavigationController
        let diaryCalendarVC = UIStoryboard(name: DiaryCalendarViewController.identifier, bundle: nil).instantiateInitialViewController() as! DiaryCalendarViewController
        
        let viewModel = DiaryCalendarViewModel(selectedDate: startDate)
        diaryCalendarVC.viewModel = viewModel
        nvc.pushViewController(diaryCalendarVC, animated: true)
        
        viewModel.selectedDate.drive(calendarDateObserver).disposed(by: disposeBag)
        
        return Observable.never()
    }
    
    func coordinate(to coordinator: CoordinatorProtocol, from viewController: UIViewController) -> Observable<Void> {
        return coordinator.start(from: viewController)
    }
}
