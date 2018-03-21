//
//  CreateFitActionTableViewCell.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 23/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CreateFitActionTableViewCell: DisposableTableViewCell {
    
    // MARK: - IBOutlets: Views
    
    @IBOutlet weak var createFitButton: UIButton!

    // MARK: Public Methods

    func bind(with viewModel: FitDetailsViewModel) {
        createFitButton.rx.tap.bind(to: viewModel.createFitAction).disposed(by: disposeBag)
        viewModel.saveFitButtonText.drive(createFitButton.rx.title()).disposed(by: disposeBag)
    }

}
