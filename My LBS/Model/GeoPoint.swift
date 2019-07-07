//
//  GeoPoint.swift
//  My LBS
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI on 07.07.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import Foundation
import CoreLocation

class GeoPoint: Codable {
    
    enum CodingKeys: String, CodingKey {
        case lat, lon
    }
    var latitude: Double
    var longitude: Double
    
    init(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try values.decode(Double.self, forKey: .lat)
        longitude = try values.decode(Double.self, forKey: .lon)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .lat)
        try container.encode(longitude, forKey: .lon)
    }
}
