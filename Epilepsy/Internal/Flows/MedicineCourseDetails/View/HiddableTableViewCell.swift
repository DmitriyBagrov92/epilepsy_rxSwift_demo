//
//  HiddableTableViewCell.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 29/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit

class HiddableTableViewCell: UITableViewCell {

    // MARK: IBOutlets - Views
    
    @IBOutlet weak var height: NSLayoutConstraint!
    
    func setHidden(_ value: Bool) {
        if value {
            height.constant = 0.0
        } else {
            height.constant = 44.0
        }
        layoutIfNeeded()
    }

}
