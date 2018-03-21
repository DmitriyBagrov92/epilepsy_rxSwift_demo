//
//  AboutUserViewController.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 19/03/2018.
//  Copyright © 2018 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class AboutUserViewController: UIViewController, ViewControllerProtocol, Identifierable {
    
    // MARK - ViewControllerProtocol Properties
    
    typealias VM = AboutUserViewModel
    
    var viewModel: AboutUserViewModel!
    
    // MARK: IBOutlets - Views
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var continueButton: UIButton!
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
    }
    
}

private extension AboutUserViewController {
    
    func bindUI() {
        continueButton.rx.tap.bind(to: viewModel.nextButtonAction).disposed(by: disposeBag)
        datePicker.rx.date.bind(to: viewModel.birthDateChanged).disposed(by: disposeBag)
        
        viewModel.pickerMaxDate.drive(datePicker.rx.maximumDate).disposed(by: disposeBag)
    }
    
}
