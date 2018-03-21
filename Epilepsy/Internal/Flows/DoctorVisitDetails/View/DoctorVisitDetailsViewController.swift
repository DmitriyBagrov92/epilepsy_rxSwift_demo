//
//  DoctorVisitDetailsViewController.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 13/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class DoctorVisitDetailsViewController: UITableViewController, ViewControllerProtocol, Identifierable {
    
    // MARK - ViewControllerProtocol Properties
    
    typealias VM = DoctorVisitDetailsViewModel
    
    var viewModel: DoctorVisitDetailsViewModel!
    
    // MARK: IBOutlets - Views
    
    @IBOutlet weak var visitNameTextField: UITextField!
    
    @IBOutlet weak var doctorNameTextField: UITextField!
    
    @IBOutlet weak var visitDateLabel: UILabel!
    
    @IBOutlet weak var visitTimeLabel: UILabel!
    
    @IBOutlet weak var visitNotificationEnabled: UISwitch!
    
    @IBOutlet weak var notificationTimeLabel: UILabel!
    
    @IBOutlet weak var saveVisitButton: UIButton!
    
    @IBOutlet weak var removeVisitButton: UIButton!
    
    // MARK: Private Properties
    
    private var customeCellHeights: [IndexPath: CGFloat] = [:]
    
    private let disposeBag = DisposeBag()
    
    // MARK - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if customeCellHeights.keys.contains(indexPath) {
            return customeCellHeights[indexPath]!
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
}

private extension DoctorVisitDetailsViewController {
    
    func bindUI() {
        viewModel.viewTitle.drive(self.rx.title).disposed(by: disposeBag)
        
        viewModel.tableItemsCustomHeight.drive(onNext: { [unowned self] (customCellHeights) in
            self.customeCellHeights = customCellHeights
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.map({ (self.tableView, $0) }).bind(to: viewModel.tableItemSelection).disposed(by: disposeBag)
        tableView.rx.itemSelected.bind(onNext: { self.tableView.deselectRow(at: $0, animated: true) }).disposed(by: disposeBag)
        
        visitNameTextField.rx.controlEvent(.editingChanged).withLatestFrom(visitNameTextField.rx.text).bind(to: viewModel.visitNameInput).disposed(by: disposeBag)
        viewModel.visitName.drive(visitNameTextField.rx.text).disposed(by: disposeBag)
        
        doctorNameTextField.rx.controlEvent(.editingChanged).withLatestFrom(doctorNameTextField.rx.text).bind(to: viewModel.doctorNameInput).disposed(by: disposeBag)
        viewModel.doctorName.drive(doctorNameTextField.rx.text).disposed(by: disposeBag)
        
        viewModel.visitDate.drive(visitDateLabel.rx.text).disposed(by: disposeBag)
        viewModel.visitTime.drive(visitTimeLabel.rx.text).disposed(by: disposeBag)
        
        visitNotificationEnabled.rx.controlEvent(.valueChanged).withLatestFrom(visitNotificationEnabled.rx.isOn).bind(to: viewModel.notificationEnableInput).disposed(by: disposeBag)
        viewModel.notificationEnabled.drive(visitNotificationEnabled.rx.isOn).disposed(by: disposeBag)
        
        viewModel.notificationTime.drive(notificationTimeLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.saveButtonTitle.drive(saveVisitButton.rx.title()).disposed(by: disposeBag)
        
        saveVisitButton.rx.tap.bind(to: viewModel.saveButtonTap).disposed(by: disposeBag)
        removeVisitButton.rx.tap.bind(to: viewModel.removeButtonTap).disposed(by: disposeBag)
    }
    
}
