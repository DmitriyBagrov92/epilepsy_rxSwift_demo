//
//  ViewControllerProtocol.swift
//  rxDemo
//
//  Created by DmitriyBagrov on 04/09/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation

protocol ViewControllerProtocol {
    associatedtype VM: ViewModelProtocol
    var viewModel: VM! { get set }
}
