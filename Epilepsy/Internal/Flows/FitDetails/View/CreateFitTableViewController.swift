//
//  CreateFitTableViewController.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 20/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class CreateFitTableViewController: UIViewController, ViewControllerProtocol, Identifierable {
    
    // MARK: ViewControllerProtocol Properties
    
    typealias VM = FitDetailsViewModel
    
    var viewModel: FitDetailsViewModel!
    
    // MARK: - IBOutlets: Views
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        bindUI()
    }
    
}

private extension CreateFitTableViewController {
    
    func bindUI() {
        let dataSource = RxTableViewSectionedReloadDataSource<FitParamsSection>(configureCell: { [unowned self] (_, tv, ip, param) -> UITableViewCell in
            switch param.type {
            case .fitCreateAction:
                let cell = tv.dequeueReusableCell(withIdentifier: CreateFitActionTableViewCell.identifier) as! CreateFitActionTableViewCell
                cell.bind(with: self.viewModel)
                return cell
            case .fitDescription:
                let cell = tv.dequeueReusableCell(withIdentifier: CreateFitTextInputTableViewCell.identifier) as! CreateFitTextInputTableViewCell
                let viewModel = CreateFitTextInputCellViewModel(param: param)
                viewModel.value.drive(self.viewModel.createFitDescriptionInput).disposed(by: self.disposeBag)
                cell.bind(with: viewModel)
                return cell
            case .fitDeleteAction:
                let cell = tv.dequeueReusableCell(withIdentifier: FitDetailsRemoveTableViewCell.identifier) as! FitDetailsRemoveTableViewCell
                cell.bind(with: self.viewModel)
                return cell
            default:
                let cell = tv.dequeueReusableCell(withIdentifier: CreateFitParamDescriptionTableViewCell.identifier) as! CreateFitParamDescriptionTableViewCell
                cell.bind(with: CreateFitCellViewModel(param: param))
                return cell
            }
            
        }, titleForHeaderInSection: { ds, index in
            return ds.sectionModels[index].title
        })
        
        viewModel.viewTitle.drive(self.rx.title).disposed(by: disposeBag)
        
        viewModel.tableSections.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.map({ (self.tableView, $0, dataSource[$0]) }).bind(to: viewModel.createFitParamTapped).disposed(by: disposeBag)
        
        viewModel.tableViewContentInset.drive(tableView.rx.contentInset).disposed(by: disposeBag)

        viewModel.tableViewItemDeselect.drive(onNext: { self.tableView.deselectRow(at: $0, animated: true) }).disposed(by: disposeBag)
    }
    
}
