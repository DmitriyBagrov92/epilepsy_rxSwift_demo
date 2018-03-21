//
//  DiaryViewController.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 16/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RealmSwift

class DiaryViewController: UIViewController, ViewControllerProtocol, Identifierable {
    
    // MARK: ViewControllerProtocol
    
    typealias VM = DiaryViewModel
    
    var viewModel: DiaryViewModel!
    
    // MARK: IBOutlets - Views
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var calendarBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var settingsBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var currentDateLabel: UILabel!
    
    @IBOutlet weak var nextDayButton: UIButton!
    
    @IBOutlet weak var previousDateButton: UIButton!
    
    @IBOutlet weak var healthSlider: UISlider!
    
    @IBOutlet weak var healthValueLabel: UILabel!
    
    @IBOutlet weak var healthValueDescriptionLabel: UILabel!
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
        
    private var dataSource: RxTableViewSectionedReloadDataSource<DiaryTableSection>!
    
    // MARK: Lyfecircle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
    }
    
}

extension DiaryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = dataSource.sectionModels[section]
        switch section.type {
        case .chart:
            return 0.f
        default:
            return 68.f
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = dataSource.sectionModels[section]
        let cell = tableView.dequeueReusableCell(withIdentifier: DiarySectionHeaderTableViewCell.identifier) as! DiarySectionHeaderTableViewCell
        cell.bind(with: DiarySectionHeaderViewModel(type: section.type))
        return cell
    }
    
}

private extension DiaryViewController {
    
    func bindUI() {
        self.dataSource = RxTableViewSectionedReloadDataSource<DiaryTableSection>(configureCell: { (ds, tv, ip, item) -> UITableViewCell in
            let section = ds.sectionModels[ip.section]
            if let item = item {
                switch section.type {
                case .chart:
                    let cell = tv.dequeueReusableCell(withIdentifier: DiaryChartTableViewCell.identifier) as! DiaryChartTableViewCell
                    cell.bind(with: DiaryChartCellViewModel(currentDate: section.date, item: item as! (Results<Drug>, Results<Fit>, Results<DoctorVisit>)))
                    return cell
                case .drugs:
                    let cell = tv.dequeueReusableCell(withIdentifier: DiaryDrugTableViewCell.identifier) as! DiaryDrugTableViewCell
                    cell.bind(with: DiaryDrugCellViewModel(drug: item as! Drug, currentDate: section.date))
                    return cell
                case .fits:
                    let cell = tv.dequeueReusableCell(withIdentifier: DiaryFitTableViewCell.identifier) as! DiaryFitTableViewCell
                    cell.bind(with: DiaryFitCellViewModel(fit: item as! Fit))
                    return cell
                case .doctorVisits:
                    let cell = tv.dequeueReusableCell(withIdentifier: DiaryDoctorVisitTableViewCell.identifier) as! DiaryDoctorVisitTableViewCell
                    cell.bind(with: DiaryDoctorVisitViewModel(visit: item as! DoctorVisit))
                    return cell
                }
            } else {
                let cell = tv.dequeueReusableCell(withIdentifier: DiaryEmptyTableViewCell.identifier) as! DiaryEmptyTableViewCell
                cell.bind(with: DiaryEmptyCellViewModel(type: section.type))
                return cell
            }
        })
        
        viewModel.tableSections.drive(tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Any.self).filter({ $0 is Fit }).map({ $0 as! Fit }).bind(to: viewModel.fitSelected).disposed(by: disposeBag)
        tableView.rx.modelSelected(Any.self).filter({ $0 is Drug }).map({ $0 as! Drug }).bind(to: viewModel.drugSelected).disposed(by: disposeBag)
        tableView.rx.modelSelected(Any.self).filter({ $0 is DoctorVisit }).map({ $0 as! DoctorVisit }).bind(to: viewModel.visitSelected).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.bind(onNext: { self.tableView.deselectRow(at: $0, animated: true) }).disposed(by: disposeBag)

        settingsBarButtonItem.rx.tap.bind(to: viewModel.settingsButtonTap).disposed(by: disposeBag)
        calendarBarButtonItem.rx.tap.bind(to: viewModel.calendarButtonTap).disposed(by: disposeBag)
        
        viewModel.selectedDateText.drive(currentDateLabel.rx.text).disposed(by: disposeBag)
        nextDayButton.rx.tap.bind(to: viewModel.nextDayAction).disposed(by: disposeBag)
        previousDateButton.rx.tap.bind(to: viewModel.previousDayAction).disposed(by: disposeBag)
        
        viewModel.healthValueText.drive(healthValueLabel.rx.text).disposed(by: disposeBag)
        viewModel.healthDescriptionText.drive(healthValueDescriptionLabel.rx.text).disposed(by: disposeBag)
        healthSlider.rx.controlEvent(.valueChanged).withLatestFrom(healthSlider.rx.value).bind(to: viewModel.healthSliderValue).disposed(by: disposeBag)
        healthSlider.rx.controlEvent(.touchUpInside).bind(to: viewModel.healthSliderInputEnd).disposed(by: disposeBag)
        healthSlider.rx.controlEvent(.touchUpOutside).bind(to: viewModel.healthSliderInputEnd).disposed(by: disposeBag)
        viewModel.savedHealthValue.drive(healthSlider.rx.value).disposed(by: disposeBag)
    }
    
}
