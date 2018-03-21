//
//  MedicinesViewController.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 16/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class MedicinesViewController: UIViewController, ViewControllerProtocol, Identifierable {
    
    // MARK: ViewControllerProtocol Properties
    
    typealias VM = MedicinesViewModel
    
    var viewModel: MedicinesViewModel!
    
    // MARK: IBOutlets - Views
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var medicinesDateLabel: UILabel!
    
    @IBOutlet weak var previousDateButton: UIButton!
    
    @IBOutlet weak var nextDateButton: UIButton!
    
    @IBOutlet weak var settingsBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var calendarBarButtonItem: UIBarButtonItem!
    
    // MARK: - IBOutlets: Views
    
    @IBOutlet weak var coursesBarButtonItem: UIBarButtonItem!
    
    // MARK: Private Properties
    
    private var dataSource: RxTableViewSectionedReloadDataSource<MedicinesSection>!
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
        
        tableView.tableFooterView = UIView()
    }
    
}

private extension MedicinesViewController {
    
    func bindUI() {
        dataSource = RxTableViewSectionedReloadDataSource<MedicinesSection>(configureCell: { (ds, tv, ip, drug) -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: MedicinesDrugTableViewCell.identifier) as! MedicinesDrugTableViewCell
            let section = ds.sectionModels[ip.section]
            cell.bind(with: MedicinesDrugCellViewModel(section: section, drug: drug))
            return cell
        })
        
        viewModel.tableSections.drive(tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        viewModel.backgroundView.drive(tableView.rx.backgroundView).disposed(by: disposeBag)
        
        previousDateButton.rx.tap.bind(to: viewModel.medicinesPreviousDateAction).disposed(by: disposeBag)
        nextDateButton.rx.tap.bind(to: viewModel.medicinesNextDateAction).disposed(by: disposeBag)
        viewModel.currentDate.drive(medicinesDateLabel.rx.text).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.map({ (self.dataSource.sectionModels[$0.section], self.dataSource[$0] ) }).bind(to: viewModel.medicineItemSelection).disposed(by: disposeBag)
        tableView.rx.itemSelected.bind(onNext: { self.tableView.deselectRow(at: $0, animated: true) }).disposed(by: disposeBag)
        
        coursesBarButtonItem.rx.tap.bind(to: viewModel.coursesButtonTap).disposed(by: disposeBag)
        calendarBarButtonItem.rx.tap.bind(to: viewModel.calendarButtonTap).disposed(by: disposeBag)
        settingsBarButtonItem.rx.tap.bind(to: viewModel.settingsButtonTap).disposed(by: disposeBag)
        
        viewModel.presentAlertActios.drive(onNext: { (name, actions) in
            let alert = UIAlertController(title: NSLocalizedString("Вовремя приняли лекарство?", comment: ""), message: NSLocalizedString(name, comment: ""), preferredStyle: .alert)
            for action in actions {
                alert.addAction(action)
            }
            self.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
}

extension MedicinesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: MedicinesTimeHeaderTableViewCell.identifier) as! MedicinesTimeHeaderTableViewCell
        let viewModel = MedicinesSectionHeaderViewModel(section: dataSource.sectionModels[section])
        cell.bind(with: viewModel)
        viewModel.presentAlert.drive(onNext: { (alert) in
            self.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.f
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48.f
    }
    
}
