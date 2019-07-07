//
//  ModelController.swift
//  My LBS
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI on 30.06.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import UIKit
import CoreLocation

protocol ModelControllerClient {
    func setModeController(modeController: ModelController)
}

// The glue for the whole stuff :)
class ModelController {
    var geofences: [Geofence] = []
    var geofenceEvents: [GeofenceEvent] = []
    var visitEvents: [VisitEvent] = []
    var positionEvents: [PositionEvent] = []
    var myLbsSettings = MyLbsConfig()
    var viewControllers: [String: UIViewController] = [:]
    let locationManager = CLLocationManager()
    
    // MARK: Save config
    func saveMyLbsConfig() {
        let settingsDirectoryURL = URL(fileURLWithPath: "settings", relativeTo: FileManager.applicationSupportDirectoryURL)
        try? FileManager.defaultDirectory.createDirectory(at: settingsDirectoryURL, withIntermediateDirectories: true)
        let fileURL: URL = settingsDirectoryURL.appendingPathComponent("config").appendingPathExtension("json")
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(myLbsSettings)
        do {
            try jsonData.write(to: fileURL, options: .atomic)
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    // MARK: Read Config
    func readMyLbsConfig() {
        let jsonDecoder = JSONDecoder()
        let settingsDirectoryURL = URL(fileURLWithPath: "settings", relativeTo: FileManager.applicationSupportDirectoryURL)
        let fileURL: URL = settingsDirectoryURL.appendingPathComponent("config").appendingPathExtension("json")
        
        do {
            let data = try Data(contentsOf: fileURL)
            let myLbsConfig = try jsonDecoder.decode(MyLbsConfig.self, from: data)
            self.myLbsSettings = myLbsConfig
        } catch {
            print("Unexpected error: \(error).")
            self.myLbsSettings = MyLbsConfig()
        }
    }
    
    // MARK: Save fences
    func saveGeofences(folderName: String = "data", fileName: String = "geofences") {
        
        let encoder = JSONEncoder()
        let documentDirectoryURL = URL(fileURLWithPath: folderName, relativeTo: FileManager.documentDirectoryURL)
        try? FileManager.defaultDirectory.createDirectory(at: documentDirectoryURL, withIntermediateDirectories: true)
        let fileURL: URL = documentDirectoryURL.appendingPathComponent(fileName).appendingPathExtension("json")
        
        do {
            let data = try encoder.encode(geofences)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Unexpected error while encoding: \(error)")
        }
    }
    
    // MARK: Save Geofence events
    func saveGeofenceEvents(folderName: String = "data", fileName: String = "geofenceEvents") {
        let encoder = JSONEncoder()
        let documentDirectoryURL = URL(fileURLWithPath: folderName, relativeTo: FileManager.documentDirectoryURL)
        try? FileManager.defaultDirectory.createDirectory(at: documentDirectoryURL, withIntermediateDirectories: true)
        let fileURL: URL = documentDirectoryURL.appendingPathComponent(fileName).appendingPathExtension("json")
        
        do {
            let data = try encoder.encode(geofenceEvents)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Unexpected error while encoding: \(error)")
        }
    }
    
    // MARK: Save Visit events
    func saveVisitEvents(folderName: String = "data", fileName: String = "visitEvents") {
        let encoder = JSONEncoder()
        let documentDirectoryURL = URL(fileURLWithPath: folderName, relativeTo: FileManager.documentDirectoryURL)
        try? FileManager.defaultDirectory.createDirectory(at: documentDirectoryURL, withIntermediateDirectories: true)
        let fileURL: URL = documentDirectoryURL.appendingPathComponent(fileName).appendingPathExtension("json")
        
        do {
            let data = try encoder.encode(visitEvents)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Unexpected error while encoding: \(error)")
        }
    }
    
    // MARK: Save Position events
    func savePositionEvents(folderName: String = "data", fileName: String = "positionEvents") {
        let encoder = JSONEncoder()
        let documentDirectoryURL = URL(fileURLWithPath: folderName, relativeTo: FileManager.documentDirectoryURL)
        try? FileManager.defaultDirectory.createDirectory(at: documentDirectoryURL, withIntermediateDirectories: true)
        let fileURL: URL = documentDirectoryURL.appendingPathComponent(fileName).appendingPathExtension("json")
        
        do {
            let data = try encoder.encode(positionEvents)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Unexpected error while encoding: \(error)")
        }
    }
    
    // MARK: Loading and saving functions
    func readGeofences() {
        geofences.removeAll()
        geofences = Geofence.readFromJson()
    }
    
    func readGeofenceEvents() {
        geofenceEvents.removeAll()
        geofenceEvents = GeofenceEvent.readFromJson()
    }
    
    func readVisitEvents() {
        visitEvents.removeAll()
        visitEvents = VisitEvent.readFromJson()
    }
    func readPositionEvents() {
        positionEvents.removeAll()
        positionEvents = PositionEvent.readFromJson()
    }
}
