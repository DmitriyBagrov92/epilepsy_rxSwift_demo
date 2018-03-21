//
//  MedicineDozeHistoryTableViewCell.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 16/01/2018.
//  Copyright © 2018 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MedicineDozeHistoryTableViewCell: DisposableTableViewCell {

    // MARK: IBOutlets - Views
    
    @IBOutlet weak var dozeValueLabel: UILabel!

    @IBOutlet weak var startDateLabel: UILabel!
    
    @IBOutlet weak var endDateLabel: UILabel!
    
    // MARK - Public Methods
    
    func bind(with viewModel: MedicineDozeHistoryCellViewModel) {
        viewModel.dozeValue.drive(dozeValueLabel.rx.text).disposed(by: disposeBag)
        viewModel.startDate.drive(startDateLabel.rx.text).disposed(by: disposeBag)
        viewModel.endDate.drive(endDateLabel.rx.text).disposed(by: disposeBag)
    }
    
}
