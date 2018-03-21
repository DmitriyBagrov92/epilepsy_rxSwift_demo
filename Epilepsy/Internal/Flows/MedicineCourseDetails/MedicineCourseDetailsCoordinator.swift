//
//  MedicineCourseDetailsCoordinator.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 27/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MedicineCourseDetailsCoordinator: CoordinatorProtocol {
    
    // MARK: Private Properties
    
    private let drug: Drug
    
    private let disposeBag = DisposeBag()
    
    // MARK - Lifecycle
    
    init(drug: Drug) {
        self.drug = drug
    }
    
    // MARK: CoordinatorProtocol Methods
    
    func start(from viewController: UIViewController) -> Observable<Void> {
        let medicineCourseDetailsVC = UIStoryboard(name: MedicineCourseDetailsViewController.identifier, bundle: nil).instantiateInitialViewController() as! MedicineCourseDetailsViewController
        let nvc = viewController as! UINavigationController
        
        medicineCourseDetailsVC.viewModel = MedicineCourseDetailsViewModel(drug: drug)
        
        nvc.pushViewController(medicineCourseDetailsVC, animated: true)
        medicineCourseDetailsVC.viewModel.viewDismiss.drive(onNext: { () in
            nvc.popViewController(animated: true)
        }).disposed(by: disposeBag)
        
        return Observable.never()
    }
    
    func coordinate(to coordinator: CoordinatorProtocol, from viewController: UIViewController) -> Observable<Void> {
        return coordinator.start(from: viewController)
    }
    
}
