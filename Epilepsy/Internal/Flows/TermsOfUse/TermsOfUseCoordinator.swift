//
//  TermsOfUseCoordinator.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 17/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift

class TermsOfUserCoordinator: CoordinatorProtocol {
    
    // MARK: Public Properties
    
    // MARK: Private Properties
    
    private let termsService: TermsOfUseService
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle
    
    init(termsService: TermsOfUseService) {
        self.termsService = termsService
    }
    
    // MARK: CoordinatorProtocol Methods
    
    func start(from viewController: UIViewController) -> Observable<Void> {
        let termsNavigationController = UIStoryboard(name: TermsOfUseViewController.identifier, bundle: nil).instantiateInitialViewController() as! UINavigationController
        let termsViewController = termsNavigationController.topViewController as! TermsOfUseViewController
        
        termsViewController.viewModel = TermsOfUserViewModel(termsService: termsService)
        viewController.present(termsNavigationController, animated: true, completion: nil)
        
        return Observable.never()
    }
    
    func coordinate(to coordinator: CoordinatorProtocol, from viewController: UIViewController) -> Observable<Void> {
        return coordinator.start(from: viewController)
    }
}
