//
//  CreateFitCoordinator.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 20/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class FitDetailsCoordinator: CoordinatorProtocol {
    
    // MARK: Public Properties
    
    // MARK: Private Properties
    
    private let fit: Fit
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle
    
    init(fit: Fit) {
        self.fit = fit
    }
    
    // MARK: CoordinatorProtocol Methods
    
    func start(from viewController: UIViewController) -> Observable<Void> {
        let createFitViewController = UIStoryboard(name: CreateFitTableViewController.identifier, bundle: nil).instantiateInitialViewController() as! CreateFitTableViewController
        createFitViewController.viewModel = FitDetailsViewModel(fit: fit)
        
        let nvc = viewController as! UINavigationController
        nvc.pushViewController(createFitViewController, animated: true)
        
        createFitViewController.viewModel.dismissView.bind(onNext: { () in
            nvc.popViewController(animated: true)
        }).disposed(by: disposeBag)
        
        return Observable.never()
    }
    
    func coordinate(to coordinator: CoordinatorProtocol, from viewController: UIViewController) -> Observable<Void> {
        return coordinator.start(from: viewController)
    }
    
}
