//
//  ReportsCoordinator.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 16/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class ReportsCoordinator: CoordinatorProtocol {

    // MARK: Public Properties
    
    // MARK: Private Properties
    
    private let reportDetailsCoordinator = ReportDetailsCoordinator()
    
    private let reportsViewModel = ReportsViewModel()
    
    private let settingsCoordinator = SettingsCoordinator()
    
    private let disposeBag = DisposeBag()
    
    // MARK: CoordinatorProtocol Methods
    
    func start(from viewController: UIViewController) -> Observable<Void> {
        let reportsNavigationController = UIStoryboard(name: ReportsViewController.identifier, bundle: nil).instantiateInitialViewController() as! UINavigationController
        let reportsViewController = reportsNavigationController.topViewController as! ReportsViewController
        let tabBarController = viewController as! UITabBarController
        
        reportsViewController.viewModel = reportsViewModel
        
        tabBarController.viewControllers?.append(reportsNavigationController)
        
        reportsViewModel.presentReportDetails.drive(onNext: { (reportDetailsViewModel) in
            self.reportDetailsCoordinator.reportDetailsViewModel = reportDetailsViewModel
            let _ = self.coordinate(to: self.reportDetailsCoordinator, from: reportsNavigationController)
        }).disposed(by: disposeBag)
        
        reportsViewModel.presentSettings.drive(onNext: { () in
            let _ = self.coordinate(to: self.settingsCoordinator, from: reportsNavigationController)
        }).disposed(by: disposeBag)
        
        return Observable.never()
    }
    
    func coordinate(to coordinator: CoordinatorProtocol, from viewController: UIViewController) -> Observable<Void> {
        return coordinator.start(from: viewController)
    }

}
