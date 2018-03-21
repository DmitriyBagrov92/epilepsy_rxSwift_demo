//
//  MedicinesTimeHeaderTableViewCell.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 01/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MedicinesTimeHeaderTableViewCell: DisposableTableViewCell {

    // MARK: IBOutlets - Views

    @IBOutlet weak var medicinesTimeLabel: UILabel!
    
    @IBOutlet weak var selectMedicinesButton: UIButton!
    
    // MARK - Public Methods
    
    func bind(with viewModel: MedicinesSectionHeaderViewModel) {
        viewModel.medicinesIsSelectedState.drive(selectMedicinesButton.rx.isSelected).disposed(by: disposeBag)
        viewModel.medicinesTime.drive(medicinesTimeLabel.rx.text).disposed(by: disposeBag)
        
        selectMedicinesButton.rx.tap.bind(to: viewModel.medicinesUseButtonAction).disposed(by: disposeBag)
    }
    
}
