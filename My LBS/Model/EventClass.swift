//
//  EventClass.swift
//  My LBS
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI on 30.06.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import Foundation

enum EventClassType: String {
    case geofenceEvent = "Geofence Event"
    case visitEvent = "Visit Event"
    case positonEvent = "Position Event"
}

protocol EventClass: Codable {
    func getEventClass() -> EventClassType
}
