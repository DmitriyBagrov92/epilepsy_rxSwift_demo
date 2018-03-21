//
//  MedicineCoursesViewController.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 27/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class MedicineCoursesViewController: UIViewController, Identifierable, ViewControllerProtocol {
    
    // MARK: ViewControllerProtocol Properties
    
    typealias VM = MedicineCoursesViewModel
    
    var viewModel: MedicineCoursesViewModel!
    
    // MARK: IBOutlets - Views
    
    @IBOutlet weak var addCourseBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
    }
    
}

private extension MedicineCoursesViewController {
    
    func bindUI() {
        addCourseBarButtonItem.rx.tap.bind(to: viewModel.createNewCourseTap).disposed(by: disposeBag)
        
        let dataSource = RxTableViewSectionedReloadDataSource<MedicineCourseSection>(configureCell: { (ds, tv, ip, item) -> UITableViewCell in
            switch item.type {
            case .baseInfo:
                let cell = tv.dequeueReusableCell(withIdentifier: MedicineCourseBaseInfoTableViewCell.identifier) as! MedicineCourseBaseInfoTableViewCell
                let cellViewModel = MedicineCourseBaseInfoCellViewModel(drug: item.drug)
                cellViewModel.presentDrugEditing.drive(self.viewModel.editCourseTap).disposed(by: self.disposeBag)
                cell.bind(with: cellViewModel)
                return cell
            case .medicationInfo(let index):
                let cell = tv.dequeueReusableCell(withIdentifier: MedicineCourseMedicationTableViewCell.identifier) as! MedicineCourseMedicationTableViewCell
                cell.bind(with: MedicineCourseMedicationCellViewModel(index: index, drug: item.drug))
                return cell
            case .medicationHistoryTitle:
                return tv.dequeueReusableCell(withIdentifier: MedicineHistoryTitleTableViewCell.identifier)!
            case .medicationHistoryInfo(let index):
                let cell = tv.dequeueReusableCell(withIdentifier: MedicineDozeHistoryTableViewCell.identifier) as! MedicineDozeHistoryTableViewCell
                cell.bind(with: MedicineDozeHistoryCellViewModel(drug: item.drug, index: index))
                return cell
            }
        })
        
        viewModel.tableSections.drive(tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        viewModel.backgroundView.drive(tableView.rx.backgroundView).disposed(by: disposeBag)
    }
    
}
