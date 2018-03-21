//
//  FitTableViewCell.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 23/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class FitTableViewCell: DisposableTableViewCell {

    // MARK: - IBOutlets: Views
    
    @IBOutlet weak var fitTimeLabel: UILabel!

    @IBOutlet weak var fitTitleLabel: UILabel!
    
    @IBOutlet weak var fitSubTypeLabel: UILabel!
    
    @IBOutlet weak var fitColoredView: UIView!

    // MARK: Public Methods
    
    func bind(with viewModel: FitCellViewModel) {
        viewModel.fitTime.drive(fitTimeLabel.rx.text).disposed(by: disposeBag)
        viewModel.fitTitle.drive(fitTitleLabel.rx.text).disposed(by: disposeBag)
        viewModel.fitSubTitle.drive(fitSubTypeLabel.rx.text).disposed(by: disposeBag)
        viewModel.fitColor.drive(fitColoredView.rx.backgroundColor).disposed(by: disposeBag)
    }

}
