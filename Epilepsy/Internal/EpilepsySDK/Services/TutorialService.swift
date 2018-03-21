//
//  TutorialService.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 19/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift

class TutorialService {

    // MARK: Public Properties - Input
    
    let tutorialPassing: AnyObserver<Bool>

    // MARK: Public Properties - Output
    
    var content: Observable<[TutorialContent]>!
    
    let isTutorialPassed: Observable<Bool>
    
    // MARK: Private Properties
    
    private let storage = UserDefaults.standard
    
    private let kTutorialPassed = "kTutorialPassed"
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle

    init() {
        let _tutorialPassing = BehaviorSubject<Bool>(value: storage.bool(forKey: kTutorialPassed))
        self.tutorialPassing = _tutorialPassing.asObserver()
        self.isTutorialPassed = _tutorialPassing.asObservable()
        
        _tutorialPassing.bind(onNext: { self.storage.set($0, forKey: self.kTutorialPassed) }).disposed(by: self.disposeBag)
    
        let _content = BehaviorSubject<[TutorialContent]>(value: try! contentFormPlist())
        self.content = _content.asObservable()
    }
}

private extension TutorialService {

    func contentFormPlist() throws -> [TutorialContent] {
        if let path = Bundle.main.path(forResource: "TutorialContent", ofType: "plist"), let dict = NSArray(contentsOfFile: path) {
            let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            return try JSONDecoder().decode([TutorialContent].self, from: data)
        } else {
            throw EPError.Internal("Missed file with TutorialContent")
        }
    }

}
