//
//  UIView+Rx.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 19/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import UIKit

extension Reactive where Base: UIView {
    /// Bindable background color.
    public var backgroundColor: Binder<UIColor> {
        return Binder(self.base) { view, color in
            view.backgroundColor = color
        }
    }
}

extension Reactive where Base: UIButton {
    /// Bindable title color.
    public var titleColor: Binder<UIColor> {
        return Binder(self.base) { view, color in
            view.setTitleColor(color, for: .normal)
        }
    }
}

extension Reactive where Base: UITableView {
    /// Bindable content insets.
    public var contentInset: Binder<UIEdgeInsets> {
        return Binder(self.base) { tableView, insets in
            tableView.contentInset = insets
        }
    }
}

extension Reactive where Base: UITableView {
    /// Bindable Background View.
    public var backgroundView: Binder<UIView?> {
        return Binder(self.base) { tableView, backgroundView in
            tableView.backgroundView = backgroundView
        }
    }
}

extension Reactive where Base: UIDatePicker {
    
    public var maximumDate: Binder<Date> {
        return Binder(self.base) { picker, maximumDate in
            picker.maximumDate = maximumDate
        }
    }
    
}
