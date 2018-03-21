//
//  TutorialContentViewController.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 19/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

class TutorialContentViewController: UIViewController, ViewControllerProtocol, Identifierable {

    // MARK: ViewControllerProtocol Properties

    typealias VM = TutorialContentViewModel
    
    var viewModel: TutorialContentViewModel!
    
    // MARK: - IBOutlets: Views
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var verticalSpaceConstraint: NSLayoutConstraint!
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
    }

}

// MARK: Private Methods

private extension TutorialContentViewController {

    func bindUI() {
        viewModel.image.drive(imageView.rx.image).disposed(by: disposeBag)
        viewModel.title.drive(titleLabel.rx.text).disposed(by: disposeBag)
        viewModel.description.drive(descriptionLabel.rx.text).disposed(by: disposeBag)
        
        if UIScreen.main.bounds.width <= 320 {
            if titleLabel.text == "Добро пожаловать" { self.verticalSpaceConstraint.constant = 80 } else {
                self.verticalSpaceConstraint.constant = 132
            }
            if titleLabel.text == "Прием лекарственных средств" { titleLabel.font =  UIFont.systemFont(ofSize: 30) }
        }
        
    }
}
