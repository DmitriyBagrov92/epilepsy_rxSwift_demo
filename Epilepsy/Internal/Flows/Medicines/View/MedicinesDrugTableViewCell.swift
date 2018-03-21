//
//  MedicinesDrugTableViewCell.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 01/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MedicinesDrugTableViewCell: DisposableTableViewCell {

    // MARK: IBOutlets - Views

    @IBOutlet weak var drugIsUsedImageView: UIImageView!
    
    @IBOutlet weak var drugNameLabel: UILabel!
    
    @IBOutlet weak var medicationStateLabel: UILabel!
    
    @IBOutlet weak var medicationStateView: UIView!
    
    // MARK - Public Methods

    func bind(with viewModel: MedicinesDrugCellViewModel) {
        viewModel.medicationIsUsedImage.drive(drugIsUsedImageView.rx.image).disposed(by: disposeBag)
        viewModel.medicationName.drive(drugNameLabel.rx.text).disposed(by: disposeBag)
        viewModel.medicationStateIsHidden.drive(medicationStateLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.medicationStateIsHidden.drive(medicationStateView.rx.isHidden).disposed(by: disposeBag)
        viewModel.medicationStateText.drive(medicationStateLabel.rx.text).disposed(by: disposeBag)
        viewModel.medicationStateColor.drive(medicationStateView.rx.backgroundColor).disposed(by: disposeBag)
    }
    
}
