//
//  WorldSingleton.swift
//  MyWorld
//
//  Created by gabriel on 17/04/20.
//  Copyright © 2020 gabriel. All rights reserved.
//

import FortunesAlgorithm
import UIKit
import CoreData

protocol WorldSingletonDelegate {
    func worldChanged()
    func worldCreated()
}

class WorldSingleton {
    private static var _shared = WorldSingleton()
    
    var delegate: WorldSingletonDelegate?
    var world: World!
    
    private init() {
        guard let worldSaved = getSavedWorld() else {
            world = World(type: .venus)
            saveWorld()
            return
        }
        world = worldSaved        
    }
    
    class func shared() -> WorldSingleton {
        return _shared
    }
        
    func saveWorld() {
        let defaults = UserDefaults.standard
        defaults.set(try? PropertyListEncoder().encode(world), forKey: "world")
        delegate?.worldChanged()
    }
    
    private func getSavedWorld() -> World? {
        let defaults = UserDefaults.standard
        guard let worldData = defaults.object(forKey: "world") as? Data else {
            return nil
        }
        
        guard let world = try? PropertyListDecoder().decode(World.self, from: worldData) else {
            return nil
        }
            
        return world
    }
    
    func createNewWorld(withType type: WorldType) {
        self.world = World(type: type)
        saveWorld()
        delegate?.worldCreated()
    }
}
