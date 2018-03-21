//
//  DiaryEmptyCellViewModel.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 06/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class DiaryEmptyCellViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Output
    
    let title: Driver<String?>
    
    // MARK - Lifecycle
    
    init(type: DiaryTableSectionType) {
        self.title = Observable.of(type.emptyDescription).asDriver(onErrorJustReturn: nil)
    }
    
}
