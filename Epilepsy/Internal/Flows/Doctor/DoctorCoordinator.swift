//
//  DoctorCoordinator.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 16/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class DoctorVisitsCoordinator: CoordinatorProtocol {
    
    // MARK: Public Properties
    
    // MARK: Private Properties
    
    private var doctorVisitDetailsCoordinator: DoctorVisitDetailsCoordinator!
    
    private let settingsCoordinator = SettingsCoordinator()
    
    private let disposeBag = DisposeBag()
    
    // MARK: CoordinatorProtocol Methods
    
    func start(from viewController: UIViewController) -> Observable<Void> {
        let doctorNavigationController = UIStoryboard(name: DoctorVisitsViewController.identifier, bundle: nil).instantiateInitialViewController() as! UINavigationController
        let doctorViewController = doctorNavigationController.topViewController as! DoctorVisitsViewController
        let tabBarController = viewController as! UITabBarController
        
        doctorViewController.viewModel = DoctorVisitsViewModel()
        
        doctorViewController.viewModel.presentDoctorVisitDetails.drive(onNext: { (doctorVisit) in
            self.doctorVisitDetailsCoordinator = DoctorVisitDetailsCoordinator(visit: doctorVisit)
            let _ = self.coordinate(to: self.doctorVisitDetailsCoordinator, from: doctorNavigationController)
        }).disposed(by: disposeBag)
        
        doctorViewController.viewModel.presentSettings.drive(onNext: { () in
            let _ = self.coordinate(to: self.settingsCoordinator, from: doctorNavigationController)
        }).disposed(by: disposeBag)
        
        tabBarController.viewControllers?.append(doctorNavigationController)
        return Observable.never()
    }
    
    func coordinate(to coordinator: CoordinatorProtocol, from viewController: UIViewController) -> Observable<Void> {
        return coordinator.start(from: viewController)
    }
    
}
