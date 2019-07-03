//
//  FileManager.swift
//  My LBS
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI on 23.06.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import Foundation

// Make life easier to get most used URL locations.
public extension FileManager {
    static var documentDirectoryURL: URL {
        return `default`.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    static var applicationSupportDirectoryURL: URL {
        return `default`.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }
    static var defaultDirectory: FileManager {
        return`default`
    }
}
