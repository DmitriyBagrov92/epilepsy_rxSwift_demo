//
//  MedicinesCoordinator.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 16/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class MedicinesCoordinator: CoordinatorProtocol {
    
    // MARK: Public Properties
    
    // MARK: Private Properties
    
    private let coursesCoordinator = MedicineCoursesCoordinator()
    
    private var courseDetailsCoordinator: MedicineCourseDetailsCoordinator?
    
    private let settingsCoordinator = SettingsCoordinator()
    
    private var calendarCoordinator: DiaryCalendarCoordinator!
    
    private let disposeBag = DisposeBag()
    
    // MARK: CoordinatorProtocol Methods
    
    func start(from viewController: UIViewController) -> Observable<Void> {
        let medicinesNavigationController = UIStoryboard(name: MedicinesViewController.identifier, bundle: nil).instantiateInitialViewController() as! UINavigationController
        let medicinesViewController = medicinesNavigationController.topViewController as! MedicinesViewController
        let tabBarController = viewController as! UITabBarController
        
        medicinesViewController.viewModel = MedicinesViewModel()
        
        medicinesViewController.viewModel.coursesScreenPresent.drive(onNext: { () in
            let _ = self.coordinate(to: self.coursesCoordinator, from: medicinesNavigationController)
        }).disposed(by: disposeBag)
        
        medicinesViewController.viewModel.createDrugAction.drive(onNext: { date in
            self.courseDetailsCoordinator = MedicineCourseDetailsCoordinator(drug: Drug(date: date))
            let _ = self.coordinate(to: self.courseDetailsCoordinator!, from: medicinesNavigationController)
        }).disposed(by: disposeBag)
        
        medicinesViewController.viewModel.presentSettigns.drive(onNext: { () in
            let _ = self.coordinate(to: self.settingsCoordinator, from: medicinesNavigationController)
        }).disposed(by: disposeBag)
        
        medicinesViewController.viewModel.presentCalendar.drive(onNext: { (date) in
            self.calendarCoordinator = DiaryCalendarCoordinator(startDate: date)
            self.calendarCoordinator.calendarDate.drive(medicinesViewController.viewModel.medicinesDate).disposed(by: self.disposeBag)
            let _ = self.coordinate(to: self.calendarCoordinator, from: medicinesNavigationController)
        }).disposed(by: disposeBag)
        
        tabBarController.viewControllers?.append(medicinesNavigationController)
        return Observable.never()
    }
    
    func coordinate(to coordinator: CoordinatorProtocol, from viewController: UIViewController) -> Observable<Void> {
        return coordinator.start(from: viewController)
    }
    
}
