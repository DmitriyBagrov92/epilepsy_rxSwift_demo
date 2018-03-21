//
//  DisposableTableViewCell.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 04/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DisposableTableViewCell: UITableViewCell, Identifierable {
    
    // MARK: Private Properties
    
    internal var disposeBag = DisposeBag()
    
    // MARK - UITableViewCell Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
}
