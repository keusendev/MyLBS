//
//  Position.swift
//  My Tracker
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI-CVI on 09.03.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import Foundation
import CoreLocation

class Position: Codable {
    
    // MARK: Properties
    let latitude: Double
    let longitude: Double
    let date: Date
    let dateString: String
    let description: String
    let fromType: String //visit or sigLocation
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()

    init(_ location: CLLocationCoordinate2D, date: Date, descriptionString: String, fromTypeString: String) {
        latitude =  location.latitude
        longitude =  location.longitude
        self.date = date
        dateString = Position.dateFormatter.string(from: date)
        description = descriptionString
        fromType = fromTypeString
    }
}
