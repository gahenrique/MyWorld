//
//  TabBarController.swift
//  MyWorld
//
//  Created by gabriel on 17/04/20.
//  Copyright © 2020 gabriel. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var world: World?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createNewWorld(withType: .venus)
    }
    
    func createNewWorld(withType type: WorldType) {
        world = World(worldRect: CGRect(x: 0, y: 0, width: 4096, height: 2048), type: type)
        
        selectedIndex = 0
        
        guard let worldVC = viewControllers?.first(where: { (vc) -> Bool in
            if let _ = vc as? WorldViewController { return true}
            return false
        }) as? WorldViewController else { return }
        
        worldVC.initWorldView()
    }
}
