//
//  AboutUserCoordinator.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 19/03/2018.
//  Copyright © 2018 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

class AboutUserCoordinator: CoordinatorProtocol {
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    private let aboutUserViewMode: AboutUserViewModel
    
    // MARK - Lifecycle
    
    init(settingService: SettingService) {
        self.aboutUserViewMode = AboutUserViewModel(settingService: settingService)
    }
    
    // MARK: CoordinatorProtocol Methods
    
    func start(from viewController: UIViewController) -> Observable<Void> {
        let aboutUserNavigationViewController = UIStoryboard(name: AboutUserViewController.identifier, bundle: nil).instantiateInitialViewController() as! UINavigationController
        let aboutUserViewController = aboutUserNavigationViewController.topViewController as! AboutUserViewController
        
        aboutUserViewController.viewModel = aboutUserViewMode
        
        viewController.present(aboutUserNavigationViewController, animated: true, completion: nil)
        
        return aboutUserViewMode.dismissAboutUser.asObservable()
    }
    
    func coordinate(to coordinator: CoordinatorProtocol, from viewController: UIViewController) -> Observable<Void> {
        return coordinator.start(from: viewController)
    }
    
}
