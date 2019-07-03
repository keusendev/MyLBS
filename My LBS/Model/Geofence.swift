//
//  Geofence.swift
//  My LBS
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI on 29.06.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class Geofence: NSObject, Codable, MKAnnotation {
    
    enum CodingKeys: String, CodingKey {
        case latitude, longitude, radius, identifier, note, dateTime, eventType
    }
    
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: String
    var note: String
    var dateTime: Date
    var eventType: EventType
    
    var title: String? {
        if note.isEmpty {
            return "No Note"
        }
        return note
    }
    
    var subtitle: String? {
        let eventTypeString = eventType.rawValue
        return "Radius: \(radius)m - \(eventTypeString)"
    }
    
    init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, note: String, dateTime: Date = Date(), eventType: EventType) {
        self.coordinate = coordinate
        self.radius = radius
        self.identifier = identifier
        self.note = note
        self.dateTime = dateTime
        self.eventType = eventType
    }
    
    // MARK: Codable
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decode(Double.self, forKey: .latitude)
        let longitude = try values.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        radius = try values.decode(Double.self, forKey: .radius)
        identifier = try values.decode(String.self, forKey: .identifier)
        note = try values.decode(String.self, forKey: .note)
        dateTime = try values.decode(Date.self, forKey: .dateTime)
        dateTime = try dateStringDecode(forKey: .dateTime, from: values, with: .iso8601)
        let event = try values.decode(String.self, forKey: .eventType)
        eventType = EventType(rawValue: event) ?? .onEntry
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(radius, forKey: .radius)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(note, forKey: .note)
        try container.encode(DateFormatter.iso8601.string(from: dateTime), forKey: .dateTime)
        try container.encode(eventType.rawValue, forKey: .eventType)
    }
}

extension Geofence {
    public class func readFromJson() -> [Geofence] {
        
        let documentDirectoryURL = URL(fileURLWithPath: "data", relativeTo: FileManager.documentDirectoryURL)
        let fileURL: URL = documentDirectoryURL.appendingPathComponent("geofences").appendingPathExtension("json")
        
        do {
            let savedData = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let savedGeofences = try? decoder.decode(Array.self, from: savedData) as [Geofence] {
                return savedGeofences
            }
        } catch {
            return []
        }
        return []
    }
}
