//
//  Helpers.swift
//  My LBS
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI on 29.06.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import UIKit
import MapKit

// Helper to zoom in
extension MKMapView {
    func zoomToUserLocation() {
        guard let coordinate = userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        setRegion(region, animated: true)
    }
}

// MARK: Helper Extensions
extension UIViewController {
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension DateFormatter {
    // Handles dates of the form "2018-04-07"
    public static let yearMonthDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    // Handles dates of the form "2018-02-22T23:35:48.945-0800"
    public static let iso8601Milliseconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    // Handles dates of the form "2018-02-22T23:34:24-0800"
    public static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ";
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}

// A generic method for date decoding
public func dateStringDecode<C>(forKey key: C.Key, from container: C, with formatters: DateFormatter...) throws -> Date
    where C: KeyedDecodingContainerProtocol {
        let dateString = try container.decode(String.self, forKey: key)
        
        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: dateString)
}

// The app "red"
public func appColorRed() -> UIColor {
    let red = 158
    let green = 39
    let blue = 41
    let alpha = 255
    let redPart: CGFloat = CGFloat(red) / 255
    let greenPart: CGFloat = CGFloat(green) / 255
    let bluePart: CGFloat = CGFloat(blue) / 255
    let alphaPart: CGFloat = CGFloat(alpha) / 255
    return UIColor(red: redPart, green: greenPart, blue: bluePart, alpha: alphaPart)
}

// Pretty print time in seconds data
public func humanReadableElapsedTime(seconds: Double) -> String {
    let oneMinute: Double = 60
    let oneHour: Double = oneMinute * 60
    let oneDay: Double = oneHour * 24
    
    let numD = (seconds / oneDay).rounded(.towardZero)
    let numH = ((seconds - numD * oneDay) / oneHour).rounded(.towardZero)
    let numM = ((seconds - numD * oneDay - numH * oneHour) / oneMinute).rounded(.towardZero)
    let numS = (seconds - numD * oneDay - numH * oneHour - numM * oneMinute).rounded(.towardZero)
    
    
    if numD != 0 {
        return String(format: "%1.0fd %1.0fh %1.0lfmin %1.0fs", numD, numH, numM, numS)
    }
    if numH != 0 {
        return String(format: "%1.0fh %1.0lfmin %1.0fs", numH, numM, numS)
    }
    if numM != 0 {
        return String(format: "%1.0lfmin %1.0fs", numM, numS)
    }
    if numS != 0 {
        return String(format: "%1.0fs", numS)
    }
    
    return "0s"
}
