//
//  TerritoriesListViewController.swift
//  MyWorld
//
//  Created by gabriel on 20/04/20.
//  Copyright © 2020 gabriel. All rights reserved.
//

import UIKit

class TerritoriesListViewController: UIViewController {
    
    var world: World {
        get {
            return WorldSingleton.shared().world
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

}

extension TerritoriesListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Regências"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return world.getTerritoriesWithRegent().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TerritoryCell") as! TerritoryCell
        
        let territory = world.territories[world.getTerritoriesWithRegent()[indexPath.row]]
        cell.codeLabel.text = "Código: " + String(territory.code)
        cell.regentLabel.text = "Regente: \(territory.regent!)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let takeAction = UIContextualAction(style: .destructive, title: "Tomar") { (_, _, completionHandler) in
            let territoryIndex = self.world.getTerritoriesWithRegent()[indexPath.row]
            self.world.territories[territoryIndex].hasOwner = false
            tableView.reloadData()
            WorldSingleton.shared().saveWorld()
            completionHandler(true)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [takeAction])
        
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.tintColor = .systemBackground
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 40)
    }
}

extension TerritoriesListViewController: UITableViewDelegate {
}
