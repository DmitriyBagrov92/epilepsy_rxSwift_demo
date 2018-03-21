//
//  SettingsCoordinator.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 25/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class SettingsCoordinator: CoordinatorProtocol {
    
    // MARK: Public Properties
    
    // MARK: Private Properties
    
    private var backupCoordinator: BackupCoordinator!
    
    private var tutorialCoordinator: TutorialCoordinator!
    
    private let disposeBag = DisposeBag()
    
    private let tutorialService = TutorialService()
    
    // MARK: CoordinatorProtocol Methods
    
    func start(from viewController: UIViewController) -> Observable<Void> {
        let settingsViewController = UIStoryboard(name: SettingsViewController.identifier, bundle: nil).instantiateInitialViewController() as! SettingsViewController
        let nvc = viewController as! UINavigationController
        
        settingsViewController.viewModel = SettingsViewModel()
        
        settingsViewController.viewModel.presentTutorialSettingsAction.drive(onNext: { _ in
            self.tutorialCoordinator = TutorialCoordinator(tutorialService: self.tutorialService)
            let _ = self.coordinate(to: self.tutorialCoordinator, from: nvc)
        }).disposed(by: disposeBag)
        
        settingsViewController.viewModel.presentBackupSettings.drive(onNext: { (settings) in
            self.backupCoordinator = BackupCoordinator(settings: settings)
            let _ = self.coordinate(to: self.backupCoordinator, from: nvc)
        }).disposed(by: disposeBag)
        
        nvc.pushViewController(settingsViewController, animated: true)
        
        settingsViewController.viewModel.dismissView.drive(onNext: { () in
            nvc.popViewController(animated: true)
        }).disposed(by: disposeBag)
        
        return Observable.never()
    }
    
    func coordinate(to coordinator: CoordinatorProtocol, from viewController: UIViewController) -> Observable<Void> {
        return coordinator.start(from: viewController)
    }
    
}
