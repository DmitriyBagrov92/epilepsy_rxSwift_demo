//
//  TutorialCoordinator.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 19/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class TutorialCoordinator: CoordinatorProtocol {

    // MARK: Public Properties
    
    let tutorialService: TutorialService
    
    // MARK: Private Properties
    
    // MARK: Lyfecircle
    
    init(tutorialService: TutorialService) {
        self.tutorialService = tutorialService
    }
    
    // MARK: CoordinatorProtocol Methods
    
    func start(from viewController: UIViewController) -> Observable<Void> {
        let tutorialViewController = UIStoryboard(name: TutorialViewController.identifier, bundle: nil).instantiateInitialViewController() as! TutorialViewController
        tutorialViewController.viewModel = TutorialViewModel(tutorialService: tutorialService)
        
        viewController.present(tutorialViewController, animated: true, completion: nil)
    
        return Observable.never()
    }
    
    func coordinate(to coordinator: CoordinatorProtocol, from viewController: UIViewController) -> Observable<Void> {
        return coordinator.start(from: viewController)
    }
}
