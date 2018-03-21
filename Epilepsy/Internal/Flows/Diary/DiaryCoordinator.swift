//
//  DiaryCoordinator.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 16/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class DiaryCoordinator: CoordinatorProtocol {
    
    // MARK: Public Properties
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    private var diaryCalendarCoordinator: DiaryCalendarCoordinator!
    
    private var fitDetailsCoordinator: FitDetailsCoordinator?
    
    private var visitDetailsCoordinator: DoctorVisitDetailsCoordinator?
    
    private let settingsCoordinator = SettingsCoordinator()
    
    // MARK: CoordinatorProtocol Methods
    
    func start(from viewController: UIViewController) -> Observable<Void> {
        let diaryNavigationController = UIStoryboard(name: DiaryViewController.identifier, bundle: nil).instantiateInitialViewController() as! UINavigationController
        let diaryViewController = diaryNavigationController.topViewController as! DiaryViewController
        let tabBarController = viewController as! UITabBarController
        
        let viewModel = DiaryViewModel()
        diaryViewController.viewModel = viewModel
        
        tabBarController.viewControllers?.append(diaryNavigationController)
        
        viewModel.presentCalendar.drive(onNext: { date in
            self.diaryCalendarCoordinator = DiaryCalendarCoordinator(startDate: date)
            self.diaryCalendarCoordinator.calendarDate.drive(viewModel.selectDate).disposed(by: self.disposeBag)
            let _ = self.coordinate(to: self.diaryCalendarCoordinator, from: diaryNavigationController)
        }).disposed(by: disposeBag)
        
        viewModel.presentSettings.drive(onNext: { () in
            let _ = self.coordinate(to: self.settingsCoordinator, from: diaryNavigationController)
        }).disposed(by: disposeBag)
        
        viewModel.presentFit.drive(onNext: { (fit) in
            self.fitDetailsCoordinator = FitDetailsCoordinator(fit: fit)
            let _ = self.coordinate(to: self.fitDetailsCoordinator!, from: diaryNavigationController)
        }).disposed(by: disposeBag)
        
        viewModel.presentVisit.drive(onNext: { (visit) in
            self.visitDetailsCoordinator = DoctorVisitDetailsCoordinator(visit: visit)
            let _ = self.coordinate(to: self.visitDetailsCoordinator!, from: diaryNavigationController)
        }).disposed(by: disposeBag)
        
        return Observable.never()
    }
    
    func coordinate(to coordinator: CoordinatorProtocol, from viewController: UIViewController) -> Observable<Void> {
        return coordinator.start(from: viewController)
    }
    
}
