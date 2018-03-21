//
//  FitstHistoryCoordinator.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 16/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class FitsCoordinator: CoordinatorProtocol {
    
    // MARK: Public Properties
    
    // MARK: Private Properties
    
    private var fitDetailsCoordinator: FitDetailsCoordinator!
    
    private let settingsCoordinator = SettingsCoordinator()
    
    private let disposeBag = DisposeBag()
    
    // MARK: CoordinatorProtocol Methods
    
    func start(from viewController: UIViewController) -> Observable<Void> {
        let fitsNavigationController = UIStoryboard(name: FitsViewController.identifier, bundle: nil).instantiateInitialViewController() as! UINavigationController
        let fitsViewController = fitsNavigationController.topViewController as! FitsViewController
        
        fitsViewController.viewModel = FitsViewModel()
        
        let tabBarController = viewController as! EpilepsyTabBarController
        tabBarController.viewControllers = [fitsNavigationController]
        
        fitsViewController.viewModel.presentFitDetails.drive(onNext: { fit in
            self.fitDetailsCoordinator = FitDetailsCoordinator(fit: fit)
            let _ = self.coordinate(to: self.fitDetailsCoordinator, from: fitsNavigationController)
        }).disposed(by: disposeBag)
        
        fitsViewController.viewModel.presentSettings.bind(onNext: { () in
            let _ = self.coordinate(to: self.settingsCoordinator, from: fitsNavigationController)
        }).disposed(by: disposeBag)
        
        return Observable.never()
    }
    
    func coordinate(to coordinator: CoordinatorProtocol, from viewController: UIViewController) -> Observable<Void> {
        return coordinator.start(from: viewController)
    }
    
}
