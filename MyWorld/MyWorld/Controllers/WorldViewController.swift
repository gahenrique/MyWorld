//
//  WorldViewController.swift
//  MyWorld
//
//  Created by gabriel on 16/04/20.
//  Copyright © 2020 gabriel. All rights reserved.
//

import UIKit
import FortunesAlgorithm

class WorldViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var worldView: WorldView!
    @IBOutlet weak var availableAreaLbl: UILabel!
    
    var world: World? {
        get {
            guard let tabBarController = tabBarController as? TabBarController else { return nil }
            return tabBarController.world
        }
    }
    var territories: [Territory] = []
    var finalDiagram: Diagram!
    var availableArea: CGFloat! {
        didSet {
            // Corrigindo um pequeno erro de precisao evitando label com -0.00
            if availableArea < 0 { availableArea = 0 }
            availableAreaLbl.text = "Available area: " + String(format: "%.2f", availableArea)
        }
    }
    var selectedTerritory: Territory?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        singleTap.cancelsTouchesInView = false
        singleTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(singleTap)
        scrollView.delegate = self
        let minZoom = scrollView.bounds.width / worldView.bounds.width
        scrollView.minimumZoomScale = CGFloat(minZoom)
        scrollView.maximumZoomScale = CGFloat(4)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        
        availableArea = worldView.bounds.width * worldView.bounds.height
        
        drawTerritories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        let loc = recognizer.location(in: worldView)
        if !worldView.bounds.contains(loc) { return }

        let territory = world?.getClosestTerritory(point: loc)
        selectedTerritory = territory
        
        guard let vc = Bundle.main.loadNibNamed("TerritoryInfoView", owner: self, options: nil)?.first as? TerritoryInfoViewController else {return}
        vc.delegate = self
        let navigationController = UINavigationController(rootViewController: vc)
        present(navigationController, animated: true, completion: nil)
    }
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    
    func drawTerritories() {
        guard let world = world else {return}
        for territory in world.territories {
            worldView.layer.addSublayer(territory.layer)
        }
    }

}

extension WorldViewController: UIScrollViewDelegate, TerritoryInfoViewControllerDelegate {
    func giveTerritory() {
        guard let selectedTerritory = selectedTerritory else {return}
        if !selectedTerritory.hasOwner {
            selectedTerritory.hasOwner.toggle()
            selectedTerritory.layer.fillColor = CGColor(srgbRed: 255, green: 0, blue: 0, alpha: 0.5)
            
            availableArea -= selectedTerritory.area
        }
    }
    
    func loadTerritoryInfo(completion: (Territory) -> Void) {
        guard let selectedTerritory = selectedTerritory else {return}
        completion(selectedTerritory)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return worldView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}
