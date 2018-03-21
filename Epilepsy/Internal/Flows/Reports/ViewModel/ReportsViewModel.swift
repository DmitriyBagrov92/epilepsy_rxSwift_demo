//
//  ReportsViewModel.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 16/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftDate
import UIKit
import ActionSheetPicker_3_0

class ReportsViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Input
    
    let userEmailInput: AnyObserver<String?>
    
    let generateReportAction: AnyObserver<Void>
    
    let tableViewItemSelection: AnyObserver<(IndexPath, UIView)>
    
    let settingsButtonTap: AnyObserver<Void>
    
    // MARK - Public Properties: Output
    
    let reportTypeText: Driver<String>
    
    let reportStartDate: Driver<String>
    
    let reportEndDate: Driver<String>
    
    let presentReportDetails: Driver<ReportDetailsViewModel>
    
    let presentSettings: Driver<Void>
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK - View Controller Lifecycle
    
    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let kMaxReportDaysInterval = 184
        
        let _reportType = BehaviorSubject<ReportType>(value: .daily)
        self.reportTypeText = _reportType.map({ $0.localizedDescription }).asDriver(onErrorJustReturn: "Error")
        
        let _reportStartDate = BehaviorSubject<Date>(value: Date() - 1.month)
        self.reportStartDate = _reportStartDate.map({ dateFormatter.string(from: $0) }).asDriver(onErrorJustReturn: "Error")
        
        let _reportEndDate = BehaviorSubject<Date>(value: Date())
        self.reportEndDate = _reportEndDate.map({ dateFormatter.string(from: $0) }).asDriver(onErrorJustReturn: "Error")
        
        let _userEmail = BehaviorSubject<String?>(value: nil)
        self.userEmailInput = _userEmail.asObserver()
        
        let _generateReport = PublishSubject<Void>()
        self.generateReportAction = _generateReport.asObserver()
        
        let _tableViewItemSelection = PublishSubject<(IndexPath, UIView)>()
        self.tableViewItemSelection = _tableViewItemSelection.asObserver()
        
        let _settingsAction = PublishSubject<Void>()
        self.settingsButtonTap = _settingsAction.asObserver()
        self.presentSettings = _settingsAction.asDriver(onErrorJustReturn: ())
        
        //Business logic
        
        _tableViewItemSelection.filter({ ReportsTableCellType.type(by: $0.0) == .reportType }).withLatestFrom(Observable.combineLatest(_tableViewItemSelection, _reportType)).bind(onNext: { tableSelection, previousType in
            let stringPicker = ActionSheetStringPicker(title: "",
                                                       rows: ReportType.cases().map({ $0.localizedDescription }),
                                                       initialSelection: previousType.rawValue,
                                                       doneBlock: { (picker, select, origin) in
                                                        _reportType.onNext(ReportType(rawValue: select)!)
            },
                                                       cancel: { (picker) in
            }, origin: tableSelection.1)
            stringPicker?.toolbarButtonsColor = UIColor.EPColors.purple
            stringPicker?.show()
        }).disposed(by: disposeBag)
        
        _tableViewItemSelection.filter({ ReportsTableCellType.type(by: $0.0) == .startDate }).withLatestFrom(Observable.combineLatest(_tableViewItemSelection, _reportEndDate, _reportStartDate)).bind(onNext: { tableSelection, endDate, startDate in
            let datePicker = ActionSheetDatePicker(title: "",
                                                   datePickerMode: .date,
                                                   selectedDate: startDate,
                                                   doneBlock: { (picker, selectedDate, origin) in
                                                    _reportStartDate.onNext(selectedDate as! Date)
            }, cancel: { (picker) in
            }, origin: tableSelection.1)
            datePicker?.minimumDate = endDate - kMaxReportDaysInterval.day
            datePicker?.maximumDate = endDate - 1.day
            datePicker?.toolbarButtonsColor = UIColor.EPColors.purple
            datePicker?.show()
        }).disposed(by: disposeBag)
        
        _tableViewItemSelection.filter({ ReportsTableCellType.type(by: $0.0) == .endDate }).withLatestFrom(Observable.combineLatest(_tableViewItemSelection, _reportEndDate, _reportStartDate)).bind(onNext: { tableSelection, endDate, startDate in
            let datePicker = ActionSheetDatePicker(title: "",
                                                   datePickerMode: .date,
                                                   selectedDate: endDate,
                                                   doneBlock: { (picker, selectedDate, origin) in
                                                    _reportEndDate.onNext(selectedDate as! Date)
            }, cancel: { (picker) in
            }, origin: tableSelection.1)
            datePicker?.minimumDate = startDate + 1.day
            datePicker?.maximumDate = Date()
            datePicker?.toolbarButtonsColor = UIColor.EPColors.purple
            datePicker?.show()
        }).disposed(by: disposeBag)
        
        self.presentReportDetails = _generateReport.withLatestFrom(Observable.combineLatest(_reportStartDate, _reportEndDate, _reportType, _userEmail)).map({ ReportDetailsViewModel(from: $0.0, to: $0.1, type: $0.2, email: $0.3) }).asDriver(onErrorJustReturn: ReportDetailsViewModel(from: Date(), to: Date()-1.day, type: .daily, email: nil))
    }
    
}

enum ReportType: Int, EnumCollection {
    case daily = 0
    case weekly
    
    var localizedDescription: String {
        switch self {
        case .daily:
            return NSLocalizedString("За период по дням", comment: "")
        case .weekly:
            return NSLocalizedString("За период по неделям", comment: "")
        }
    }
    
    var timeInterval: Double {
        switch self {
        case .daily:
            return 60 * 60 * 24
        case .weekly:
            return 60 * 60 * 24 * 7
        }
    }
}

enum ReportsTableCellType {
    case reportType
    case startDate
    case endDate
    
    static func type(by indexPath: IndexPath) -> ReportsTableCellType? {
        if indexPath.section == 0, indexPath.row == 0 {
            return .reportType
        } else if indexPath.section == 0, indexPath.row == 1 {
            return .startDate
        } else if indexPath.section == 0, indexPath.row == 2 {
            return .endDate
        } else {
            return nil
        }
    }
    
}
