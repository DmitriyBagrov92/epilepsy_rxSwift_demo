//
//  ReportDetailsViewModel.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 07/03/2018.
//  Copyright © 2018 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import PDFKit
import PDFGenerator
import Charts
import SwiftDate
import RealmSwift
import UIKit
import MessageUI
import SMTPLite

class ReportDetailsViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Input
    
    let userEmailInput: AnyObserver<String?>
    
    let openReportAction: AnyObserver<Void>
    
    let sendReportToEmailAction: AnyObserver<Void>
    
    // MARK - Public Properties: Output
    
    let userEmail: Driver<String?>
    
    let pdfPreviewFilePath: Driver<URL>
    
    let errorAlertPresent: Driver<UIAlertController>
    
    let emailComposerPresent: Driver<MFMailComposeViewController>
    
    // MARK: Private Properties
    
    private let reportType: ReportType
    
    private let startDate: Date
    
    private let endDate: Date
    
    lazy var customFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.negativePrefix = ""
        formatter.positiveSuffix = "ЛС"
        formatter.negativeSuffix = "ПРСТП"
        formatter.minimumSignificantDigits = 1
        formatter.minimumFractionDigits = 1
        return formatter
    }()
    
    private let disposeBag = DisposeBag()
    
    private let kChartItemMultiplier = 50.0
    
    private let dateFormatter: DateFormatter =  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        return dateFormatter
    }()
    
    private let kEpilepsyEmail = "epilepsytest@gmail.com"
    
    private let kEpilepsyEmailPass = "i4ZnL62e"
    
    private let kEpilepsyEmailSMTP = "smtp.gmail.com"
    
    private let kEpilepsyReportName = "report.pdf"
    
    private let _alertPresent: PublishSubject<UIAlertController>
    
    // MARK - View Controller Lifecycle
    
    init(from startDate: Date, to endDate: Date, type: ReportType, email: String?) {
        self.reportType = type
        self.startDate = startDate
        self.endDate = endDate
        
        let _userEmail = BehaviorSubject<String?>(value: email)
        self.userEmail = _userEmail.asDriver(onErrorJustReturn: nil)
        self.userEmailInput = _userEmail.asObserver()
        
        let _openReport = PublishSubject<Void>()
        self.openReportAction = _openReport.asObserver()
        
        let _sendReportToEmail = PublishSubject<Void>()
        self.sendReportToEmailAction = _sendReportToEmail.asObserver()
        
        let _pdfPreviewFilePath = PublishSubject<URL>()
        self.pdfPreviewFilePath = _pdfPreviewFilePath.asDriver(onErrorJustReturn: URL(fileURLWithPath: "error"))
        
        self._alertPresent = PublishSubject<UIAlertController>()
        self.errorAlertPresent = _alertPresent.asDriver(onErrorJustReturn: UIAlertController(title: nil, message: nil, preferredStyle: .alert))
        
        let _emailComposerPresent = PublishSubject<MFMailComposeViewController>()
        self.emailComposerPresent = _emailComposerPresent.asDriver(onErrorJustReturn: MFMailComposeViewController())
        
        self.generateAndSaveReport(from: startDate, to: endDate)
        
        //Business logic
        
        _openReport.bind(onNext: { () in
            let url = NSTemporaryDirectory().appending("report.pdf")
            _pdfPreviewFilePath.onNext(URL(fileURLWithPath: url))
        }).disposed(by: disposeBag)
        
        _sendReportToEmail.withLatestFrom(_userEmail).filter({ $0?.isEmail != true }).map({ (email) -> UIAlertController in
            let alert = UIAlertController(title: NSLocalizedString("Ошибка", comment: ""), message: NSLocalizedString("Введен некорретный e-mail. Пожалуйста повторите попытку снова", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
            return alert
        }).bind(to: _alertPresent).disposed(by: disposeBag)
        
        
        _sendReportToEmail.withLatestFrom(_userEmail).filter({ $0?.isEmail == true }).map({ email -> MFMailComposeViewController in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
        
            let composer = MFMailComposeViewController()
            composer.addAttachmentData(try! Data(contentsOf: URL(fileURLWithPath: NSTemporaryDirectory().appending("report.pdf"))), mimeType: "application/pdf", fileName: "report.pdf")
            composer.setSubject(String(format: NSLocalizedString("Отчет от %@", comment: ""), dateFormatter.string(from: Date())))
            composer.setToRecipients([email!])
            composer.setMessageBody(String(format: NSLocalizedString("Отчет о приеме ЛС и приступов с %@ до %@", comment: ""), dateFormatter.string(from: startDate), dateFormatter.string(from: endDate)), isHTML: false)
            return composer
        }).bind(to: _emailComposerPresent).disposed(by: disposeBag)
    }
    
}

extension ReportDetailsViewModel: ChartViewDelegate {
    
    func generateAndSaveReport(from startDate: Date, to endDate: Date) {
        let interval = reportType.timeInterval
        let intervalsInReport = (endDate - startDate) / interval
        let chartWidth = intervalsInReport * kChartItemMultiplier
        
        let chart = BarChartView(frame: CGRect(x: 0, y: 0, width: chartWidth+500, height: 500))
        
        chart.delegate = self
        
        chart.chartDescription?.enabled = false
        
        chart.drawBarShadowEnabled = false
        chart.drawValueAboveBarEnabled = true
        
        chart.leftAxis.enabled = false
        let rightAxis = chart.rightAxis
        rightAxis.axisMaximum = 25
        rightAxis.axisMinimum = -25
        rightAxis.drawZeroLineEnabled = true
        rightAxis.labelCount = 7
        rightAxis.valueFormatter = self
        rightAxis.labelFont = .systemFont(ofSize: 9)
        
        let xAxis = chart.xAxis
        xAxis.labelPosition = .bothSided
        xAxis.drawAxisLineEnabled = false
        xAxis.axisMinimum = 0
        xAxis.axisMaximum = chartWidth
        xAxis.centerAxisLabelsEnabled = true
        xAxis.setLabelCount(Int(intervalsInReport), force: true)
        xAxis.valueFormatter = self
        xAxis.granularity = 2.0
        xAxis.labelFont = .systemFont(ofSize: 9)
        xAxis.valueFormatter = self
        
        let l = chart.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.formSize = 8
        l.formToTextSpace = 8
        l.xEntrySpace = 6
        
        let fits = try! Realm().objects(Fit.self).filter(NSPredicate(format: "fitDate >= %@ AND fitDate <= %@", NSDate(timeIntervalSince1970: startDate.startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: endDate.endOfDay.timeIntervalSince1970)))
        
        let drugs = try! Realm().objects(Drug.self).filter(NSPredicate(format: "(startData <= %@ AND isDaily = true ) OR (isDaily = false AND endData >= %@ AND startData <= %@)", NSDate(timeIntervalSince1970: startDate.endOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: endDate.startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: startDate.endOfDay.timeIntervalSince1970)))
        
        var chartDays: [BarChartDataEntry] = []
        
        switch reportType {
        case .daily:
            chartDays = stride(from: 0, to: intervalsInReport, by: 1)
                .map { (day) -> BarChartDataEntry in
                    let date = startDate + Int(day).day
                    let drugsInDay = drugs.filter(NSPredicate(format: "(startData <= %@ AND isDaily = true ) OR (isDaily = false AND endData >= %@ AND startData <= %@)", NSDate(timeIntervalSince1970: date.endOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: date.startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: date.endOfDay.timeIntervalSince1970)))
                    var numberOfSuccessfullDrugsInDay = 0
                    for drugInDay in drugsInDay {
                        for medication in drugInDay.medications {
                            if medication.usings.filter({ $0.type != "failed" }).contains(where: { $0.date.isInSameDayOf(date: date) }) {
                                numberOfSuccessfullDrugsInDay += 1
                            }
                        }
                    }
                    let fitsInDay = fits.filter({ (fit) -> Bool in
                        return fit.fitDate.isInSameDayOf(date: date)
                    })
                    let numberOfFitsInDay = -fitsInDay.count
                    return BarChartDataEntry(x: day * kChartItemMultiplier, yValues: [Double(numberOfFitsInDay), Double(numberOfSuccessfullDrugsInDay)])
            }
        case .weekly:
            chartDays = stride(from: 0, to: intervalsInReport, by: 1)
                .map { (week) -> BarChartDataEntry in
                    let date = startDate + Int(week).week
                    let drugsInWeek = drugs.filter(NSPredicate(format: "(startData <= %@ AND isDaily = true ) OR (isDaily = false AND endData >= %@ AND startData <= %@)", NSDate(timeIntervalSince1970: date.endOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: date.startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: date.endOfDay.timeIntervalSince1970)))
                    var numberOfSuccessfullDrugsInWeek = 0
                    for drugInWeek in drugsInWeek {
                        for medication in drugInWeek.medications {
                            if medication.usings.filter({ $0.type != "failed" }).contains(where: { $0.date.isBetween(date: date.startWeek, and: date.endWeek) }) {
                                numberOfSuccessfullDrugsInWeek += 1
                            }
                        }
                    }
                    let fitsInWeek = fits.filter({ (fit) -> Bool in
                        return fit.fitDate.isBetween(date: date.startWeek, and: date.endWeek)
                    })
                    let numberOfFitsInWeek = -fitsInWeek.count
                    return BarChartDataEntry(x: week * kChartItemMultiplier, yValues: [Double(numberOfFitsInWeek), Double(numberOfSuccessfullDrugsInWeek)])
            }
        }
        
        let set = BarChartDataSet(values: chartDays, label: String(format: "ПРИЕМ ЛЕКАРСТВ И ПРУСТУПЫ С ПО ДНЯМ С (%@ - %@)", dateFormatter.string(from: startDate), dateFormatter.string(from: endDate)))
        set.drawIconsEnabled = false
        set.valueFormatter = DefaultValueFormatter(formatter: customFormatter)
        set.valueFont = .systemFont(ofSize: 7)
        set.axisDependency = .right
        set.colors = [UIColor.EPColors.red,
                      UIColor.EPDiaryMedicationState.green
        ]
        set.stackLabels = ["Прием ЛС", "Приступы"]
        
        let data = BarChartData(dataSet: set)
        data.barWidth = 8.5
        
        chart.data = data
        chart.setNeedsDisplay()
        
        //Generate PDF
        
        let chartImage = chart.getChartImage(transparent: false)
        do {
            let path = NSTemporaryDirectory().appending("report.pdf")
            try PDFGenerator.generate(chartImage!, to: path)
        } catch let error {
            print(error)
        }
        
    }
    
    func sendReport(to email: String) {
        let message = SMTPMessage()
        message.from = kEpilepsyEmail
        message.to = email
        message.account = kEpilepsyEmail
        message.pwd = kEpilepsyEmailPass
        message.host = kEpilepsyEmailSMTP
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        message.subject = String(format: NSLocalizedString("Отчет от %@", comment: ""), dateFormatter.string(from: Date()))
        message.content = String(format: NSLocalizedString("Отчет о приеме ЛС и приступов с %@ до %@", comment: ""), dateFormatter.string(from: startDate), dateFormatter.string(from: endDate))
        let backup = SMTPAttachment()
        backup.name = kEpilepsyReportName
        backup.filePath = NSTemporaryDirectory().appending("report.pdf")
        message.attachments = [backup]
        message.send({ (message, now, total) in
            print(now)
        }, success: { [weak self] (message) in
            let alert = UIAlertController(title: NSLocalizedString("Успешно", comment: ""), message: NSLocalizedString("Отчет успешно отправлен на ваш email. Пожалуйста проверьте почту", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self?._alertPresent.onNext(alert)
            }, failure: { [weak self] (message, error) in
                let alert = UIAlertController(title: NSLocalizedString("Ошибка", comment: ""), message: NSLocalizedString("Произошла ошибка отправки отчсета на ваш email. Пожалуйста попробуйте позже", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?._alertPresent.onNext(alert)
        })
    }
    
    // MARK - ChartViewDelegate
    
}

extension ReportDetailsViewModel: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if axis?.granularity ?? 0 > 1, reportType == .daily {
            let date = startDate + Int(value / kChartItemMultiplier).day
            return dateFormatter.string(from: date)
        } else if axis?.granularity ?? 0 > 1, reportType == .weekly {
            let fromDate = startDate + Int(value / kChartItemMultiplier).weeks
            let toDate = startDate + Int(value / kChartItemMultiplier).weeks + 1.week
            return dateFormatter.string(from: fromDate) + " - " + dateFormatter.string(from: toDate)
        } else {
            return value > 0 ? String(format: "%0.0f Приемов ЛС", value) : String(format: "%0.0f Приуступов", abs(value))
        }
    }
    
}

