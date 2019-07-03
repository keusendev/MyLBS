//
//  GeofencesTableViewController.swift
//  My LBS
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI on 30.06.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import UIKit

class GeofencesTableViewController: UITableViewController {
    
    var modelController: ModelController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Make sure that latest data get loaded in view
    override func viewWillAppear(_ animated: Bool) {
        if !tableView.hasUncommittedUpdates {
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Is needed that the view knows how many rows will be displayed
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelController.geofences.count
    }
    
    // Normally if one taps on a cell it stays selected. This method here ensures that it gets unselected again. Of course animated.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) != nil{
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // This enables deleting data. After the array is altered it will also be saved to disk.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let toBeDeletedGeofence = modelController.geofences.remove(at: indexPath.row)
        let geofencingMapViewController: GeofencingMapViewController = (modelController.viewControllers["GeofencingMapViewController"] as! GeofencingMapViewController?)!
        geofencingMapViewController.stopMonitoring(geofence: toBeDeletedGeofence)
        modelController.saveGeofences()
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    // This is the "ugly" way of setting text values for table cells: by catching them with a preset tag. Well, id does its job.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeofenceItem")!
        
        let fence = modelController.geofences[indexPath.row]
        
        let labelNote = cell.viewWithTag(1000) as! UILabel
        labelNote.text = "Fence Name: \(fence.note)"
        
        let labelType = cell.viewWithTag(1002) as! UILabel
        labelType.text = "Fence Type: \(fence.eventType)"

        let labelRadius = cell.viewWithTag(1003) as! UILabel
        labelRadius.text = "Radius: \(Int(fence.radius))m"

        return cell
    }
}

// Back referencing this Controller and linking the ModelController
extension GeofencesTableViewController: ModelControllerClient {
    func setModeController(modeController: ModelController) {
        self.modelController = modeController
        self.modelController.viewControllers["GeofencesTableViewController"] = self
    }
}
