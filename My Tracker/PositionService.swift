//
//  PositionService.swift
//  My Tracker
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI-CVI on 09.03.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import Foundation
import CoreLocation

class PositionService {
    // MARK: Properties
    private static var sharedPositionService: PositionService = {
        let positionService = PositionService()
        return positionService
    }()
    
    var positions = [Position]()
    let locationManager = CLLocationManager()
    
    
    // Initialization
    private init() {
        loadSamplePositions()
    }
    
    // MARK: - Accessors
    class func shared() -> PositionService {
        return sharedPositionService
    }
    // MARK: Private functions
    private func loadSamplePositions() {
        let pos1 = Position(name: "first pos", detail: "my descr 1")
        let pos2 = Position(name: "second pos", detail: "my descr 2")
        let pos3 = Position(name: "third pos", detail: "my descr 3")
        positions += [pos1, pos2, pos3]
    }
    
    func enableLocationServices() {
        locationManager.delegate = self as? CLLocationManagerDelegate
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
            break
            
        case .restricted, .denied:
            // Disable location features
            disableMyLocationBasedFeatures()
            break
            
        case .authorizedWhenInUse:
            // Enable basic location features
            enableMyWhenInUseFeatures()
            break
            
        case .authorizedAlways:
            // Enable any of your app's location features
            enableMyAlwaysFeatures()
            break
        }
    }
}



