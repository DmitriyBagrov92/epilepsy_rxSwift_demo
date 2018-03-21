//
//  AppCoordinator.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 16/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Swinject
import UIKit

class AppCoordinator: CoordinatorProtocol {
    
    // MARK: Public Properties
    
    var backupService: BackupService? {
        return container.resolve(BackupService.self)
    }
    
    // MARK: Private Properties
    
    private let container = Container()
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle
    
    init() {
        setupDependencies()
    }
    
    // MARK: CoordinatorProtocol Methods
    
    func start(from viewController: UIViewController) -> Observable<Void> {
        viewController.rx.viewDidAppear.bind(onNext: { [unowned self] () in
            let termsService = self.container.resolve(TermsOfUseService.self)!
            let tutorialService = self.container.resolve(TutorialService.self)!
            let settingsService = self.container.resolve(SettingService.self)!
            
            Observable.combineLatest(termsService.isTermsOfUseAccepted, tutorialService.isTutorialPassed, settingsService.isAboutUserSkipped).bind(onNext: { (isTermsAccepted, isTutorialPassed, userBirthdatePassed) in
                if isTermsAccepted == false {
                    self.coordinateToTermsOfUse(from: viewController)
                } else if isTutorialPassed == false {
                    self.coordinateToTutorial(from: viewController)
                } else if userBirthdatePassed == false {
                    self.coordinateToAboutUser(from: viewController)
                } else {
                    self.coordinateToTabBar(from: viewController)
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        return Observable.never()
    }
    
    func coordinate(to coordinator: CoordinatorProtocol, from viewController: UIViewController) -> Observable<Void> {
        return coordinator.start(from: viewController)
    }
    
}

// MARK: Private Methods

private extension AppCoordinator {
    
    func setupDependencies() {
        container.register(TermsOfUseService.self, factory: { _ in return TermsOfUseService() })
        container.register(TutorialService.self, factory: { _ in return TutorialService() })
        container.register(NotificationsService.self, factory: { _ in return NotificationsService() })
        container.register(BackupService.self, factory: { _ in return BackupService() })
        container.register(SettingService.self, factory: { _ in return SettingService() })
        container.register(TermsOfUserCoordinator.self, factory: { r in
            return TermsOfUserCoordinator(termsService: r.resolve(TermsOfUseService.self)!)
        })
        container.register(TutorialCoordinator.self, factory: { r in
            return TutorialCoordinator(tutorialService: r.resolve(TutorialService.self)!)
        })
        container.register(TabBarCoordinator.self, factory: { r in
            return TabBarCoordinator(notificationsService: r.resolve(NotificationsService.self)!, backupService: r.resolve(BackupService.self)!)
        })
        container.register(AboutUserCoordinator.self, factory: { r in
            return AboutUserCoordinator(settingService: r.resolve(SettingService.self)!)
        })
    }
    
    func coordinateToTabBar(from viewController: UIViewController) {
        let _ = self.coordinate(to: self.container.resolve(TabBarCoordinator.self)!, from: viewController)
    }
    
    func coordinateToTermsOfUse(from viewController: UIViewController) {
        let _ = self.coordinate(to: self.container.resolve(TermsOfUserCoordinator.self)!, from: viewController)
    }
    
    func coordinateToTutorial(from viewController: UIViewController) {
        let _ = self.coordinate(to: self.container.resolve(TutorialCoordinator.self)!, from: viewController)
    }
    
    func coordinateToAboutUser(from viewController: UIViewController) {
        let dismiss = self.coordinate(to: self.container.resolve(AboutUserCoordinator.self)!, from: viewController)
        dismiss.bind(onNext: { () in
            viewController.presentedViewController?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
}
