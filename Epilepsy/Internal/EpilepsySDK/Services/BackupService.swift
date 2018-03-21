//
//  BackupService.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 26/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import UIKit
import CloudKit
import SMTPLite
import RxRealm

class BackupService {
    
    // MARK: Private Properties
    
    private var realm: Realm {
        return try! Realm()
    }
    
    private var settings: Settings {
        return realm.objects(Settings.self).first ?? Settings(byDefault: true)
    }
    
    private let iCloudDocumentsURL: URL? = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent(kBackupFileName)
    
    private let kEpilepsyEmail = "epilepsytest@gmail.com"
    
    private let kEpilepsyEmailPass = "i4ZnL62e"
    
    private let kEpilepsyEmailSMTP = "smtp.gmail.com"
    
    private var completion: ((EPError?) -> Void)?
    
    private let disposeBag = DisposeBag()
    
    // MARK - Public Methods
    
    init() {
        self.updateICloudEnableState()
        
        //TODO: Uncomment for production logic
        //        Observable.from(object: settings, properties: ["backupICloudTimeInterval", "backupEmailTimeInterval"]).bind(onNext: { (settings) in
        //            self.setupBackgroundFetchInterval()
        //        }).disposed(by: disposeBag)
        
        //TODO: Remove - this is debug logic
        Observable.from(object: settings, properties: ["isBackupEmailSendEnabled", "userEmail"]).skip(1).bind(onNext: { (settings) in
            if settings.isBackupICloudEnabled {
                let _ = self.sendBackupToICloud()
            }
            if settings.isBackupEmailSendEnabled {
                self.performBackupSend(completion: { _ in })
            }
        }).disposed(by: disposeBag)
    }
    
    func setupBackgroundFetchInterval() {
        UIApplication.shared.setMinimumBackgroundFetchInterval(settings.minimumFetchInterval)
    }
    
    func performBackupSend(completion: @escaping (EPError?) -> Void) {
        let _ = sendBackupToICloud()
        if settings.lastEmailBackupDate ?? (Date() - Double(settings.backupEmailTimeInterval)) + Double(settings.backupEmailTimeInterval) <= Date() {
            let _ = sendBackupToEmail(completion: completion)
        } else {
            completion(nil)
        }
    }
    
}

private extension BackupService {
    
    var isICloudAvailable: Bool {
        return iCloudDocumentsURL != nil
    }
    
    var isSettingsCreated: Bool {
        return realm.object(ofType: Settings.self, forPrimaryKey: settings.id) != nil
    }
    
    func updateICloudEnableState() {
        try! realm.write {
            //TODO: Present alert on icloud unavailable
            settings.isBackupICloudEnabled = isICloudAvailable
            realm.add(settings, update: isSettingsCreated)
        }
    }
    
    func sendBackupToICloud() -> EPError? {
        if let iCloudUrl = iCloudDocumentsURL {
            //TODO: Refactor to set ubiquity directory with backup, to send to email after
            do {
                if FileManager.default.fileExists(atPath: iCloudUrl.path) {
                    try FileManager.default.removeItem(at: iCloudUrl)
                }
                try realm.writeCopy(toFile: iCloudUrl)
                if settings.lastICloudBackupDate ?? (Date() - Double(settings.backupICloudTimeInterval)) + Double(settings.backupICloudTimeInterval) <= Date() {
                    try realm.write {
                        settings.lastICloudBackupDate = Date()
                    }
                }
                return nil
            } catch {
                return EPError.ICloidBackupSyncError
            }
        } else {
            return EPError.ICloidBackupSyncError
        }
    }
    
    func sendBackupToEmail(completion: @escaping (EPError?) -> Void) {
        if let email = settings.userEmail, isICloudAvailable, settings.isBackupEmailSendEnabled {
            let message = SMTPMessage()
            message.from = kEpilepsyEmail
            message.to = email
            message.account = kEpilepsyEmail
            message.pwd = kEpilepsyEmailPass
            message.host = kEpilepsyEmailSMTP
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            message.subject = String(format: NSLocalizedString("Ваша резервная копия данных из приложения Epilepsy от %@", comment: ""), dateFormatter.string(from: Date()))
            message.content = NSLocalizedString("Резервная копия прикреплена к письму, откройте ее на своем iPhone с установленным приложением Epilepsy, чтобы восстановить данные", comment: "")
            let backup = SMTPAttachment()
            backup.name = kBackupFileName
            backup.filePath = iCloudDocumentsURL!.path
            message.attachments = [backup]
            message.send({ (message, now, total) in
                print(now)
            }, success: { [weak self] (message) in
                try? self?.realm.write {
                    self?.settings.lastEmailBackupDate = Date()
                }
                completion(nil)
                }, failure: { (message, error) in
                    completion(EPError.EmailBackupSendError)
            })
        } else {
            return completion(nil)
        }
    }
    
}
