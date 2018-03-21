//
//  DiaryCalendarViewController.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 07/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import CVCalendar
import RealmSwift
import SwiftDate

class DiaryCalendarViewController: UIViewController, ViewControllerProtocol, Identifierable {
    
    // MARK - ViewControllerProtocol Properties
    
    typealias VM = DiaryCalendarViewModel
    
    var viewModel: DiaryCalendarViewModel!
    
    // MARK: IBOutlets - Views
    
    @IBOutlet weak var calendarMenuView: CVCalendarMenuView!
    
    @IBOutlet weak var calendarView: CVCalendarView?
    
    @IBOutlet weak var todayBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var calendarHeaderLabel: UILabel!
    
    @IBOutlet weak var calendarDayLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: IBOutlets - Constraints
    
    @IBOutlet weak var calendarViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: Private Properties
    
    private var selectedDate = Date()
    
//    private var dataSource: RxTableViewSectionedReloadDataSource<DiaryTableSection>!
    
    private let kTableOffsetWithoutCalendar = 95.f
    
    private let kCalendarMinHeight = 44.f
    
    private let kCalendarMaxHeight = 240.f
    
    private var calendarDots: [Date: [UIColor]] = [:]
    
    private let disposeBag = DisposeBag()
    
    // MARK - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.calendarMenuView.commitMenuViewUpdate()
        self.calendarView?.commitCalendarViewUpdate()
        self.updateTableViewInsets()
    }
    
    
}

extension DiaryCalendarViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        let section = dataSource.sectionModels[section]
//        switch section.type {
//        case .chart:
//            return 0.f
//        default:
            return 68.f
//        }
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let section = dataSource.sectionModels[section]
//        let cell = tableView.dequeueReusableCell(withIdentifier: DiarySectionHeaderTableViewCell.identifier) as! DiarySectionHeaderTableViewCell
//        cell.bind(with: DiarySectionHeaderViewModel(type: section.type))
//        return cell
//    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if -scrollView.contentOffset.y >= kCalendarMinHeight*2 + kTableOffsetWithoutCalendar {
//            calendarView?.changeMode(.monthView)
//        } else if -scrollView.contentOffset.y <= kCalendarMaxHeight/2 + kTableOffsetWithoutCalendar {
//            calendarView?.changeMode(.weekView)
//        }
//        view.layoutIfNeeded()
//        updateTableViewInsets()
//    }
    
}

private extension DiaryCalendarViewController {
    
    func bindUI() {
        viewModel.selectedDate.drive(onNext: { (date) in
            self.calendarView?.toggleViewWithDate(date)
        }).disposed(by: disposeBag)
        
//        self.dataSource = RxTableViewSectionedReloadDataSource<DiaryTableSection>(configureCell: { (ds, tv, ip, item) -> UITableViewCell in
//            let section = ds.sectionModels[ip.section]
//            if let item = item {
//                switch section.type {
//                case .drugs:
//                    let cell = tv.dequeueReusableCell(withIdentifier: DiaryDrugTableViewCell.identifier) as! DiaryDrugTableViewCell
//                    cell.bind(with: DiaryDrugCellViewModel(drug: item as! Drug, currentDate: section.date))
//                    return cell
//                case .fits:
//                    let cell = tv.dequeueReusableCell(withIdentifier: DiaryFitTableViewCell.identifier) as! DiaryFitTableViewCell
//                    cell.bind(with: DiaryFitCellViewModel(fit: item as! Fit))
//                    return cell
//                case .doctorVisits:
//                    let cell = tv.dequeueReusableCell(withIdentifier: DiaryDoctorVisitTableViewCell.identifier) as! DiaryDoctorVisitTableViewCell
//                    cell.bind(with: DiaryDoctorVisitViewModel(visit: item as! DoctorVisit))
//                    return cell
//                default:
//                    return UITableViewCell()
//                }
//            } else {
//                let cell = tv.dequeueReusableCell(withIdentifier: DiaryEmptyTableViewCell.identifier) as! DiaryEmptyTableViewCell
//                cell.bind(with: DiaryEmptyCellViewModel(type: section.type))
//                return cell
//            }
//        })
//
//        viewModel.tableSections.drive(tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        todayBarButtonItem.rx.tap.bind(to: viewModel.todayButtonTap).disposed(by: disposeBag)
        viewModel.calendarHeaderText.drive(calendarHeaderLabel.rx.text).disposed(by: disposeBag)
        viewModel.calendarDayText.drive(calendarDayLabel.rx.text).disposed(by: disposeBag)
        viewModel.calendarDots.drive(onNext: { (dots) in
            self.calendarDots = dots
            self.calendarView?.contentController.refreshPresentedMonth()
        }).disposed(by: disposeBag)
    }
    
    func updateTableViewInsets() {
        tableView.contentInset = UIEdgeInsets(top: kTableOffsetWithoutCalendar + calendarViewHeightConstraint.constant, left: 0, bottom: 0, right: 0)
    }
    
}

extension DiaryCalendarViewController: CVCalendarMenuViewDelegate {
    
    func dayOfWeekTextColor(by weekday: Weekday) -> UIColor {
        switch weekday {
        case .saturday, .sunday:
            return UIColor.lightGray
        default:
            return UIColor.black
        }
    }
    
    func dayOfWeekBackGroundColor() -> UIColor {
        return UIColor.clear
    }
    
    func dayOfWeekTextUppercase() -> Bool {
        return false
    }
    
    func dayOfWeekFont() -> UIFont {
        return UIFont.systemFont(ofSize: 15.f)
    }
    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .veryShort
    }
    
    func didShowPreviousMonthView(_ date: Date) {
        viewModel.calendarDateInterval.onNext((date.startOf(component: .month) - 2.month, date.endOf(component: .month) + 2.month))
    }
    
    func didShowNextMonthView(_ date: Date) {
        viewModel.calendarDateInterval.onNext((date.startOf(component: .month) - 2.month, date.endOf(component: .month) + 2.month))
    }
    
}

extension DiaryCalendarViewController: CVCalendarViewDelegate {
    
    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    func firstWeekday() -> Weekday {
        return .monday
    }
    
    func presentedDateUpdated(_ date: CVDate) {
        viewModel.changeDate.onNext(date.convertedDate()!)
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        return true
    }
    
    func shouldSelectRange() -> Bool {
        return false
    }
    
    func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool {
        return dayView.isOut == false
    }
    
    func dotMarker(moveOffsetOnDayView dayView: DayView) -> CGFloat {
        return 16.f
    }
    
    func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
        if let dots = calendarDots[dayView.date.convertedDate()!.startOfDay] {
            return Array(dots.prefix(3))
        } else {
            return []
        }
    }
    
}

extension DiaryCalendarViewController: CVCalendarViewAppearanceDelegate {
    
    func dayLabelFont(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIFont {
        return UIFont.systemFont(ofSize: 17.f)
    }
    
    func dayLabelPresentWeekdayFont() -> UIFont {
        return UIFont.boldSystemFont(ofSize: 17.f)
    }
    
    func dayLabelPresentWeekdayTextColor() -> UIColor {
        return UIColor.EPColors.purple
    }
    
    func dayLabelPresentWeekdaySelectedBackgroundColor() -> UIColor {
        return UIColor.EPColors.purple
    }
    
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return UIColor.lightGray
    }
    
}
