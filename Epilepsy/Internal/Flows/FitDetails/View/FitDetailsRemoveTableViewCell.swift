//
//  FitDetailsRemoveTableViewCell.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 15/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class FitDetailsRemoveTableViewCell: DisposableTableViewCell {

    // MARK: IBOutlets - Views
    
    @IBOutlet weak var removeButton: UIButton!
    
    // MARK - Public Methods
    
    func bind(with viewModel: FitDetailsViewModel) {
        removeButton.rx.tap.bind(to: viewModel.removeFitTap).disposed(by: disposeBag)
    }

}
