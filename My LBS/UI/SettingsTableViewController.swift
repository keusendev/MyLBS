//
//  SettingsTableViewController.swift
//  My LBS
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI on 22.06.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import UIKit

protocol SettingsDelegate: AnyObject {
    func didChangeSettings()
}

class SettingsTableViewController: UITableViewController {
    
    var modelController: ModelController!
    weak var delegate: SettingsDelegate?
    
    @IBOutlet weak var hostText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var saveConfigButton: UIButton!
    @IBOutlet weak var deviceIdText: UITextField!
    @IBOutlet weak var visitTrackingSwitch: UISwitch!
    @IBOutlet weak var significantPosTrackingSwitch: UISwitch!
    @IBOutlet weak var consoleOutputLabel: UILabel!
    
    var saveConfigButtonEnabledState: buttonState = .disable
    
    enum buttonState: Int {
        case enable = 0
        case disable = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Needed for autogrow of table rows
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        // Update view elements with app parameters
        hostText.text = modelController.myLbsSettings.host
        usernameText.text = modelController.myLbsSettings.username
        passwordText.text = modelController.myLbsSettings.password
        deviceIdText.text = modelController.myLbsSettings.deviceId
        visitTrackingSwitch.isOn = modelController.myLbsSettings.visitTrackingEnabled
        significantPosTrackingSwitch.isOn = modelController.myLbsSettings.significantPositionTrackingEnabled
        
        setSaveConfigButtonEnableState(.disable)
    }

    // Unselects a tapped row automatically and animated
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) != nil{
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    // Toggle if save button is active or inactive. Only if settings are new the button becomes active.
    func setSaveConfigButtonEnableState(_ newState: buttonState) {
        switch newState {
        case .enable:
            saveConfigButton.isEnabled = true
        case .disable:
            saveConfigButton.isEnabled = false
        }
    }
    
    // Updating values... Check if save button needs to be activated
    @IBAction func updateHost() {
        if (modelController.myLbsSettings.host != hostText.text) {
            setSaveConfigButtonEnableState(.enable)
        } else {
            setSaveConfigButtonEnableState(.disable)
        }
    }
    
    // Updating values... Check if save button needs to be activated
    @IBAction func updateUsername() {
        if (modelController.myLbsSettings.username != usernameText.text) {
            setSaveConfigButtonEnableState(.enable)
        } else {
            setSaveConfigButtonEnableState(.disable)
        }
    }
    
    // Updating values... Check if save button needs to be activated
    @IBAction func updatePassword() {
        if (modelController.myLbsSettings.password != passwordText.text) {
            setSaveConfigButtonEnableState(.enable)
        } else {
            setSaveConfigButtonEnableState(.disable)
        }
    }
    
    // Updating values... Check if save button needs to be activated
    @IBAction func updateDeviceId() {
        if (modelController.myLbsSettings.deviceId != deviceIdText.text) {
            setSaveConfigButtonEnableState(.enable)
        } else {
            setSaveConfigButtonEnableState(.disable)
        }
    }
    
    // Save new settings and store config on disk. Via delegate AppDelegate gets informed that eventually services needed to be started or stopped.
    @IBAction func saveConfig() {
        modelController.myLbsSettings.host = hostText.text!
        modelController.myLbsSettings.username = usernameText.text!
        modelController.myLbsSettings.password = passwordText.text!
        modelController.myLbsSettings.deviceId = deviceIdText.text!
        modelController.myLbsSettings.visitTrackingEnabled = visitTrackingSwitch.isOn
        modelController.myLbsSettings.significantPositionTrackingEnabled = significantPosTrackingSwitch.isOn
        modelController.saveMyLbsConfig()
        delegate?.didChangeSettings()
        setSaveConfigButtonEnableState(.disable)
    }
    
    // Fanzy shit :)  Little console print-outs for debugging purposes.
    @IBAction func print2Console() {
        let text: String = """
        \(modelController.myLbsSettings)
        
        active fences: \(modelController.locationManager.monitoredRegions.count)
        
        loc mon: \(modelController.locationManager.monitoredRegions)
        """
        print(text)
        consoleOutputLabel.text = text
        tableView.reloadData()
    }
    
    // Option to enable/disable CLVisit tracking
    @IBAction func toggleVisitTrackingEnabled(_ sender: UISwitch) {
        visitTrackingSwitch.isOn = sender.isOn
        
        if (modelController.myLbsSettings.visitTrackingEnabled != visitTrackingSwitch.isOn) {
            setSaveConfigButtonEnableState(.enable)
        } else {
            setSaveConfigButtonEnableState(.disable)
        }
    }
    
    // Option to enable/disable Significant Position tracking
    @IBAction func toggleSignificantPosTrackingEnabled(_ sender: UISwitch) {
        significantPosTrackingSwitch.isOn = sender.isOn
        
        if (modelController.myLbsSettings.significantPositionTrackingEnabled != significantPosTrackingSwitch.isOn) {
            setSaveConfigButtonEnableState(.enable)
        } else {
            setSaveConfigButtonEnableState(.disable)
        }
    }
}

// Back referencing this Controller and linking the ModelController
extension SettingsTableViewController: ModelControllerClient {
    func setModeController(modeController: ModelController) {
        self.modelController = modeController
        self.modelController.viewControllers["SettingsTableViewController"] = self
    }
}
