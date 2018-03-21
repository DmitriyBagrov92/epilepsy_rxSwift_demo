//
//  DiaryChartTableViewCell.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 05/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DiaryChartTableViewCell: DisposableTableViewCell {
    
    // MARK: IBOutlets - Views
    
    @IBOutlet weak var chartScrollView: UIScrollView!
    
    @IBOutlet weak var fitsView: UIView!
    
    @IBOutlet weak var drugsView: UIView!
    
    @IBOutlet weak var doctorVisitsView: UIView!
    
    // MARK: IBOutlets - Constraints
    
    @IBOutlet weak var trailingCursorConstraint: NSLayoutConstraint!
    
    // MARK: Private Properties
    
    private var isScrollToCursorRequired = false
    
    private let scrollViewContentWidth = 1183.f
    
    // MARK - Public Methods
    
    func bind(with viewModel: DiaryChartCellViewModel) {
        viewModel.cursorTrailingOffset.drive(trailingCursorConstraint.rx.constant).disposed(by: disposeBag)
        isScrollToCursorRequired = true
        
        viewModel.fitsChartIcons.drive(onNext: { (fits) in
            for subview in self.fitsView.subviews {
                subview.removeFromSuperview()
            }
            for fit in fits {
                let imageView = UIImageView(image: fit.0)
                imageView.frame = CGRect(x: fit.1.x - imageView.bounds.width/2, y: fit.1.y, width: imageView.bounds.width, height: imageView.bounds.height)
                self.fitsView.addSubview(imageView)
            }
        }).disposed(by: disposeBag)
        
        viewModel.drugsChartIcons.drive(onNext: { (drugs) in
            for subview in self.drugsView.subviews {
                subview.removeFromSuperview()
            }
            for drug in drugs {
                let imageView = UIImageView(image: drug.0)
                imageView.frame = CGRect(x: drug.1.x - imageView.bounds.width/2, y: drug.1.y, width: imageView.bounds.width, height: imageView.bounds.height)
                self.drugsView.addSubview(imageView)
            }
        }).disposed(by: disposeBag)
        
        viewModel.visitsChartIcons.drive(onNext: { (visits) in
            for subview in self.doctorVisitsView.subviews {
                subview.removeFromSuperview()
            }
            for visit in visits {
                let imageView = UIImageView(image: visit.0)
                imageView.frame = CGRect(x: visit.1.x - imageView.bounds.width/2, y: visit.1.y - imageView.bounds.height/2, width: imageView.bounds.width, height: imageView.bounds.height)
                self.doctorVisitsView.addSubview(imageView)
            }
        }).disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isScrollToCursorRequired {
            isScrollToCursorRequired = false
            scrollToCursor(animated: true)
        }
    }
    
}

private extension DiaryChartTableViewCell {
    
    func scrollToCursor(animated: Bool) {
        let cursorPositionX = self.scrollViewContentWidth + trailingCursorConstraint.constant
        var contenOffsetX = cursorPositionX - self.bounds.width/2.f - 15.f
        if contenOffsetX < 0 {
            contenOffsetX = 0.f
        } else if contenOffsetX + self.bounds.width > scrollViewContentWidth {
            contenOffsetX = scrollViewContentWidth - self.bounds.width
        }
        chartScrollView.setContentOffset(CGPoint(x: contenOffsetX, y: 0), animated: animated)
    }
    
}
