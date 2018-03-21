//
//  DiarySectionHeaderViewModela.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 05/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DiarySectionHeaderViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Output
    
    let title: Driver<String?>
    
    let icon: Driver<UIImage?>
    
    // MARK - Lifecycle
    
    init(type: DiaryTableSectionType) {
        self.title = Observable.of(type.title).asDriver(onErrorJustReturn: nil)
        self.icon = Observable.of(type.icon).asDriver(onErrorJustReturn: nil)
    }
}
