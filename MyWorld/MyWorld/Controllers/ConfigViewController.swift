//
//  ConfigViewController.swift
//  MyWorld
//
//  Created by gabriel on 18/04/20.
//  Copyright © 2020 gabriel. All rights reserved.
//

import UIKit

class ConfigViewController: UIViewController {
    
    @IBOutlet weak var ceresButton: UIButton!
    @IBOutlet weak var venusButton: UIButton!
    
    var worldTypeSelected: WorldType = .venus

    override func viewDidLoad() {
        super.viewDidLoad()
        
        venusSelected(self)
    }
    
    @IBAction func ceresSelected(_ sender: Any) {
        ceresButton.backgroundColor = UIColor(red: 188/256, green: 66/256, blue: 66/256, alpha: 1)
        venusButton.backgroundColor = UIColor.clear
        worldTypeSelected = .ceres
    }
    
    @IBAction func venusSelected(_ sender: Any) {
        venusButton.backgroundColor = UIColor(red: 188/256, green: 66/256, blue: 66/256, alpha: 1)
        ceresButton.backgroundColor = UIColor.clear
        worldTypeSelected = .venus
    }
    
    @IBAction func createNewWorld(_ sender: Any) {
        WorldSingleton.shared().createNewWorld(withType: worldTypeSelected)
        tabBarController?.selectedIndex = 0
    }
    
}
