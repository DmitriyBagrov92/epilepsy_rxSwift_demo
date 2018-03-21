//
//  DoctorVisitDetailsCoordinator.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 13/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class DoctorVisitDetailsCoordinator: CoordinatorProtocol {
    
    // MARK: Public Properties
    
    // MARK: Private Properties
    
    private let visit: DoctorVisit
    
    private let disposeBag = DisposeBag()
    
    // MARK - Lifecycle
    
    init(visit: DoctorVisit) {
        self.visit = visit
    }
    
    // MARK: CoordinatorProtocol Methods
    
    func start(from viewController: UIViewController) -> Observable<Void> {
        let doctorVisitDetailsVC = UIStoryboard(name: DoctorVisitDetailsViewController.identifier, bundle: nil).instantiateInitialViewController() as! DoctorVisitDetailsViewController
        let nvc = viewController as! UINavigationController
        
        doctorVisitDetailsVC.viewModel = DoctorVisitDetailsViewModel(visit: visit)
        
        nvc.pushViewController(doctorVisitDetailsVC, animated: true)
        
        doctorVisitDetailsVC.viewModel.dismissView.drive(onNext: { () in
            nvc.popViewController(animated: true)
        }).disposed(by: disposeBag)
        
        return Observable.never()
    }
    
    func coordinate(to coordinator: CoordinatorProtocol, from viewController: UIViewController) -> Observable<Void> {
        return coordinator.start(from: viewController)
    }
    
}
