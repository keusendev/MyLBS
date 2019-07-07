//
//  GeofencingMapViewController.swift
//  My LBS
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI on 29.06.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications

class GeofencingMapViewController: UIViewController {
    
    var modelController: ModelController!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        // Remove all info stuff from the map
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        // Re-add info stuff with latest data
        loadAllGeofences()
    }
    
    // MARK: Register this instance in delegate variable of AddGeofenceTableViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Catch the correct segue with its identifier
        if segue.identifier == "addGeofenceSegue" {
            let navigationController = segue.destination as! UINavigationController
            let vc = navigationController.viewControllers.first as! AddGeofenceTableViewController
            vc.delegate = self
        }
    }
}

extension GeofencingMapViewController {
    
    // MARK: Zooms map to current position if the button is taped.
    @IBAction func zoomToCurrentLocation(sender: AnyObject) {
        mapView.zoomToUserLocation()
    }
    
    // MARK: Functions that update the model/associated views with geotification changes
    func addAnnotation(_ geofence: Geofence) {
        mapView.addAnnotation(geofence)
        addRadiusOverlay(forGeofence: geofence)
        updateGeofencesCount() // Titel
    }
    
    // MARK: Map overlay functions
    func addRadiusOverlay(forGeofence geofence: Geofence) {
        mapView?.addOverlay(MKCircle(center: geofence.coordinate, radius: geofence.radius))
    }
    
    // No magic, right?
    func updateGeofencesCount() {
        navBar.title = "Geofences: \(modelController.geofences.count)"
    }

    // Re-place all overlay/annotation items
    func loadAllGeofences() {
        mapView.removeAnnotations(mapView.annotations)
        modelController.geofences.forEach { addAnnotation($0) }
    }
    
    // Preparing the fence region.
    func region(with geofence: Geofence) -> CLCircularRegion {
        let region = CLCircularRegion(center: geofence.coordinate, radius: geofence.radius, identifier: geofence.identifier)
        region.notifyOnEntry = (geofence.eventType == .onEntry)
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    // Activate the actual fence monitoring
    func startMonitoring(geofence: Geofence) {
        let fenceRegion = region(with: geofence)
        modelController.locationManager.startMonitoring(for: fenceRegion)
    }
    
    // Deactivate a specific fence monitoring
    func stopMonitoring(geofence: Geofence) {
        for region in modelController.locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geofence.identifier else { continue }
            modelController.locationManager.stopMonitoring(for: circularRegion)
        }
    }
}

extension GeofencingMapViewController: MKMapViewDelegate {
    
    // Defines how the overlay circle should look like
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

// MARK: Add Delegate Protocol
extension GeofencingMapViewController: AddGeofenceTableViewControllerDelegate {
    
    // Incoming from addGeofence Delegate
    func addGeofenceTableViewController(_ controller: AddGeofenceTableViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, eventType: EventType) {
        controller.dismiss(animated: true, completion: nil)
        let clampedRadius = min(radius, modelController.locationManager.maximumRegionMonitoringDistance)
        let geofence = Geofence(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note, eventType: eventType)
        modelController.geofences.append(geofence)
        addAnnotation(geofence)
        modelController.saveGeofences()
        startMonitoring(geofence: geofence)
    }
}

// Back referencing this Controller and linking the ModelController
extension GeofencingMapViewController: ModelControllerClient {
    func setModeController(modeController: ModelController) {
        self.modelController = modeController
        self.modelController.viewControllers["GeofencingMapViewController"] = self
    }
}
