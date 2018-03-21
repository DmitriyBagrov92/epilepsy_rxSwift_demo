//
//  ReportDetailsViewController.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 07/03/2018.
//  Copyright © 2018 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit
import WebKit
import MessageUI

class ReportDetailsViewController: UITableViewController, ViewControllerProtocol, Identifierable {
    
    // MARK: ViewControllerProtocol Properties
    
    typealias VM = ReportDetailsViewModel
    
    var viewModel: ReportDetailsViewModel!
    
    // MARK: IBOutlets - Views
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var openReportButton: UIButton!
    
    @IBOutlet weak var sendReportToEmailButton: UIButton!
    
    // MARK: Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: Lyfecircle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = tableView.backgroundColor
        
        bindUI()
    }
    
}

private extension ReportDetailsViewController {
    
    func bindUI() {
        emailTextField.rx.controlEvent(.editingChanged).withLatestFrom(emailTextField.rx.text).bind(to: viewModel.userEmailInput).disposed(by: disposeBag)
        viewModel.userEmail.drive(emailTextField.rx.text).disposed(by: disposeBag)
        
        openReportButton.rx.tap.bind(to: viewModel.openReportAction).disposed(by: disposeBag)
        sendReportToEmailButton.rx.tap.bind(to: viewModel.sendReportToEmailAction).disposed(by: disposeBag)
        
        viewModel.pdfPreviewFilePath.drive(onNext: { (url) in
            let documentInteractionController = UIDocumentInteractionController(url: url)
            documentInteractionController.delegate = self
            documentInteractionController.presentPreview(animated: true)
        }).disposed(by: disposeBag)
        
        viewModel.errorAlertPresent.drive(onNext: { self.present($0, animated: true, completion: nil) }).disposed(by: disposeBag)
        
        viewModel.emailComposerPresent.drive(onNext: { (composer) in
            composer.mailComposeDelegate = self
            self.present(composer, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
}

extension ReportDetailsViewController: UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
}

extension ReportDetailsViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
