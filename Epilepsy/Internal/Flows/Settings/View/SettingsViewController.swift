//
//  SettingsViewController.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 25/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsViewController: UITableViewController, ViewControllerProtocol, Identifierable {
    
    // MARK: ViewControllerProtocol Properties
    
    typealias VM = SettingsViewModel
    
    var viewModel: SettingsViewModel!
    
    // MARK: IBOutlets - Views
    
    @IBOutlet var defaultMedicationDateLabels: [UILabel]!
    
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var dayNotificationEnableSwitch: UISwitch!
    
    @IBOutlet weak var dayNotificationTimeLabel: UILabel!
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
    }
    
}

private extension SettingsViewController {
    
    func bindUI() {
        tableView.rx.itemSelected.map({ ($0, self.tableView) }).bind(to: viewModel.itemSelection).disposed(by: disposeBag)
        tableView.rx.itemSelected.bind(onNext: { self.tableView.deselectRow(at: $0, animated: true) }).disposed(by: disposeBag)
        
        viewModel.medicationDefaultTimes.drive(onNext: { (dates) in
            for i in 0..<dates.count {
                self.defaultMedicationDateLabels[i].text = dates[i]
            }
        }).disposed(by: disposeBag)
        
        dayNotificationEnableSwitch.rx.controlEvent(.valueChanged).withLatestFrom(dayNotificationEnableSwitch.rx.isOn).bind(to: viewModel.dayNotificationEnableAction).disposed(by: disposeBag)
        viewModel.dayNotificationEnabled.drive(dayNotificationEnableSwitch.rx.isOn).disposed(by: disposeBag)
        
        viewModel.dayNotificationTime.drive(dayNotificationTimeLabel.rx.text).disposed(by: disposeBag)
        
        saveBarButtonItem.rx.tap.bind(to: viewModel.saveButtonAction).disposed(by: disposeBag)
        
        viewModel.presentWebTutorial.drive(onNext: { (url) in
            UIApplication.shared.openURL(url)
        }).disposed(by: disposeBag)
    }
        
}
