//
//  CoordinatorProtocol.swift
//  rxDemo
//
//  Created by DmitriyBagrov on 04/09/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol CoordinatorProtocol {
    func start(from viewController: UIViewController) -> Observable<Void>
    func coordinate(to coordinator: CoordinatorProtocol, from viewController: UIViewController) -> Observable<Void>
}
