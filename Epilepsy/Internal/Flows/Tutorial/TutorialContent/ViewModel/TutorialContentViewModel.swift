//
//  TutorialContentViewModel.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 19/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class TutorialContentViewModel: ViewModelProtocol {

    // MARK: Public Properties - Output
    
    let image: Driver<UIImage?>
    
    let title: Driver<String>
    
    let description: Driver<String>
    
    // MARK: Private Methods
    
    private let content: TutorialContent
    
    // MARK: Lyfecircle

    init(content: TutorialContent) {
        self.content = content
        
        self.image = Driver.just(content.image)
        self.title = Driver.just(content.title)
        self.description = Driver.just(content.description)
    }

}
