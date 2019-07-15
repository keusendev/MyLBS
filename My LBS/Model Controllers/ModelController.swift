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
    
    
    
    func syncToElasticsea() {
        
    }
    
    func uploadEventToElasticsearch(event: Event) {
        
        
    }
    
    // MARK: Upload events
    func startSyncToElastic() {
        print("upload started")
    }
    
    private func getJsonData(event: Event) -> Data? {
        
        let encoder = JSONEncoder()
        
        do {
            if let geofenceEvent = event as? GeofenceEvent {
                return try encoder.encode(geofenceEvent)
            } else if let visitEvent = event as? VisitEvent {
                return try encoder.encode(visitEvent)
            } else if let posEvent = event as? PositionEvent {
                return try encoder.encode(posEvent)
            }
        } catch {
            print("Error info: \(error)")
        }
        return nil
    }
    
    private func getEsIndex(event: Event) -> ElasticsearchIndexName? {
        do {
            if event is GeofenceEvent {
                return .geofenceIndex
            } else if event is VisitEvent {
                return .visitIndex
            } else if event is PositionEvent {
                return .positionIndex
            }
            return nil
        }
        
    }
    
    func postEventToElasticsearch(event: Event) {
        
        guard let esIndex = getEsIndex(event: event) else {
            return
        }
        
        guard var request = getRequestBody(forEsIndex: esIndex) else {
            return
        }
        
        guard let jsonData = getJsonData(event: event) else {
            // exit func if jsonData is nil
            return
        }
        
        request.httpBody = jsonData
        
        let sessionConf = URLSessionConfiguration.ephemeral
        sessionConf.allowsCellularAccess = true
        sessionConf.waitsForConnectivity = true
        
        let session = URLSession(configuration: sessionConf)
        
        let task = session.dataTask(with: request) {
            
            (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse, (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) else {
                return
            }
            do {
                let decoder = JSONDecoder()
                let esResponse = try decoder.decode(ElasticDocAddResponse.self, from: data!)
                
                if (esResponse.result == "created" || esResponse.result == "updated") {
                    
                    let queue = OperationQueue.main
                    queue.addOperation {
                        event.setEsid(esid: esResponse._id)
                    }
                } else {
                    print(esResponse)
                }
            } catch {
                print("Error info: \(error)")
            }
        }
        task.resume()
    }

    private func areElasticParametersSet() -> Bool {
        if ( !myLbsSettings.username.isEmpty && !myLbsSettings.password.isEmpty && !myLbsSettings.host.isEmpty) {
            return true
        }
        return false
    }
    
    private func getRequestBody(forEsIndex: ElasticsearchIndexName) -> URLRequest? {
        
        // Check if needed parametes for web request are set
        guard areElasticParametersSet() else {
            // exit if parameters are missing
            return nil
        }
        
        let loginString = "\(myLbsSettings.username):\(myLbsSettings.password)"
        let loginData = loginString.data(using: .utf8)
        let encodedString = loginData!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        
        let url = URL(string: "https://\(myLbsSettings.host)/\(forEsIndex.rawValue)/_doc/")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "Post"
        request.httpShouldHandleCookies = true
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic \(encodedString)", forHTTPHeaderField: "authorization")
        
        return request
    }
}
