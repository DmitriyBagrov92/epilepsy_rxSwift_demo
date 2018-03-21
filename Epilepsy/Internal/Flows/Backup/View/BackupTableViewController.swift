//
//  BackupTableViewController.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 19/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import CoreGraphics
import RxCocoa
import RxSwift

class BackupTableViewController: UITableViewController, ViewControllerProtocol, Identifierable {

    // MARK - ViewControllerProtocol Properties
    
    typealias VM = BackupViewModel
    
    var viewModel: BackupViewModel!
    
    // MARK: IBOutlets - Views
    
    @IBOutlet weak var iCloudBackupEnableSwitch: UISwitch!
    
    @IBOutlet weak var emailBackupSentSwitch: UISwitch!
    
    @IBOutlet weak var emailValueLabel: UILabel!
    
    @IBOutlet weak var iCloudBackupIntervalLabel: UILabel!
    
    @IBOutlet weak var emailBackupIntervalLabel: UILabel!
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    private var customCellHeights: [IndexPath: CGFloat] = [:]
    
    private var sectionFooters: [Int: String] = [:]

    // MARK - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
    }
    
    // MARK - UITableView Delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cusotmHeight = customCellHeights[indexPath] {
            return cusotmHeight
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let footerText = sectionFooters[section] {
            return footerText
        } else {
            return super.tableView(tableView, titleForFooterInSection: section)
        }
    }
    
}

private extension BackupTableViewController {
    
    func bindUI() {
        tableView.rx.itemSelected.map({ ($0, self.tableView) }).bind(to: viewModel.tableViewCellSelection).disposed(by: disposeBag)
        tableView.rx.itemSelected.bind(onNext: { self.tableView.deselectRow(at: $0, animated: true) }).disposed(by: disposeBag)
    
        iCloudBackupEnableSwitch.rx.controlEvent(.valueChanged).withLatestFrom(iCloudBackupEnableSwitch.rx.isOn).bind(to: viewModel.enableICloudBackupSentSwitch).disposed(by: disposeBag)
        viewModel.isICloudBackupEnabled.drive(iCloudBackupEnableSwitch.rx.isOn).disposed(by: disposeBag)
    
        viewModel.iCloudBackupInterval.drive(iCloudBackupIntervalLabel.rx.text).disposed(by: disposeBag)
        
        emailBackupSentSwitch.rx.controlEvent(.valueChanged).withLatestFrom(emailBackupSentSwitch.rx.isOn).bind(to: viewModel.enableEmailBackupSentSwitch).disposed(by: disposeBag)
        viewModel.isEmailBackupSentEnabled.drive(emailBackupSentSwitch.rx.isOn).disposed(by: disposeBag)
        
        viewModel.emailBackupInterval.drive(emailBackupIntervalLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.customCellHeights.drive(onNext: { self.customCellHeights = $0; self.tableView.reloadData() }).disposed(by: disposeBag)
        
        viewModel.userEmail.drive(emailValueLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.presentAlert.drive(onNext: { self.present($0, animated: true, completion: nil) }).disposed(by: disposeBag)
        
        viewModel.sectionFooters.drive(onNext: { footers in self.sectionFooters = footers; self.tableView.reloadData() }).disposed(by: disposeBag)
    }
    
}
