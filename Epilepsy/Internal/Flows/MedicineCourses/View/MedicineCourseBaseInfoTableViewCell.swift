//
//  MedicineCourseBaseInfoTableViewCell.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 02/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MedicineCourseBaseInfoTableViewCell: DisposableTableViewCell {

    // MARK: IBOutlets - Views
    
    @IBOutlet weak var editMedicineButton: UIButton!
    
    @IBOutlet weak var medicineCourseNameLabel: UILabel!
    
    @IBOutlet weak var medicineCourseDateLabel: UILabel!
    
    @IBOutlet weak var medicineCourseDozeLabel: UILabel!
    
    @IBOutlet weak var medicineCourseFormLabel: UILabel!
    
    @IBOutlet weak var nextDozeTitleLabel: UILabel!
    
    @IBOutlet weak var nextDozeDateLabel: UILabel!
    
    // MARK - Public Methods

    func bind(with viewModel: MedicineCourseBaseInfoCellViewModel) {
        viewModel.drugName.drive(medicineCourseNameLabel.rx.text).disposed(by: disposeBag)
        viewModel.drugDate.drive(medicineCourseDateLabel.rx.text).disposed(by: disposeBag)
        viewModel.drugDoze.drive(medicineCourseDozeLabel.rx.text).disposed(by: disposeBag)
        viewModel.drugForm.drive(medicineCourseFormLabel.rx.text).disposed(by: disposeBag)
        viewModel.nextDozeInfoHidden.drive(nextDozeTitleLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.nextDozeInfoHidden.drive(nextDozeDateLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.nextDozeDate.drive(nextDozeDateLabel.rx.text).disposed(by: disposeBag)
        editMedicineButton.rx.tap.bind(to: viewModel.editDrugButtonTap).disposed(by: disposeBag)
    }

}
