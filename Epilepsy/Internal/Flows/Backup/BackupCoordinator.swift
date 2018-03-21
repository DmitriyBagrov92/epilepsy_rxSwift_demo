//
//  BackupCoordinator.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 19/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

class BackupCoordinator: CoordinatorProtocol {
    
    // MARK: Private Properties
    
    private let settings: Settings
    
    // MARK - Lifecycle
    
    init(settings: Settings) {
        self.settings = settings
    }
    
    // MARK: CoordinatorProtocol Methods
    
    func start(from viewController: UIViewController) -> Observable<Void> {
        let backupTableViewController = UIStoryboard(name: BackupTableViewController.identifier, bundle: nil).instantiateInitialViewController() as! BackupTableViewController
        let nvc = viewController as! UINavigationController
        
        backupTableViewController.viewModel = BackupViewModel(settings: settings)
        
        nvc.pushViewController(backupTableViewController, animated: true)
        
        return Observable.never()
    }
    
    func coordinate(to coordinator: CoordinatorProtocol, from viewController: UIViewController) -> Observable<Void> {
        return coordinator.start(from: viewController)
    }
    
}
