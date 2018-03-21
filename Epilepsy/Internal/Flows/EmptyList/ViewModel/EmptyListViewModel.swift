//
//  EmptyListViewModel.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 03/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

struct EmptyListDescription {
    let icon: UIImage
    let description: String?
    let actionButtonText: String
}

class EmptyListViewModel: ViewModelProtocol {

    // MARK - Public Properties: Input
    
    let actionButtonTap: AnyObserver<Void>
    
    let actionButtonIsHiddenState: AnyObserver<Bool>
    
    // MARK - Public Properties: Output
    
    let actionButtonIsHidden: Driver<Bool>
    
    let iconImage: Driver<UIImage>
    
    let descriptionText: Driver<String?>
    
    let actionButtonText: Driver<String>
    
    let actionButtonTapped: Driver<Void>
    
    // MARK - Lifecycle
    
    init(description: EmptyListDescription) {
        self.descriptionText = Observable.of(description.description).asDriver(onErrorJustReturn: nil)
        self.actionButtonText = Observable.of(description.actionButtonText).asDriver(onErrorJustReturn: "Error")
        self.iconImage = Observable.of(description.icon).asDriver(onErrorJustReturn: UIImage())
        
        let _actionButtonTap = PublishSubject<Void>()
        self.actionButtonTap = _actionButtonTap.asObserver()
        self.actionButtonTapped = _actionButtonTap.asDriver(onErrorJustReturn: ())
        
        let _actionButtonIsHidden = BehaviorSubject<Bool>(value: false)
        self.actionButtonIsHiddenState = _actionButtonIsHidden.asObserver()
        self.actionButtonIsHidden = _actionButtonIsHidden.asDriver(onErrorJustReturn: false)
    }
    
}
