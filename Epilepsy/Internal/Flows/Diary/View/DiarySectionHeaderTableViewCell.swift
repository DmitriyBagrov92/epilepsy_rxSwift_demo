//
//  DiarySectionHeaderTableViewCell.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 05/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class DiarySectionHeaderTableViewCell: DisposableTableViewCell {

    // MARK: IBOutlets - Views
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    // MARK - Public Methods
    
    func bind(with viewModel: DiarySectionHeaderViewModel) {
        self.isUserInteractionEnabled = false
        viewModel.title.drive(titleLabel.rx.text).disposed(by: disposeBag)
        viewModel.icon.drive(iconImageView.rx.image).disposed(by: disposeBag)
    }
    
}
