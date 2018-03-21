//
//  CreateFitTextInputTableViewCell.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 24/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CreateFitTextInputTableViewCell: DisposableTableViewCell {

    // MARK: - IBOutlets: Views
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var textField: UITextField!
    
    // MARK: Public Methods
    
    func bind(with viewModel: CreateFitTextInputCellViewModel) {
        viewModel.title.drive(titleLabel.rx.text).disposed(by: disposeBag)
        textField.rx.controlEvent(.editingChanged).withLatestFrom(textField.rx.text).bind(to: viewModel.textInput).disposed(by: disposeBag)
        viewModel.value.drive(textField.rx.text).disposed(by: disposeBag)
    }
    
}
