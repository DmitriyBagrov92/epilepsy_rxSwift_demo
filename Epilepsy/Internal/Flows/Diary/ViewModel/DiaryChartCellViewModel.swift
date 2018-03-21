//
//  DiaryChartCellViewModel.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 07/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import CoreGraphics
import SwiftDate
import RealmSwift

class DiaryChartCellViewModel: ViewModelProtocol {
    
    // MARK - Public Properties: Output
    
    let cursorTrailingOffset: Driver<CGFloat>
    
    let fitsChartIcons: Driver<[(UIImage, CGPoint)]>
    
    let drugsChartIcons: Driver<[(UIImage, CGPoint)]>
    
    let visitsChartIcons: Driver<[(UIImage, CGPoint)]>
    
    // MARK: Private Properties
    
    // MARK - Lifecycle
    
    init(currentDate: Date, item: (Results<Drug>, Results<Fit>, Results<DoctorVisit>)) {
        let kChartWidth = 1153
        let secondsInDay = 60 * 60 * 24
        
        let cursorDiff = currentDate - currentDate.startOfDay
        
        let _cursorTrailingOffset = -kChartWidth * (secondsInDay - Int(cursorDiff)) / secondsInDay
        self.cursorTrailingOffset = Observable.of(_cursorTrailingOffset.f + 4.f).asDriver(onErrorJustReturn: 0.f)
        
        let fits = Array(item.1).map { (fit) -> (UIImage, CGPoint) in
            let fitPositionDiff = fit.fitDate - currentDate.startOfDay
            let positionX = (Int(fitPositionDiff) * kChartWidth) / secondsInDay
            let icon = #imageLiteral(resourceName: "attack-journal")
            return (icon, CGPoint(x: positionX, y: 0))
        }
        
        self.fitsChartIcons = Observable.of(fits).asDriver(onErrorJustReturn: [])
        
        let drugMedications = Array(item.0).flatMap({ $0.medications }).map { (medication) -> (UIImage, CGPoint) in
            let useDate = medication.useDate(with: currentDate)!
            let using = medication[useDate]
            let medicationTimeDiff = useDate - currentDate.startOfDay
            let medicationPosX = (Int(medicationTimeDiff) * kChartWidth) / secondsInDay
            return (using.icon, CGPoint(x: medicationPosX, y: 0))
        }
        
        self.drugsChartIcons = Observable.of(drugMedications).asDriver(onErrorJustReturn: [])
        
        let doctorVisits = Array(item.2).map { (visit) -> (UIImage, CGPoint) in
            let visitPositionDiff = visit.visitDate - currentDate.startOfDay
            let positionX = (Int(visitPositionDiff) * kChartWidth) / secondsInDay
            let icon = visit.icon(by: visit.visitDate, currentDate: currentDate)
            return (icon, CGPoint(x: positionX, y: 0))
        }
        
        self.visitsChartIcons = Observable.of(doctorVisits).asDriver(onErrorJustReturn: [])
    }
    
}

extension DoctorVisit {

    func icon(by useDate: Date, currentDate: Date) -> UIImage {
        if useDate > currentDate {
            return #imageLiteral(resourceName: "doctor-journal-future")
        } else if isDone {
            return #imageLiteral(resourceName: "doctor-journal")
        } else {
            return #imageLiteral(resourceName: "doctor-journal-missed")
        }
    }

}
