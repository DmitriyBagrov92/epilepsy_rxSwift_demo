//
//  TabBarCoordinator.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 16/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class TabBarCoordinator: CoordinatorProtocol {
    
    // MARK: Public Properties
    
    // MARK: Private Properties
    
    private let notificationsService: NotificationsService
    
    private let backupService: BackupService
    
    private let fitsCoordinator = FitsCoordinator()
    
    private let medicinesCoordinator = MedicinesCoordinator()
    
    private let diaryCoordinator = DiaryCoordinator()
    
    private let doctorVisitsCoordinator = DoctorVisitsCoordinator()
    
    private let reportsCoordinator = ReportsCoordinator()
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lifecycle
    
    init(notificationsService: NotificationsService, backupService: BackupService) {
        self.notificationsService = notificationsService
        self.backupService = backupService
    }
    
    // MARK: CoordinatorProtocol Methods
    
    func start(from viewController: UIViewController) -> Observable<Void> {
        let tabBarController = UIStoryboard(name: EpilepsyTabBarController.identifier, bundle: nil).instantiateInitialViewController() as! EpilepsyTabBarController
        tabBarController.viewModel = EpilepsyTabBarViewModel()
        
        let _ = coordinate(to: fitsCoordinator, from: tabBarController)
        let _ = coordinate(to: medicinesCoordinator, from: tabBarController)
        let _ = coordinate(to: diaryCoordinator, from: tabBarController)
        let _ = coordinate(to: doctorVisitsCoordinator, from: tabBarController)
        let _ = coordinate(to: reportsCoordinator, from: tabBarController)
        
        viewController.present(tabBarController, animated: true, completion: nil)
        tabBarController.selectedIndex = 2
        
        return Observable.never()
    }
    
    func coordinate(to coordinator: CoordinatorProtocol, from viewController: UIViewController) -> Observable<Void> {
        return coordinator.start(from: viewController)
    }
    
}
