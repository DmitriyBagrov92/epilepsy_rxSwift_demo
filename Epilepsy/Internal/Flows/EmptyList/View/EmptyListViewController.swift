//
//  EmptyListViewController.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 03/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EmptyListViewController: UIViewController, ViewControllerProtocol, Identifierable {

    // MARK - ViewControllerProtocol Properties

    typealias VM = EmptyListViewModel
    
    var viewModel: EmptyListViewModel!
    
    // MARK: IBOutlets - Views
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        bindUI()
    }
    
    // MARK - Public Methods

    class func instance(with viewModel: EmptyListViewModel) -> EmptyListViewController {
        let vc = EmptyListViewController(nibName: EmptyListViewController.identifier, bundle: nil)
        vc.viewModel = viewModel
        return vc
    }
    
}

private extension EmptyListViewController {

    func bindUI() {
        viewModel.descriptionText.drive(descriptionLabel.rx.text).disposed(by: disposeBag)
        viewModel.actionButtonText.drive(actionButton.rx.title()).disposed(by: disposeBag)
        viewModel.iconImage.drive(icon.rx.image).disposed(by: disposeBag)
        viewModel.actionButtonIsHidden.drive(actionButton.rx.isHidden).disposed(by: disposeBag)
        
        actionButton.rx.tap.bind(to: viewModel.actionButtonTap).disposed(by: disposeBag)
    }

}
