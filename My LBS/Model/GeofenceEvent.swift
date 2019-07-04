//
//  GeofenceEvent.swift
//  My LBS
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI on 30.06.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import Foundation
import CoreLocation



class GeofenceEvent: Codable {
       
    enum CodingKeys: String, CodingKey {
        case name, activityDate, eventType, latitude, longitude, isUploaded, eventClassType, addedDate
    }
    
    var name: String
    var activityDate: Date
    var coordinate: CLLocationCoordinate2D
    var eventType: EventType
    var isUploaded: Bool
    var eventClassType: EventClassType
    var addedDate: Date
    
    init(name: String, activityDate: Date, coordinate: CLLocationCoordinate2D, eventType: EventType, isUploaded: Bool = false, eventClassType: EventClassType = .geofenceEvent, addedDate: Date = Date()) {
        self.name = name
        self.activityDate = activityDate
        self.coordinate = coordinate
        self.eventType = eventType
        self.isUploaded = isUploaded
        self.eventClassType = eventClassType
        self.addedDate = addedDate
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        activityDate = try dateStringDecode(forKey: .activityDate, from: values, with: .iso8601)
        let latitude = try values.decode(Double.self, forKey: .latitude)
        let longitude = try values.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let event = try values.decode(String.self, forKey: .eventType)
        eventType = EventType(rawValue: event) ?? .onEntry
        isUploaded = try values.decode(Bool.self, forKey: .isUploaded)
        let classType = try values.decode(String.self, forKey: .eventClassType)
        eventClassType = EventClassType(rawValue: classType) ?? .geofenceEvent
        addedDate = try dateStringDecode(forKey: .addedDate, from: values, with: .iso8601Milliseconds)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(DateFormatter.iso8601.string(from: activityDate), forKey: .activityDate)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(eventType.rawValue, forKey: .eventType)
        try container.encode(isUploaded, forKey: .isUploaded)
        try container.encode(eventClassType.rawValue, forKey: .eventClassType)
        try container.encode(DateFormatter.iso8601Milliseconds.string(from: addedDate), forKey: .addedDate)
    }
}

extension GeofenceEvent {
    public class func readFromJson() -> [GeofenceEvent] {
        
        let documentDirectoryURL = URL(fileURLWithPath: "data", relativeTo: FileManager.documentDirectoryURL)
        let fileURL: URL = documentDirectoryURL.appendingPathComponent("geofenceEvents").appendingPathExtension("json")
        
        do {
            let savedData = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let savedGeofenceEvents = try? decoder.decode(Array.self, from: savedData) as [GeofenceEvent] {
                return savedGeofenceEvents
            }
        } catch {
            return []
        }
        return []
    }
}

extension GeofenceEvent: EventClass {
    func getEventClass() -> EventClassType {
        return eventClassType
    }
}