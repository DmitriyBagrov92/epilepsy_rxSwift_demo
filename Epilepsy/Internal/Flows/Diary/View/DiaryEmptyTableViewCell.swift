//
//  DiaryEmptyTableViewCell.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 06/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DiaryEmptyTableViewCell: DisposableTableViewCell {

    // MARK: IBOutlets - Views
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK - Public Methods
    
    func bind(with viewModel: DiaryEmptyCellViewModel) {
        viewModel.title.drive(descriptionLabel.rx.text).disposed(by: disposeBag)
    }
}
