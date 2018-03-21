//
//  DiaryDrugTableViewCell.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 05/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DiaryDrugTableViewCell: DisposableTableViewCell {
    
    // MARK: IBOutlets - Views
    
    @IBOutlet weak var drugNameLabel: UILabel!
    
    @IBOutlet weak var drugStateDescriptionLabel: UILabel!
    
    @IBOutlet weak var drugStateColor: UIView!
    
    @IBOutlet var drugMedicationDateLabels: [UILabel]!
    
    // MARK - Public Methods
    
    func bind(with viewModel: DiaryDrugCellViewModel) {
        viewModel.drugName.drive(drugNameLabel.rx.text).disposed(by: disposeBag)
        viewModel.drugMedicationStateDescription.drive(drugStateDescriptionLabel.rx.text).disposed(by: disposeBag)
        viewModel.drugMedicationStateColor.drive(drugStateColor.rx.backgroundColor).disposed(by: disposeBag)
        viewModel.drugMedicationsAttributedText.drive(onNext: { (attributedTexts) in
            for i in 0..<self.drugMedicationDateLabels.count {
                self.drugMedicationDateLabels[i].attributedText = attributedTexts[i]
            }
        }).disposed(by: disposeBag)
    }
}
