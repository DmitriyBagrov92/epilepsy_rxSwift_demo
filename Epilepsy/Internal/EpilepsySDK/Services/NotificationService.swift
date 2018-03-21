//
//  NotificationService.swift
//  Epilepsy
//
//  Created by Dmitrii Bagrov on 18/12/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation
import RxSwift
import RxRealm
import RealmSwift
import UserNotificationsUI

class NotificationsService {
    
    // MARK: Private Properties
    
    private let notificationTypes: UIUserNotificationType = [.alert, .sound]
    
    private let disposeBag = DisposeBag()
    
    // MARK - Lifecycle
    
    init() {
        //TODO: Call Setup when you need
        setupNotificationsAccess()
        
        let realm = try! Realm()
        
        setupDoctorVisitsNotifications(realm: realm)
        //TODO: Fix and optimize
        setupDrugsNotifications(realm: realm)
        setupEndOfDayNotification(realm: realm)
    }
    
}

private extension NotificationsService {
    
    func setupDoctorVisitsNotifications(realm: Realm) {
        let doctorVisits = realm.objects(DoctorVisit.self)
        let visitsCollection = Observable.collection(from: doctorVisits)
        visitsCollection.bind(onNext: { (visits) in
            for visit in visits {
                if let previousNotification = self.notification(with: visit.id)?.first {
                    UIApplication.shared.cancelLocalNotification(previousNotification)
                }
                if let newNotifications = visit.notifications {
                    UIApplication.shared.scheduleLocalNotification(newNotifications.first!)
                }
            }
        }).disposed(by: disposeBag)
    }
    
    func setupDrugsNotifications(realm: Realm) {
        let drugs = realm.objects(Drug.self)
        let drugsChangset = Observable.changeset(from: drugs)
        drugsChangset.bind(onNext: { (result, changes) in
            
            if let removedIndexes = changes?.deleted, removedIndexes.count > 0 {
                for index in removedIndexes {
                    if let previousNotifications = self.notification(with: result[index].id) {
                        for pn in previousNotifications {
                            UIApplication.shared.cancelLocalNotification(pn)
                        }
                    }
                }
            }
            
            if let insertedIndexes = changes?.inserted, insertedIndexes.count > 0 {
                for index in insertedIndexes {
                    if let previousNotifications = self.notification(with: result[index].id) {
                        for nn in previousNotifications {
                            UIApplication.shared.scheduleLocalNotification(nn)
                        }
                    }
                }
            }
            
            if let changedIndexes = changes?.updated, changedIndexes.count > 0 {
                for index in changedIndexes {
                    //TODO: Optimize to changeset
                    if let previousNotifications = self.notification(with: result[index].id) {
                        for pn in previousNotifications {
                            UIApplication.shared.cancelLocalNotification(pn)
                        }
                    }
                    
                    if let newNotifications = result[index].notifications {
                        for nn in newNotifications {
                            UIApplication.shared.scheduleLocalNotification(nn)
                        }
                    }
                }
            }
            
        }).disposed(by: disposeBag)
    }
    
    func setupEndOfDayNotification(realm: Realm) {
        let drugs = realm.objects(Drug.self)
        let drugsCollection = Observable.collection(from: drugs)
        
        let healths = realm.objects(Health.self)
        let healhtsCollection = Observable.collection(from: healths)
        
        let settings = realm.objects(Settings.self)
        let settingsCollection = Observable.collection(from: settings)
        
        Observable.combineLatest(drugsCollection, healhtsCollection, settingsCollection).bind(onNext: { (drugs, heaths, settings) in
            let settings = realm.objects(Settings.self).first ?? Settings(byDefault: true)
            if let previousNotifications = self.notification(with: settings.id) {
                for pn in previousNotifications {
                    UIApplication.shared.cancelLocalNotification(pn)
                }
            }
            if let newNotifications = settings.notifications {
                for nn in newNotifications {
                    UIApplication.shared.scheduleLocalNotification(nn)
                }
            }
        }).disposed(by: disposeBag)
    }
    
    func setupNotificationsAccess() {
        guard let currentSettigns = UIApplication.shared.currentUserNotificationSettings else { return }
        if currentSettigns.types != notificationTypes {
            let newSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(newSettings)
        }
    }
    
    func notification(with objectId: String) -> [UILocalNotification]? {
        return UIApplication.shared.scheduledLocalNotifications?.filter({ $0.userInfo?[kNotificationObjectId] as? String == objectId })
    }
    
}
