//
//  EventsTableViewController.swift
//  My LBS
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI on 30.06.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import UIKit
import CoreLocation

class EventsTableViewController: UITableViewController {
    
    var modelController: ModelController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.eventDelegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        // Static definition of how many sections are available in table view
        return 3
    }
    
    // Self-explaining...
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return modelController.geofenceEvents.count
        case 1:
            return modelController.visitEvents.count
        case 2:
            return modelController.positionEvents.count
        default:
            return 0
        }
    }
    
    // Unselects a tapped row automatically and animated
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) != nil{
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // Let's color section headers a bit :)
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = appColorRed()
    }
    
    // Self-explaining...
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String? = nil
        
        switch section {
        case 0:
            title = "Geofences"
        case 1:
            title = "Visits"
        case 2:
            title = "Positions"
        default:
            title = "other section"
        }
        return title
    }
    
    // Round to three significant points for coordinates
    func coordinaterFormatter(coordinate: CLLocationCoordinate2D) -> String {
        let lat = coordinate.latitude
        let lon = coordinate.longitude
        return String(format: "lat: %.3f lon: %.3f", lat, lon)
    }
    
    // Table-Cell factory
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        let dateformatter = DateFormatter.iso8601
        let dateformatterMs = DateFormatter.iso8601Milliseconds
        
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "GeofenceEventItem")!
            
            let geofenceEvent = modelController.geofenceEvents[indexPath.row]
            
            if let geofenceEventTableViewCell = cell as? GeofenceEventTableViewCell {
                
                geofenceEventTableViewCell.noteLabel.text = geofenceEvent.name
                geofenceEventTableViewCell.addedDateLabel.text = "Date added: \(dateformatterMs.string(from: geofenceEvent.addedDate))"
                geofenceEventTableViewCell.isUploadedLabel.text = "Uploaded to server: \(geofenceEvent.isUploaded)"
                geofenceEventTableViewCell.typeLabel.text = "Type: \(geofenceEvent.eventType)"
                geofenceEventTableViewCell.dateLabel.text = "Date: \(dateformatter.string(from: geofenceEvent.activityDate))"
                geofenceEventTableViewCell.coordinateLabel.text = coordinaterFormatter(coordinate: geofenceEvent.coordinate)
            }
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "VisitEventItem")!
            
            let visitEvent = modelController.visitEvents[indexPath.row]
            
            if let visitEventTableViewCell = cell as? VisitEventTableViewCell {
                
                visitEventTableViewCell.nameLabel.text = visitEvent.name
                visitEventTableViewCell.addedDateLabel.text = "Date added: \(dateformatterMs.string(from: visitEvent.addedDate))"
                visitEventTableViewCell.isUploadedLabel.text = "Uploaded to server: \(visitEvent.isUploaded)"
                visitEventTableViewCell.arrivalDateLabel.text = "Arrival: \(dateformatter.string(from: visitEvent.arrivalDate))"
                
                if let departureDateSafe = visitEvent.departureDate {
                    visitEventTableViewCell.departureDateLabel.text = "Departure: \(dateformatter.string(from: departureDateSafe))"
                    visitEventTableViewCell.durationLabel.text = "Duration: \(humanReadableElapsedTime(seconds: visitEvent.duration!))"
                } else {
                    visitEventTableViewCell.departureDateLabel.text = "Departure: n/a"
                    visitEventTableViewCell.durationLabel.text = "Duration: n/a"
                }
                
                visitEventTableViewCell.coordinateLabel.text = coordinaterFormatter(coordinate: visitEvent.coordinate)
                visitEventTableViewCell.horizontalAccuracyLabel.text = String(format: "Accuracy: %.1fm", visitEvent.horizontalAccuracy)
            }
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "PositionEventItem")!
            
            let posEvent = modelController.positionEvents[indexPath.row]
            
            if let positionEventTableViewCell = cell as? PositionTableViewCell {
                
                positionEventTableViewCell.nameLabel.text = posEvent.name
                positionEventTableViewCell.addedDateLabel.text = "Date added: \(dateformatterMs.string(from: posEvent.addedDate))"
                positionEventTableViewCell.isUploadedLabel.text = "Uploaded to server: \(posEvent.isUploaded)"
                positionEventTableViewCell.arrivalDateLabel.text = "Arrival: \(dateformatter.string(from: posEvent.arrivalDate))"
                positionEventTableViewCell.coordinateLabel.text = coordinaterFormatter(coordinate: posEvent.coordinate)
                positionEventTableViewCell.altitudeLabel.text = String(format: "Altitude: %.1fm", posEvent.altitude)
                positionEventTableViewCell.courseLabel.text = String(format: "Course relative to North: %.0f°N", posEvent.course)
                positionEventTableViewCell.floorLabel.text = "Floor in Building: \(posEvent.floor)"
                positionEventTableViewCell.horizontalAccuracyLabel.text = String(format: "Accuracy horizontal: %.1fm", posEvent.horizontalAccuracy)
                positionEventTableViewCell.verticalAccuracyLabel.text = String(format: "Accuracy vertical: %.1fm", posEvent.verticalAccuracy)
                
                var speed_mpers: Double = 0
                var speed_kmh: Double = 0
                if posEvent.speed > 0 {
                    speed_mpers = posEvent.speed
                    speed_kmh = posEvent.speed * 3.6
                }
                positionEventTableViewCell.speedLabel.text = String(format: "Current speed: %.2fm/s (%.1fkm/h)", speed_mpers, speed_kmh)
            }
        default: break
        }
        return cell
    }
    
    // Function to delete table entries and store modified arrays to disk
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            modelController.geofenceEvents.remove(at: indexPath.row)
            modelController.saveGeofenceEvents()
        case 1:
            modelController.visitEvents.remove(at: indexPath.row)
            modelController.saveVisitEvents()
        case 2:
            modelController.positionEvents.remove(at: indexPath.row)
            modelController.savePositionEvents()
        default:
            break
        }
        
        // Delete them with a nice animation
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
}

// Back referencing this Controller and linking the ModelController
extension EventsTableViewController: ModelControllerClient {
    func setModeController(modeController: ModelController) {
        self.modelController = modeController
        self.modelController.viewControllers["GeofencesTableViewController"] = self
    }
}

// Incoming information if new data is available to display
extension EventsTableViewController: EventDelegate {
    func didReceiveNewEvent(eventClassType: EventClassType) {
        switch eventClassType {
        case .geofenceEvent:
            break
        case .positonEvent:
            break
        case .visitEvent:
            break
        }
        tableView.reloadData()
    }
}
