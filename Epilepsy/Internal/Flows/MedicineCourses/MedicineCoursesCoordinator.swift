//
//  MedicineCourses.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 27/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class MedicineCoursesCoordinator: CoordinatorProtocol {
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    private var medicineCourseDetailsCoordinator: MedicineCourseDetailsCoordinator?
    
    // MARK: CoordinatorProtocol Methods
    
    func start(from viewController: UIViewController) -> Observable<Void> {
        let medicineCoursesVC = UIStoryboard(name: MedicineCoursesViewController.identifier, bundle: nil).instantiateInitialViewController() as! MedicineCoursesViewController
        let nvc = viewController as! UINavigationController
        
        medicineCoursesVC.viewModel = MedicineCoursesViewModel()
        
        medicineCoursesVC.viewModel.presentCourseDetails.drive(onNext: { drug in
            self.medicineCourseDetailsCoordinator = MedicineCourseDetailsCoordinator(drug: drug)
            let _ = self.coordinate(to: self.medicineCourseDetailsCoordinator!, from: nvc)
        }).disposed(by: disposeBag)
        
        nvc.pushViewController(medicineCoursesVC, animated: true)
        return Observable.never()
    }
    
    func coordinate(to coordinator: CoordinatorProtocol, from viewController: UIViewController) -> Observable<Void> {
        return coordinator.start(from: viewController)
    }
    
}
