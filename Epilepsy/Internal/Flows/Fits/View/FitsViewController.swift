//
//  FitsViewController.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 16/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class FitsViewController: UIViewController, ViewControllerProtocol, Identifierable {
    
    // MARK: ViewControllerProtocol Properties
    
    typealias VM = FitsViewModel
    
    var viewModel: FitsViewModel!
    
    // MARK: - IBOutlets: Views
    
    @IBOutlet weak var createFitButton: UIButton!
    
    @IBOutlet weak var settingsBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: IBOutlets - Constraints
    
    @IBOutlet weak var createFitGradientHeightConstraint: NSLayoutConstraint!
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
        
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, createFitGradientHeightConstraint.constant, 0)
    }
    
}

private extension FitsViewController {
    
    func bindUI() {
        createFitButton.rx.tap.bind(to: viewModel.createFitAction).disposed(by: disposeBag)
        settingsBarButtonItem.rx.tap.bind(to: viewModel.settingsAction).disposed(by: disposeBag)
        
        let dataSource = RxTableViewSectionedReloadDataSource<FitsSection>(configureCell: { (_, tv, ip, viewModel) -> UITableViewCell in
            if let viewModel = viewModel as? FitCellViewModel {
                let cell = tv.dequeueReusableCell(withIdentifier: FitTableViewCell.identifier) as! FitTableViewCell
                cell.bind(with: viewModel)
                return cell
            } else {
                let cell = tv.dequeueReusableCell(withIdentifier: FitsEmptyTableViewCell.identifier) as! FitsEmptyTableViewCell
                return cell
            }
        }, titleForHeaderInSection: { ds, index in
            return ds.sectionModels[index].title
        })
        
        tableView.rx.modelSelected(Any.self).filter({ $0 is FitCellViewModel }).map({ $0 as! FitCellViewModel }).bind(to: viewModel.fitCellSelection).disposed(by: disposeBag)
        tableView.rx.itemSelected.bind(onNext: { self.tableView.deselectRow(at: $0, animated: true) }).disposed(by: disposeBag)
        
        viewModel.fitSections.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
}
