//
//  TutorialViewModel.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 19/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class TutorialViewModel: ViewModelProtocol {
    
    // MARK: Public Properties - Input
    
    let nextScreenAction: AnyObserver<Void>
    
    let skipTutorialAction: AnyObserver<Void>
    
    let currentPageChanged: AnyObserver<Int>
    
    // MARK: Public Properties - Outputs
    
    let contentViewControllers: Observable<[TutorialContentViewController]>
    
    let scrollToNextContent: Observable<Void>
    
    let currentPageIndex: Driver<Int>
    
    let nextScreenButtonTitle: Driver<String>
    
    let viewBackgroundColor: Driver<UIColor>
    
    let dismissView: Observable<Void>
    
    // MARK: Private Properties
    
    private let tutorialService: TutorialService
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle
    
    init(tutorialService: TutorialService) {
        self.tutorialService = tutorialService
        
        let _nextScreenAction = PublishSubject<Void>()
        self.nextScreenAction = _nextScreenAction.asObserver()
        
        let _scrollToNext = PublishSubject<Void>()
        self.scrollToNextContent = _scrollToNext.asObservable()
        
        let _skipTutorialAction = PublishSubject<Void>()
        self.skipTutorialAction = _skipTutorialAction.asObserver()
        self.dismissView = _skipTutorialAction.asObservable()
        
        let _currentPage = BehaviorSubject<Int>(value: 0)
        self.currentPageChanged = _currentPage.asObserver()
        self.currentPageIndex = _currentPage.asDriver(onErrorJustReturn: 0)
        
        let _viewBackgroundColor = PublishSubject<UIColor>()
        self.viewBackgroundColor = _viewBackgroundColor.asDriver(onErrorJustReturn: UIColor.red)
        tutorialService.content.map({ $0.first!.color}).bind(to: _viewBackgroundColor).disposed(by: disposeBag)
        
        let _nextScreenButtonTitle = BehaviorSubject<String>(value: NSLocalizedString("Дальше", comment: ""))
        self.nextScreenButtonTitle = _nextScreenButtonTitle.asDriver(onErrorJustReturn: "Error")
        
        self.contentViewControllers = tutorialService.content.map({ $0.map({ (content) -> TutorialContentViewController in
            let viewModel = TutorialContentViewModel(content: content)
            let viewController = UIStoryboard(name: TutorialViewController.identifier, bundle: nil).instantiateViewController(withIdentifier: TutorialContentViewController.identifier) as! TutorialContentViewController
            viewController.viewModel = viewModel
            return viewController
        }) })
        
        _nextScreenAction.withLatestFrom(Observable.combineLatest(_currentPage, tutorialService.content)).bind(onNext: { (index, content) in
            if index < content.count - 1 {
                _scrollToNext.onNext(())
            } else {
                _skipTutorialAction.onNext(())
            }
        }).disposed(by: disposeBag)
        
        _currentPage.withLatestFrom(Observable.combineLatest(_currentPage, tutorialService.content)).bind(onNext: { (index, content) in
            if index == content.count - 1 {
                _nextScreenButtonTitle.onNext(NSLocalizedString("Начать ЭпиДень", comment: ""))
            } else {
                _nextScreenButtonTitle.onNext(NSLocalizedString("Дальше", comment: ""))
            }
            _viewBackgroundColor.onNext(content[index].color)
        }).disposed(by: disposeBag)
        
        _skipTutorialAction.map({ return true }).bind(to: tutorialService.tutorialPassing).disposed(by: disposeBag)
    }
    
}
