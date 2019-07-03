//
//  SettingsModel.swift
//  My LBS
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI on 22.06.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import Foundation

struct MyLbsConfig: Codable, Equatable {
    
    var host: String = ""
    var username: String = ""
    var password: String = ""
    var deviceId: String = ""
    var visitTrackingEnabled: Bool
    var significantPositionTrackingEnabled: Bool
    
    init(host: String = "", username: String = "", password: String = "", deviceId: String = "", visitTrackingEnabled: Bool = false, significantPositionTrackingEnabled: Bool = false) {
        self.host = host
        self.username = username
        self.password = password
        self.deviceId = deviceId
        self.visitTrackingEnabled = visitTrackingEnabled
        self.significantPositionTrackingEnabled = significantPositionTrackingEnabled
    }
}
