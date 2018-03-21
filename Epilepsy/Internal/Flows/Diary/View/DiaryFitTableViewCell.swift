//
//  DiaryFitTableViewCell.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 05/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DiaryFitTableViewCell: DisposableTableViewCell {

    // MARK: IBOutlets - Views
    
    @IBOutlet weak var fitNameLabel: UILabel!
    
    @IBOutlet weak var fitTimeLabel: UILabel!
    
    @IBOutlet weak var fitTypeColoredView: UIView!
    
    // MARK - Public Methods
    
    func bind(with viewModel: DiaryFitCellViewModel) {
        viewModel.fitType.drive(fitNameLabel.rx.text).disposed(by: disposeBag)
        viewModel.fitTime.drive(fitTimeLabel.rx.text).disposed(by: disposeBag)
        viewModel.fitTypeColor.drive(fitTypeColoredView.rx.backgroundColor).disposed(by: disposeBag)
    }

}
