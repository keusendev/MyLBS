//
//  PositionsStorage.swift
//  My Tracker
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI-CVI on 30.03.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import Foundation
import CoreLocation

class PositionsStorage {
    static let shared = PositionsStorage()
    
    private(set) var positions: [Position]
    private let fileManager: FileManager
    private let documentsURL: URL
    
    init() {
        let fileManager = FileManager.default
        documentsURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        self.fileManager = fileManager
        
        let jsonDecoder = JSONDecoder()
        
        let positionFilesURLs = try! fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
        
        positions = positionFilesURLs.compactMap { url -> Position? in
            guard !url.absoluteString.contains(".DS_Store") else {
                return nil
            }
            guard let data = try? Data(contentsOf: url) else {
                return nil
            }
            return try? jsonDecoder.decode(Position.self, from: data)
            }.sorted(by: { $0.date < $1.date })
    }
    func savePositionOnDisk(_ position: Position) {
        let encoder = JSONEncoder()
        let timestamp = position.date.timeIntervalSince1970
        let fileURL = documentsURL.appendingPathComponent("\(timestamp)")
        
        let data = try! encoder.encode(position)
        try! data.write(to: fileURL)
        
        positions.append(position)
        
    }
    
    func saveCLPositionToDisk(_ clLocation: CLLocation) {
        let currentDate = Date()
        AppDelegate.geoCoder.reverseGeocodeLocation(clLocation) { placemarks, _ in
            if let place = placemarks?.first {
                let location = Location(clLocation.coordinate, date: currentDate, descriptionString: "\(place)")
                self.saveLocationOnDisk(location)
            }
        }
    }
}
