//
//  MedicineCourseDetailsViewController.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 27/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MedicineCourseDetailsViewController: UITableViewController, Identifierable, ViewControllerProtocol {
    
    // MARK - ViewControllerProtocol Properties
    
    typealias VM = MedicineCourseDetailsViewModel
    
    var viewModel: MedicineCourseDetailsViewModel!
    
    // MARK: IBOutlets - Views
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var mnnTableViewCell: UITableViewCell!
    
    @IBOutlet weak var medicineStartDateCell: UITableViewCell!
    
    @IBOutlet weak var medicineIsDailySwitch: UISwitch!
    
    @IBOutlet weak var medicineEndDateCell: UITableViewCell!
    
    @IBOutlet weak var medicineFormCell: UITableViewCell!
    
    @IBOutlet weak var medicineDozeTextField: UITextField!
    
    @IBOutlet weak var numberOfMedicinesCell: UITableViewCell!
    
    @IBOutlet var medicationDateTimeCells: [UITableViewCell]!
    
    @IBOutlet var medicationNotificationsEnabledSwitch: [UISwitch]!
    
    @IBOutlet var medicationCommentTextFields: [UITextField]!
    
    @IBOutlet weak var saveDrugButton: UIButton!
    
    @IBOutlet weak var removeDrugButton: UIButton!
    
    // MARK: Private Properties
    
    private var isSecondMedicineHidden = true
    
    private var isThirdMedicineHidden = true
    
    private var isRemoveDrugHidden = true
    
    private let secondMedicineIndexPaths = [IndexPath(row: 3, section: 5) : 56.f,
                                            IndexPath(row: 4, section: 5) : 44.f,
                                            IndexPath(row: 5, section: 5) : 44.f,
                                            IndexPath(row: 6, section: 5) : 64.f]
    
    private let thirdMedicineIndexPaths = [IndexPath(row: 7, section: 5) : 56.f,
                                           IndexPath(row: 8, section: 5) : 44.f,
                                           IndexPath(row: 9, section: 5) : 44.f,
                                           IndexPath(row: 10, section: 5) : 64.f]
    
    private let removeDrugIndexPath = [IndexPath(row: 12, section: 5) : 74.f]
    
    private let disposeBag = DisposeBag()
    
    // MARK - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if secondMedicineIndexPaths.keys.contains(indexPath) {
            return isSecondMedicineHidden ? 0.f : secondMedicineIndexPaths[indexPath]!
        } else if thirdMedicineIndexPaths.keys.contains(indexPath) {
            return isThirdMedicineHidden ? 0.f : thirdMedicineIndexPaths[indexPath]!
        } else if removeDrugIndexPath.keys.contains(indexPath) {
            return isRemoveDrugHidden ? 0.f : removeDrugIndexPath[indexPath]!
        }
        return UITableViewAutomaticDimension
    }
    
}

extension MedicineCourseDetailsViewController {
    
    func bindUI() {
        viewModel.viewTitle.drive(self.rx.title).disposed(by: disposeBag)
    
        tableView.rx.itemSelected.map({ (self.tableView, $0) }).bind(to: viewModel.medicineTableItemSelected).disposed(by: disposeBag)
        tableView.rx.itemSelected.bind(onNext: { ip in self.tableView.deselectRow(at: ip, animated: true) }).disposed(by: disposeBag)
        
        viewModel.medicineName.drive(nameTextField.rx.text).disposed(by: disposeBag)
        nameTextField.rx.text.bind(to: viewModel.medicineNameInput).disposed(by: disposeBag)
        
        viewModel.medicineMNN.drive(mnnTableViewCell.detailTextLabel!.rx.text).disposed(by: disposeBag)
        
        medicineIsDailySwitch.rx.controlEvent(.valueChanged).withLatestFrom(medicineIsDailySwitch.rx.isOn).bind(to: viewModel.medicineIsDailyInput).disposed(by: disposeBag)
        viewModel.medicineIsDaily.drive(medicineIsDailySwitch.rx.isOn).disposed(by: disposeBag)
        
        viewModel.medicineStartDate.drive(medicineStartDateCell.detailTextLabel!.rx.text).disposed(by: disposeBag)
        viewModel.medicineEndDate.drive(medicineEndDateCell.detailTextLabel!.rx.text).disposed(by: disposeBag)
        
        viewModel.medicineForm.drive(medicineFormCell.detailTextLabel!.rx.text).disposed(by: disposeBag)
        
        medicineDozeTextField.rx.controlEvent(.editingChanged).withLatestFrom(medicineDozeTextField.rx.text).bind(to: viewModel.medicineDozeInput).disposed(by: disposeBag)
        viewModel.medicineDoze.drive(medicineDozeTextField.rx.text).disposed(by: disposeBag)
        
        viewModel.numberOfMedicines.drive(numberOfMedicinesCell.detailTextLabel!.rx.text).disposed(by: disposeBag)
        
        viewModel.secondMedicationSectionHidden.drive(onNext: { (isHidden) in
            self.isSecondMedicineHidden = isHidden
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.thirdMedicationSectionHidden.drive(onNext: { (isHidden) in
            self.isThirdMedicineHidden = isHidden
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.removeDrugRowIsHidden.drive(onNext: { (isHidden) in
            self.isRemoveDrugHidden = isHidden
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.medicationDateTime.drive(onNext: { (index, time) in
            self.medicationDateTimeCells[index].detailTextLabel?.text = time
        }).disposed(by: disposeBag)
        
        for notificationSwitch in medicationNotificationsEnabledSwitch {
            notificationSwitch.rx.isOn.map({ (self.medicationNotificationsEnabledSwitch.index(of: notificationSwitch)!, $0) }).bind(to: viewModel.medicationNotificationEnableInput).disposed(by: disposeBag)
        }
        
        viewModel.medicationNotificationEnabled.drive(onNext: { (index, isOn) in
            self.medicationNotificationsEnabledSwitch[index].isOn = isOn
        }).disposed(by: disposeBag)
        
        for textField in medicationCommentTextFields {
            textField.rx.text.map({ (self.medicationCommentTextFields.index(of: textField)!, $0) }).bind(to: viewModel.medicationCommentsInput).disposed(by: disposeBag)
        }
        
        viewModel.medicationComments.drive(onNext: { (index, text) in
            self.medicationCommentTextFields[index].text = text
        }).disposed(by: disposeBag)
        
        viewModel.saveDrugTitle.drive(saveDrugButton.rx.title()).disposed(by: disposeBag)
        saveDrugButton.rx.tap.bind(to: viewModel.saveDrugAction).disposed(by: disposeBag)
        
        viewModel.drugValidationError.drive(onNext: { (error) in
            let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
            let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        removeDrugButton.rx.tap.bind(to: viewModel.removeDrugAction).disposed(by: disposeBag)
    }
    
}
