//
//  FirstViewController.swift
//  My Tracker
//
//  Created by Keusen Alain, INI-ONE-CIS-CLI-CVI on 09.03.19.
//  Copyright © 2019 Keusen DEV. All rights reserved.
//

import UIKit

class PositionTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PositionsStorage.shared.positions.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "PositionTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PositionTableViewCell else {
            fatalError("The dequeued cell is not an instance of PositionTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let position = PositionsStorage.shared.positions[indexPath.row]
        
        cell.nameLabel.text = position.description
        cell.detailLabel.text = position.dateString
        
        return cell
    }
    
    // MARK: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "ShowDetail":
            guard let positionDetailViewController = segue.destination as? PositionDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedPositionCell = sender as? PositionTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedPositionCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedPosition = PositionsStorage.shared.positions[indexPath.row]
            positionDetailViewController.position = selectedPosition
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
}

