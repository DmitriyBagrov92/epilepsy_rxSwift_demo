//
//  FitsViewModel.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 16/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RealmSwift
import RxRealm
import RxDataSources

class FitsViewModel: ViewModelProtocol {
    
    // MARK: Public Properties - Input
    
    let createFitAction: AnyObserver<Void>
    
    let settingsAction: AnyObserver<Void>
        
    let fitCellSelection: AnyObserver<FitCellViewModel>
    
    // MARK: Public Properties - Output
    
    let fitSections: Observable<[FitsSection]>
    
    let presentFitDetails: Driver<Fit>
    
    let presentSettings: Observable<Void>
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle
    
    init() {
        let _createFitAction = PublishSubject<Void>()
        self.createFitAction = _createFitAction.asObserver()
        
        let _presentFitAction = PublishSubject<Fit>()
        self.presentFitDetails = _presentFitAction.asDriver(onErrorJustReturn: Fit())
        
        let _settingsAction = PublishSubject<Void>()
        self.settingsAction = _settingsAction.asObserver()
        self.presentSettings = _settingsAction.asObservable()
        
        let _fitSelection = PublishSubject<FitCellViewModel>()
        self.fitCellSelection = _fitSelection.asObserver()
        
        let realm = try! Realm()
        
        self.fitSections = Observable.changeset(from: realm.objects(Fit.self).sorted(byKeyPath: "fitDate", ascending: false)).map { (result, changes) -> [FitsSection] in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy"
            var sections = result.toArray().grouped(by: { dateFormatter.string(from: $0.fitDate) }).sorted(by: { $0.1.first!.fitDate > $1.1.first!.fitDate }).map({ FitsSection(title: $0.key, items: $0.value.map({ FitCellViewModel(fit: $0) })) })
            if sections.contains(where: { $0.title == dateFormatter.string(from: Date())}) {
                return sections
            } else {
                sections.insert(FitsSection(title: NSLocalizedString("Сегодня", comment: ""), items: [FitsEmptyViewModel()]), at: 0)
                return sections
            }
        }
        
        _fitSelection.map({ $0.fit }).bind(to: _presentFitAction).disposed(by: disposeBag)
        
        _createFitAction.map({ Fit() }).bind(to: _presentFitAction).disposed(by: disposeBag)
    }
    
}

struct FitsSection {
    
    let title: String
    
    var items: [ViewModelProtocol?]
    
}

extension FitsSection: SectionModelType {
    
    typealias Item = ViewModelProtocol?
    
    init(original: FitsSection, items: [Item]) {
        self = original
        self.items = items
    }
    
}
