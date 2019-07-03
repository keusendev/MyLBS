//
//  AddGeofenceTableViewController.swift
//  My LBS
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI on 29.06.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import UIKit
import MapKit

// Delegate Protocol to notify AppDelegate instance if a new fence needs to be registered or de-registered.
protocol AddGeofenceTableViewControllerDelegate {
    func addGeofenceTableViewController(_ controller: AddGeofenceTableViewController, didAddCoordinate coordinate: CLLocationCoordinate2D,
                                        radius: Double, identifier: String, note: String, eventType: EventType)
}

class AddGeofenceTableViewController: UITableViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var eventTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sliderRadius: UISlider!
    
    var delegate: AddGeofenceTableViewControllerDelegate?
    
    var tempCounter: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.isEnabled = false
        mapView.delegate = self
    }
    
    // Unselects a tapped row automatically and animated
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) != nil{
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // Removing view from stack and go back to former view
    @IBAction func onCancel(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func zoomToCurrentLocation(sender: AnyObject) {
        mapView.zoomToUserLocation()
    }
    
    @IBAction func textFieldEditingChanged(sender: UITextField) {
        addButton.isEnabled = !radiusTextField.text!.isEmpty && !noteTextField.text!.isEmpty
        updateRadius()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        radiusTextField.text = Int(sender.value).description
        updateRadius()
    }
    
    @IBAction func radiusValueChanged(_ sender: UITextField) {
        updateRadius()
    }
    
    // Catch all important date to add a new fence and trigger delegate
    @IBAction private func onAdd(sender: AnyObject) {
        let coordinate = mapView.centerCoordinate
        let radius = Double(radiusTextField.text!) ?? 0
        let identifier = NSUUID().uuidString
        let note = noteTextField.text
        let eventType: EventType = (eventTypeSegmentedControl.selectedSegmentIndex == 0) ? .onEntry : .onExit
        delegate?.addGeofenceTableViewController(self, didAddCoordinate: coordinate, radius: radius, identifier: identifier, note: note!, eventType: eventType)
    }
    
    // Remove old overlay circle item and add the new one
    func updateRadius() {
        mapView.removeOverlays(mapView.overlays)
        
        let rad = Double(radiusTextField.text!) ?? 100
        let center = mapView.centerCoordinate
        let circle = MKCircle(center: center, radius: rad)
        mapView.addOverlay(circle)
    }
    
    // Sometimes it is useful to have satelite view to set a Geofence. This method toggles the view from normal to satellite and back.
    @IBAction func changedMapStyle(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = MKMapType.standard
        case 1:
            mapView.mapType = MKMapType.satellite
        default:
            mapView.mapType = MKMapType.standard
        }
    }
}

// MapKit delegate methods
extension AddGeofenceTableViewController: MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        updateRadius()
    }
    
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
