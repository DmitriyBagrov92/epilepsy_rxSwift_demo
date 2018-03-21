//
//  DoctorVisitsShortInfoTableViewCell.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 13/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class DoctorVisitsShortInfoTableViewCell: DisposableTableViewCell {

    // MARK: IBOutlets - Views
    
    @IBOutlet weak var visitStateButton: UIButton!
    
    @IBOutlet weak var visitNameLabel: UILabel!
    
    @IBOutlet weak var visitDateLabel: UILabel!
    
    @IBOutlet weak var visitStateTextLabel: UILabel!
    
    // MARK - Public Methods
    
    func bind(with viewModel: DoctorVisitsShortInfoCellViewModel) {
        visitStateButton.rx.tap.bind(to: viewModel.visitDoneTap).disposed(by: disposeBag)
        viewModel.visitStateIsDone.drive(visitStateButton.rx.isSelected).disposed(by: disposeBag)
        viewModel.visitName.drive(visitNameLabel.rx.text).disposed(by: disposeBag)
        viewModel.visitDate.drive(visitDateLabel.rx.text).disposed(by: disposeBag)
        viewModel.visitIsDoneText.drive(visitStateTextLabel.rx.text).disposed(by: disposeBag)
    }
}
