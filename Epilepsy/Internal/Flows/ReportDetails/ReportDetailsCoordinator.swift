//
//  ReportDetailsCoordinator.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 07/03/2018.
//  Copyright © 2018 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class ReportDetailsCoordinator: CoordinatorProtocol {

    // MARK: Public Properties
    
    var reportDetailsViewModel: ReportDetailsViewModel?
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: CoordinatorProtocol Methods
    
    func start(from viewController: UIViewController) -> Observable<Void> {
        let navigationController = viewController as! UINavigationController
        let reportDetailsViewController = UIStoryboard(name: ReportDetailsViewController.identifier, bundle: nil).instantiateInitialViewController() as! ReportDetailsViewController
    
        
        reportDetailsViewController.viewModel = reportDetailsViewModel!
        
        navigationController.pushViewController(reportDetailsViewController, animated: true)
        return Observable.never()
    }
    
    func coordinate(to coordinator: CoordinatorProtocol, from viewController: UIViewController) -> Observable<Void> {
        return coordinator.start(from: viewController)
    }

}
