//
//  DiaryDoctorVisitTableViewCell.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 05/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DiaryDoctorVisitTableViewCell: DisposableTableViewCell {

    // MARK: IBOutlets - Views
    
    @IBOutlet weak var visitNameLabel: UILabel!
    
    @IBOutlet weak var doctorNameLabel: UILabel!
    
    @IBOutlet weak var visitTimeLabel: UILabel!
    
    // MARK - Public Methods
    
    func bind(with viewModel: DiaryDoctorVisitViewModel) {
        viewModel.visitName.drive(visitNameLabel.rx.text).disposed(by: disposeBag)
        viewModel.visitDoctor.drive(doctorNameLabel.rx.text).disposed(by: disposeBag)
        viewModel.visitTime.drive(visitTimeLabel.rx.text).disposed(by: disposeBag)
    }

}
