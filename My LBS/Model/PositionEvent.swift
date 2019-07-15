//
//  PositionEvent.swift
//  My LBS
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI on 01.07.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import Foundation
import CoreLocation

class PositionEvent: Event, Codable {

    enum CodingKeys: String, CodingKey {
        case name, arrivalDate, location, latitude, longitude, isUploaded, eventClassType, altitude, course, floor, horizontalAccuracy, verticalAccuracy, speed, addedDate, esid
    }
    
    var name: String
    var arrivalDate: Date
    var location: GeoPoint
    var isUploaded: Bool
    var eventClassType: EventClassType
    var altitude: CLLocationDistance
    var course: CLLocationDirection
    var floor: Int
    var horizontalAccuracy: CLLocationAccuracy
    var verticalAccuracy: CLLocationAccuracy
    var speed: CLLocationSpeed
    var addedDate: Date
    var esid: String
    
    init(name: String, arrivalDate: Date, coordinate: CLLocationCoordinate2D, isUploaded: Bool = false, eventClassType: EventClassType = .positonEvent, altitude: CLLocationDistance, course: CLLocationDirection, floor: Int, horizontalAccuracy: CLLocationAccuracy, verticalAccuracy: CLLocationAccuracy, speed: CLLocationSpeed, addedDate: Date = Date(), esid: String = "") {
        self.name = name
        self.arrivalDate = arrivalDate
        self.location = GeoPoint(coordinate: coordinate)
        self.isUploaded = isUploaded
        self.eventClassType = eventClassType
        self.altitude = altitude
        self.course = course
        self.floor = floor
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.speed = speed
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
        let latitude = try values.decode(Double.self, forKey: .latitude)
        let longitude = try values.decode(Double.self, forKey: .longitude)
        location = GeoPoint(coordinate: CLLocationCoordinate2DMake(latitude, longitude))
        isUploaded = try values.decode(Bool.self, forKey: .isUploaded)
        let classType = try values.decode(String.self, forKey: .eventClassType)
        eventClassType = EventClassType(rawValue: classType) ?? .visitEvent
        altitude = try values.decode(CLLocationDistance.self, forKey: .altitude)
        course = try values.decode(CLLocationDirection.self, forKey: .course)
        floor = try values.decode(Int.self, forKey: .floor)
        horizontalAccuracy = try values.decode(CLLocationAccuracy.self, forKey: .horizontalAccuracy)
        verticalAccuracy = try values.decode(CLLocationAccuracy.self, forKey: .verticalAccuracy)
        speed = try values.decode(CLLocationSpeed.self, forKey: .speed)
        addedDate = try dateStringDecode(forKey: .addedDate, from: values, with: .iso8601Milliseconds)
        location = try values.decode(GeoPoint.self, forKey: .location)
        esid = try values.decode(String.self, forKey: .esid)

    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(DateFormatter.iso8601.string(from: arrivalDate), forKey: .arrivalDate)
        try container.encode(location, forKey: .location)
        try container.encode(isUploaded, forKey: .isUploaded)
        try container.encode(eventClassType.rawValue, forKey: .eventClassType)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(course, forKey: .course)
        try container.encode(floor, forKey: .floor)
        try container.encode(horizontalAccuracy, forKey: .horizontalAccuracy)
        try container.encode(verticalAccuracy, forKey: .verticalAccuracy)
        try container.encode(speed, forKey: .speed)
        try container.encode(DateFormatter.iso8601Milliseconds.string(from: addedDate), forKey: .addedDate)
        try container.encode(esid, forKey: .esid)

    }
}

extension PositionEvent {
    public class func readFromJson() -> [PositionEvent] {
        
        let documentDirectoryURL = URL(fileURLWithPath: "data", relativeTo: FileManager.documentDirectoryURL)
        let fileURL: URL = documentDirectoryURL.appendingPathComponent("positionEvents").appendingPathExtension("json")
        
        do {
            let savedData = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let savedVisitEvents = try? decoder.decode(Array.self, from: savedData) as [PositionEvent] {
                return savedVisitEvents
            }
        } catch {
            return []
        }
        return []
    }
}

extension PositionEvent: EventClass {
    func getEventClass() -> EventClassType {
        return eventClassType
    }
}
