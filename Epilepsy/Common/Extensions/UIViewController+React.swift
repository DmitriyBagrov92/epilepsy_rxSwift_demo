//
//  UIViewController+React.swift
//  rxDemo
//
//  Created by DmitriyBagrov on 04/09/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    
    private func controlEvent(for selector: Selector) -> ControlEvent<Void> {
        return ControlEvent(events: sentMessage(selector).map { _ in })
    }
    
    var viewWillAppear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewWillAppear))
    }
    
    var viewDidAppear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewDidAppear))
    }
    
    var viewWillDisappear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewWillDisappear))
    }
    
    var viewDidDisappear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewDidDisappear))
    }
    
}
