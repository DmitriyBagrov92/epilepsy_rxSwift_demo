//
//  MedicineCourseMedicationTableViewCell.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 02/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MedicineCourseMedicationTableViewCell: DisposableTableViewCell {

    // MARK: IBOutlets - Views
    
    @IBOutlet weak var medicationName: UILabel!
    
    @IBOutlet weak var medicationCommentLabel: UILabel!
    
    @IBOutlet weak var medicationNotificationStatusImage: UIImageView!
    
    @IBOutlet weak var medicationTimeLabel: UILabel!
    
    // MARK - Public Methods
    
    func bind(with viewModel: MedicineCourseMedicationCellViewModel) {
        viewModel.medicationName.drive(medicationName.rx.text).disposed(by: disposeBag)
        viewModel.medicationComment.drive(medicationCommentLabel.rx.text).disposed(by: disposeBag)
        viewModel.medicationIsNotificationImageHidden.drive(medicationNotificationStatusImage.rx.isHidden).disposed(by: disposeBag)
        viewModel.medicationTime.drive(medicationTimeLabel.rx.text).disposed(by: disposeBag)
    }
}
