//
//  TutorialViewController.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 19/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TutorialViewController: UIViewController, ViewControllerProtocol, Identifierable {
    
    // MARK: ViewControllerProtocol Properties
    
    typealias VM = TutorialViewModel
    
    var viewModel: TutorialViewModel!
    
    // MARK: - IBOutlets: Views
    
    @IBOutlet weak var skipButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    private var pageViewController: UIPageViewController?
    
    private var contentControllers: [TutorialContentViewController]!
    
    private var currentContentPageIndex: Int {
        guard let currentVC = pageViewController?.viewControllers?.first as? TutorialContentViewController else { return 0 }
        return contentControllers.index(of: currentVC) ?? 0
    }
    
    // MARK: Lyfecircle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pvc = segue.destination as? UIPageViewController {
            self.pageViewController = pvc
            bindTutorialPages(with: pvc)
            pvc.dataSource = self
            pvc.delegate = self
        }
    }
}

extension TutorialViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return contentControllers[safe: currentContentPageIndex + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return contentControllers[safe: currentContentPageIndex - 1]
    }
    
}

extension TutorialViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            viewModel.currentPageChanged.onNext(currentContentPageIndex)
        }
    }
    
}

// MARK: Private Methods

private extension TutorialViewController {
    
    func bindUI() {
        nextButton.rx.tap.bind(to: viewModel.nextScreenAction).disposed(by: disposeBag)
        skipButton.rx.tap.bind(to: viewModel.skipTutorialAction).disposed(by: disposeBag)
        viewModel.currentPageIndex.drive(pageControl.rx.currentPage).disposed(by: disposeBag)
        viewModel.nextScreenButtonTitle.drive(nextButton.rx.title()).disposed(by: disposeBag)
        
        viewModel.scrollToNextContent.bind(onNext: { _ in
            self.pageViewController?.setViewControllers([self.contentControllers[self.currentContentPageIndex + 1]],
                                                        direction: .forward,
                                                        animated: true, completion: { (finished) in
                                                            self.viewModel.currentPageChanged.onNext(self.currentContentPageIndex)
            })
        }).disposed(by: disposeBag)
        
        viewModel.viewBackgroundColor.drive(onNext: { (backgroundColor) in
            UIView.animate(withDuration: 0.2, animations: {
                self.view.backgroundColor = backgroundColor
            })
        }).disposed(by: disposeBag)
        
        viewModel.dismissView.bind(onNext: { () in
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    func bindTutorialPages(with pageViewController: UIPageViewController) {
        //TODO: Create reactive datasource, this is temporary solution
        viewModel.contentViewControllers.bind(onNext: { self.contentControllers = $0; pageViewController.setViewControllers([$0.first!], direction: .forward, animated: false, completion: nil) }).disposed(by: disposeBag)
    }
    
}
