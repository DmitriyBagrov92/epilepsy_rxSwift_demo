//
//  ReportsViewController.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 16/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ReportsViewController: UITableViewController, ViewControllerProtocol, Identifierable {

    // MARK: ViewControllerProtocol Properties
    
    typealias VM = ReportsViewModel
    
    var viewModel: ReportsViewModel!
    
    private let disposeBag = DisposeBag()
    
    // MARK: IBOutlets - Views
    
    @IBOutlet weak var reportTypeLabel: UILabel!
    
    @IBOutlet weak var reportStartDateLabel: UILabel!
    
    @IBOutlet weak var reportEndDateLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var generateReportButton: UIButton!
    
    @IBOutlet weak var settingsBarButtonItem: UIBarButtonItem!
    
    // MARK: Lyfecircle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = tableView.backgroundColor

        bindUI()
    }

}

private extension ReportsViewController {
    
    func bindUI() {
        viewModel.reportTypeText.drive(reportTypeLabel.rx.text).disposed(by: disposeBag)
        viewModel.reportStartDate.drive(reportStartDateLabel.rx.text).disposed(by: disposeBag)
        viewModel.reportEndDate.drive(reportEndDateLabel.rx.text).disposed(by: disposeBag)
        settingsBarButtonItem.rx.tap.bind(to: viewModel.settingsButtonTap).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.map( { ($0, self.tableView.cellForRow(at: $0)!)} ).bind(to: viewModel.tableViewItemSelection).disposed(by: disposeBag)
        tableView.rx.itemSelected.bind(onNext: {  self.tableView.deselectRow(at: $0, animated: true ) }).disposed(by: disposeBag)
        emailTextField.rx.controlEvent(.editingChanged).withLatestFrom(emailTextField.rx.text).bind(to: viewModel.userEmailInput).disposed(by: disposeBag)
        generateReportButton.rx.tap.bind(to: viewModel.generateReportAction).disposed(by: disposeBag)
    }
    
}
