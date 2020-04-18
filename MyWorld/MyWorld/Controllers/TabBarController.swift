//
//  TabBarController.swift
//  MyWorld
//
//  Created by gabriel on 17/04/20.
//  Copyright © 2020 gabriel. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var world: World?

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        
        world = World(worldRect: CGRect(x: 0, y: 0, width: 4096, height: 2048))
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let _ = viewController as? WorldViewController {
            print("world")
        } else {
            print("outro")
        }
    }
    
    
    

}
