//
//  DoctorVisitsViewController.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 16/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class DoctorVisitsViewController: UIViewController, ViewControllerProtocol, Identifierable {
    
    // MARK: ViewControllerProtocol Properties
    
    typealias VM = DoctorVisitsViewModel
    
    var viewModel: DoctorVisitsViewModel!
    
    // MARK: IBOutlets - Views
    
    @IBOutlet weak var addVisitBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var settingsBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
    }
    
}

private extension DoctorVisitsViewController {
    
    func bindUI() {
        viewModel.backgroundView.drive(tableView.rx.backgroundView).disposed(by: disposeBag)
    
        let dataSource = RxTableViewSectionedReloadDataSource<VisitsSection>(configureCell: { (ds, tv, ip, item) -> UITableViewCell in
            if let visitFullViewModel = item as? DoctorVisitFullInfoCellViewModel {
                let cell = tv.dequeueReusableCell(withIdentifier: DoctorVisitFullInfoTableViewCell.identifier) as! DoctorVisitFullInfoTableViewCell
                visitFullViewModel.presentVisit.drive(self.viewModel.editDoctorVisitTap).disposed(by: cell.disposeBag)
                cell.bind(with: visitFullViewModel)
                return cell
            } else if let visitShortViewNodel = item as? DoctorVisitsShortInfoCellViewModel {
                let cell = tv.dequeueReusableCell(withIdentifier: DoctorVisitsShortInfoTableViewCell.identifier) as! DoctorVisitsShortInfoTableViewCell
                cell.bind(with: visitShortViewNodel)
                return cell
            } else {
                return UITableViewCell()
            }
        }, titleForHeaderInSection: { ds, index in
            return ds.sectionModels[index].title
        })
        viewModel.tableSections.drive(tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        settingsBarButtonItem.rx.tap.bind(to: viewModel.settingsButtonTap).disposed(by: disposeBag)
        addVisitBarButtonItem.rx.tap.bind(to: viewModel.addDoctorVisitTap).disposed(by: disposeBag)
    }
    
}
