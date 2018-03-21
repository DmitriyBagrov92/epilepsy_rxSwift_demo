//
//  DoctorVisitFullInfoTableViewCell.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 13/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class DoctorVisitFullInfoTableViewCell: DisposableTableViewCell {

    // MARK: IBOutlets - Views
    
    @IBOutlet weak var visitStateButton: UIButton!
    
    @IBOutlet weak var visitNameLabel: UILabel!
    
    @IBOutlet weak var visitEditButton: UIButton!
    
    @IBOutlet weak var visitDateLabel: UILabel!
    
    @IBOutlet weak var visitTimeLabel: UILabel!
    
    @IBOutlet weak var visitDoctorLabel: UILabel!
    
    // MARK - Public Methods
    
    func bind(with viewModel: DoctorVisitFullInfoCellViewModel) {
        visitStateButton.rx.tap.bind(to: viewModel.visitStatusButtonTap).disposed(by: disposeBag)
        viewModel.visitName.drive(visitNameLabel.rx.text).disposed(by: disposeBag)
        visitEditButton.rx.tap.bind(to: viewModel.editVisitButtonTap).disposed(by: disposeBag)
        viewModel.visitStatusButtonIsSelected.drive(visitStateButton.rx.isSelected).disposed(by: disposeBag)
        viewModel.visitStatusButtonIsHidden.drive(visitStateButton.rx.isHidden).disposed(by: disposeBag)
        viewModel.visitDate.drive(visitDateLabel.rx.text).disposed(by: disposeBag)
        viewModel.visitTime.drive(visitTimeLabel.rx.text).disposed(by: disposeBag)
        viewModel.visitDoctor.drive(visitDoctorLabel.rx.text).disposed(by: disposeBag)
    }
    
}
