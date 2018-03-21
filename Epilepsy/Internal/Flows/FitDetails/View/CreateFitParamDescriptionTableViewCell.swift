//
//  CreateFitParamDescriptionTableViewCell.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 23/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CreateFitParamDescriptionTableViewCell: DisposableTableViewCell {
    
    // MARK: Public Methods

    func bind(with viewModel: CreateFitCellViewModel) {
        viewModel.title.drive(textLabel!.rx.text).disposed(by: disposeBag)
        viewModel.description.drive(detailTextLabel!.rx.text).disposed(by: disposeBag)
    }

}
