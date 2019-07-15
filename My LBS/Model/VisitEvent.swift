//
//  File.swift
//  My LBS
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI on 30.06.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import Foundation
import CoreLocation

class VisitEvent: Event, Codable {
    
    enum CodingKeys: String, CodingKey {
        case name, arrivalDate, departureDate, duration, location, latitude, longitude, horizontalAccuracy, isUploaded, eventClassType, addedDate, esid
    }
    
    var name: String
    var arrivalDate: Date
    var departureDate: Date?
    var duration: Double?
    var location: GeoPoint
    var horizontalAccuracy: CLLocationAccuracy
    var isUploaded: Bool
    var eventClassType: EventClassType
    var addedDate: Date
    var esid: String
    
    
    
    init(name: String, arrivalDate: Date, departureDate: Date?, duration: Double?, coordinate: CLLocationCoordinate2D, horizontalAccuracy: CLLocationAccuracy, isUploaded: Bool = false, eventClassType: EventClassType = .visitEvent, addedDate: Date = Date(), esid: String = "") {
        self.name = name
        self.arrivalDate = arrivalDate
        self.departureDate = departureDate
        self.duration = duration
        self.location = GeoPoint(coordinate: coordinate)
        self.horizontalAccuracy = horizontalAccuracy
        self.isUploaded = isUploaded
        self.eventClassType = eventClassType
        self.addedDate = addedDate
        self.esid = esid
    }
    
    func setEsid(esid: String) {
        self.esid = esid
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        arrivalDate = try dateStringDecode(forKey: .arrivalDate, from: values, with: .iso8601)
        
        // departureDate = try dateStringDecode(forKey: .departureDate, from: values, with: .iso8601)
        do {
            try departureDate = dateStringDecode(forKey: .departureDate, from: values, with: .iso8601)
        } catch {
            departureDate = nil
        }
        
        //duration = try values.decode(Double.self, forKey: .duration)
        do {
            try duration = values.decode(Double.self, forKey: .duration)
        } catch {
            duration = nil
        }
        
        let latitude = try values.decode(Double.self, forKey: .latitude)
        let longitude = try values.decode(Double.self, forKey: .longitude)
        location = GeoPoint(coordinate: CLLocationCoordinate2DMake(latitude, longitude))
        location = try values.decode(GeoPoint.self, forKey: .location)
        
        let horizontalAccuracyRaw = try values.decode(Double.self, forKey: .longitude)
        horizontalAccuracy = CLLocationAccuracy(horizontalAccuracyRaw)
        isUploaded = try values.decode(Bool.self, forKey: .isUploaded)
        let classType = try values.decode(String.self, forKey: .eventClassType)
        eventClassType = EventClassType(rawValue: classType) ?? .visitEvent
        addedDate = try dateStringDecode(forKey: .addedDate, from: values, with: .iso8601Milliseconds)
        esid = try values.decode(String.self, forKey: .esid)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(DateFormatter.iso8601.string(from: arrivalDate), forKey: .arrivalDate)
        if let departureDateSafe = departureDate {
            try container.encode(DateFormatter.iso8601.string(from: departureDateSafe), forKey: .departureDate)
        } else {
            try container.encode(departureDate, forKey: .departureDate)
        }
        try container.encode(duration, forKey: .duration)
        try container.encode(location, forKey: .location)
        try container.encode(horizontalAccuracy.binade, forKey: .horizontalAccuracy)
        try container.encode(isUploaded, forKey: .isUploaded)
        try container.encode(eventClassType.rawValue, forKey: .eventClassType)
        try container.encode(DateFormatter.iso8601Milliseconds.string(from: addedDate), forKey: .addedDate)
        try container.encode(esid, forKey: .esid)
    }
}

extension VisitEvent {
    public class func readFromJson() -> [VisitEvent] {
        
        let documentDirectoryURL = URL(fileURLWithPath: "data", relativeTo: FileManager.documentDirectoryURL)
        let fileURL: URL = documentDirectoryURL.appendingPathComponent("visitEvents").appendingPathExtension("json")
        
        do {
            let savedData = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let savedVisitEvents = try? decoder.decode(Array.self, from: savedData) as [VisitEvent] {
                return savedVisitEvents
            }
        } catch {
            return []
        }
        return []
    }
}

extension VisitEvent: EventClass {
    func getEventClass() -> EventClassType {
        return eventClassType
    }
}
