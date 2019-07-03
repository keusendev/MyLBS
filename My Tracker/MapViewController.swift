//
//  SecondViewController.swift
//  My Tracker
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI-CVI on 09.03.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.userTrackingMode = .follow
    }
    
    
}

