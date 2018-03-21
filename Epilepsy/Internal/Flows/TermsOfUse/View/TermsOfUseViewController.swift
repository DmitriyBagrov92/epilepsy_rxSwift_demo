//
//  TermsOfUseViewController.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 17/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TermsOfUseViewController: UIViewController, ViewControllerProtocol, Identifierable {
    
    // MARK: ViewControllerProtocol Properties
    
    typealias VM = TermsOfUserViewModel
    
    var viewModel: TermsOfUserViewModel!
    
    // MARK: - IBOutlets: Views
    
    @IBOutlet weak var agreeButton: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var agreeViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
        configureTextView()
    }
    
}

// MARK: Private Methods

private extension TermsOfUseViewController {
    
    func bindUI() {
        agreeButton.rx.tap.bind(to: viewModel.agreeAction).disposed(by: disposeBag)
        
        viewModel.dismissTermsView.bind(onNext: { () in
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    func configureTextView() {
        textView.contentInset = UIEdgeInsetsMake(0, 0, agreeViewHeightConstraint.constant, 0)
    }
    
}
