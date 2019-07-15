//
//  AppDelegate.swift
//  My LBS
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI on 22.06.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

protocol EventDelegate: AnyObject {
    func didReceiveNewEvent(eventClassType: EventClassType)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let modelController = ModelController()
    weak var eventDelegate: EventDelegate?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Dependency injection to all possible ViewControllers
        if let tab = window?.rootViewController as? UITabBarController {
            for child in tab.viewControllers ?? [] {
                for nav in child.children {
                    if let top = nav as? ModelControllerClient {
                        top.setModeController(modeController: modelController)
                    }
                }
            }
        }
        
        // Be a delegate of SettingsController to stay notified if settings will be changed
        (modelController.viewControllers["SettingsTableViewController"] as! SettingsTableViewController).delegate = self
        
        // Handle LBS stuff a place to be ^^ and get permission from user to use LBS
        modelController.locationManager.delegate = self
        modelController.locationManager.requestAlwaysAuthorization()
        
        // Prepare possible notification options and request to be allowed to send notifications
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        UNUserNotificationCenter.current()
            .requestAuthorization(options: options) { success, error in
                if let error = error {
                    print("Error: \(error)")
                }
        }
        
        // Read stored app configuration and data
        modelController.readMyLbsConfig()
        modelController.readGeofences()
        modelController.readGeofenceEvents()
        modelController.readVisitEvents()
        modelController.readPositionEvents()
        activateSettings()
        
//        modelController.saveVisitEvents()
//        modelController.saveGeofenceEvents()
//        modelController.savePositionEvents()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Set Badge Icon number to 0
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

// Implement SettingsDelegate extension. Used to know when user updates the setting.
// This allows to set activate new settings without closing and opening the app.
extension AppDelegate: SettingsDelegate {
    func didChangeSettings() {
        activateSettings()
    }
}

// MARK: Custom functions to treat incoming tasks
extension AppDelegate {
    
    // General function for user notification
    func notify(message: String, allowInAppInfo: Bool = false) {
        
        // Show an alert if application is active
        if (UIApplication.shared.applicationState == .active && allowInAppInfo) {
            window?.rootViewController?.showAlert(withTitle: nil, message: message)
        } else {
            // Otherwise present a local notification
            let notificationContent = UNMutableNotificationContent()
            notificationContent.body = message
            notificationContent.sound = UNNotificationSound.default
            notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "location_change",
                                                content: notificationContent,
                                                trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error: \(error)")
                }
            }
        }
    }
    
    // Managing incomming Geofence event
    func handleEvent(for region: CLRegion!) {
        
        guard let body = (activatedFence(from: region.identifier))?.note else { return }
        notify(message: body, allowInAppInfo: true)
        
        guard let activeFence = activatedFence(from: region.identifier) else { return }
        let newGeofenceEvent = GeofenceEvent(name: activeFence.note, activityDate: Date(), coordinate: activeFence.coordinate, eventType: activeFence.eventType, device: modelController.myLbsSettings.deviceId)
        modelController.postEventToElasticsearch(event: newGeofenceEvent)
        modelController.geofenceEvents.insert(newGeofenceEvent, at: 0)
        eventDelegate?.didReceiveNewEvent(eventClassType: .geofenceEvent)
        modelController.saveGeofenceEvents()
    }
    
    // MARK: Wrapper to activate user's desired settings
    func activateSettings() {
        if (modelController.myLbsSettings.visitTrackingEnabled) {
            modelController.locationManager.startMonitoringVisits()
        } else {
            modelController.locationManager.stopMonitoringVisits()
        }
        if (modelController.myLbsSettings.significantPositionTrackingEnabled) {
            modelController.locationManager.startMonitoringSignificantLocationChanges()
        } else {
            modelController.locationManager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    // find out which Geofence was triggered by its identifier
    func activatedFence(from identifier: String) -> Geofence? {
        guard let matched = modelController.geofences.filter({
            $0.identifier == identifier
        }).first else { return nil }
        return matched
    }
}


// MARK: Location Manager Delegate functions
extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        var counter: Int = 0
        
        // It is possible that more than one location will be delivered.
        // If the iOS ecosystem didn't manage to deliver all updates then all queued locations will be served in "locations"
        for loc in locations {
            
            var posAlreadyKnown = false
            
            // Because this type of location will be served always if the app gets closed and re-opened, a check is needed to avoid duplicate entries.
            for pos in modelController.positionEvents {
                
                let delta = pos.arrivalDate.timeIntervalSince(loc.timestamp).magnitude
                if delta < 60 {
                    posAlreadyKnown = true
                    break
                }
            }
            if !posAlreadyKnown {
                let locName = "A position (at: \(counter))"
                
                let newPositionEvent = PositionEvent(name: locName,
                                                     arrivalDate: loc.timestamp,
                                                     coordinate: loc.coordinate,
                                                     altitude: loc.altitude,
                                                     course: loc.course,
                                                     floor: loc.floor?.level ?? 0,
                                                     horizontalAccuracy: loc.horizontalAccuracy,
                                                     verticalAccuracy: loc.verticalAccuracy,
                                                     speed: loc.speed,
                                                     device: modelController.myLbsSettings.deviceId)
                
                modelController.postEventToElasticsearch(event: newPositionEvent)
                modelController.positionEvents.insert(newPositionEvent, at: 0)
                modelController.savePositionEvents()
                eventDelegate?.didReceiveNewEvent(eventClassType: .positonEvent)
                counter += 1
            }
        }
    }
    
    // Handle incoming CLVisits -> A CLVisit will be generated if the device stayed on a place for a certain time.
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        let name = "Visit"
        
        var departureDate: Date?
        var duration: Double?
        
        if (visit.departureDate == Date.distantFuture) {
            departureDate = nil
            duration = nil
        } else {
            departureDate = visit.departureDate
            duration = visit.departureDate.timeIntervalSince(visit.arrivalDate)
        }
        
        let newVisitEvent = VisitEvent(name: name,
                                       arrivalDate: visit.arrivalDate,
                                       departureDate: departureDate,
                                       duration: duration,
                                       coordinate: visit.coordinate,
                                       horizontalAccuracy: visit.horizontalAccuracy,
                                       device: modelController.myLbsSettings.deviceId)
        
        let dateformatter = DateFormatter.iso8601
        let message = "New visit: \(dateformatter.string(from: newVisitEvent.arrivalDate))"
        notify(message: message, allowInAppInfo: true)
        modelController.postEventToElasticsearch(event: newVisitEvent)
        modelController.visitEvents.insert(newVisitEvent, at: 0)
        eventDelegate?.didReceiveNewEvent(eventClassType: .visitEvent)
        modelController.saveVisitEvents()
    }
    
    // Catched errors can be treated here
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
}





