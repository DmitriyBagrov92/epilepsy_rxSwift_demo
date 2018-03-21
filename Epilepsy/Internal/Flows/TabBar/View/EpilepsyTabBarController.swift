//
//  EpilepsyTabBarController.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 16/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EpilepsyTabBarController: UITabBarController, ViewControllerProtocol, Identifierable {
    
    // MARK: ViewControllerProtocol Properties
    
    typealias VM = EpilepsyTabBarViewModel

    var viewModel: EpilepsyTabBarViewModel!
    
    // MARK: Lyfecircle

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

}
