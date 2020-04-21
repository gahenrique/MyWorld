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
    @IBOutlet weak var availableAreaView: UIView!
    @IBOutlet weak var availableAreaLbl: UILabel!
    @IBOutlet weak var worldImage: UIImageView!
    @IBOutlet weak var centralizeBackgroundView: UIView!
    
    var world: World {
        get {
            return WorldSingleton.shared().world
        }
    }
    var loadedWorld: UUID?
    var territoriesLayers: [CAShapeLayer] = []
    var finalDiagram: Diagram!
    var availableArea: CGFloat {
        get {
            return world.getAvailableArea()
        }
    }
    var selectedTerritory: Territory?
    var selectedTerritoryLayer: CAShapeLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WorldSingleton.shared().delegate = self
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        singleTap.cancelsTouchesInView = false
        singleTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(singleTap)
        scrollView.delegate = self
        let ratioWidth = scrollView.bounds.width / worldView.bounds.width
        let ratioHeight = scrollView.bounds.height / worldView.bounds.height
        let minZoom = min(ratioWidth, ratioHeight)
        scrollView.minimumZoomScale = CGFloat(minZoom)
        scrollView.maximumZoomScale = CGFloat(4)
        
        
        availableAreaView.layer.cornerRadius = 10
        centralizeBackgroundView.layer.cornerRadius = 10
        
        initLayers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initWorldView()
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        let loc = recognizer.location(in: worldView)
        if !worldView.bounds.contains(loc) { return }
        
        let index = world.getClosestTerritory(point: loc)
        selectedTerritory = world.territories[index]
        selectedTerritoryLayer = territoriesLayers[index]
        
        guard let vc = Bundle.main.loadNibNamed("TerritoryInfoView", owner: nil, options: nil)?.first as? TerritoryInfoViewController else {return}
        vc.delegate = self
        let navigationController = UINavigationController(rootViewController: vc)
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func centralizeWorld(_ sender: Any) {
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
    }
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    
    func initWorldView() {
        if world.type == .venus { worldImage.image = UIImage(named: "venus2d") }
        else if world.type == .ceres { worldImage.image = UIImage(named: "ceres2d") }
        
        availableAreaLbl.text = "Área disponível: " + String(format: "%.2f", availableArea) + "km²"
        
        drawTerritories()
    }
    
    private func initLayers() {
        territoriesLayers.removeAll()
        
        for territory in world.territories {
            let territoryColor = territory.hasOwner ? CGColor(srgbRed: 255, green: 0, blue: 0, alpha: 0.5) : UIColor.clear.cgColor
            let layer = createTerritoryLayer(vertices: territory.vertices , territoryColor: territoryColor, lineColor: CGColor(srgbRed: 0, green: 0, blue: 255, alpha: 0.8))
            territoriesLayers.append(layer)
        }
    }
    
    private func createTerritoryLayer(vertices: [CGPoint] , territoryColor: CGColor, lineColor: CGColor) -> CAShapeLayer{
        let layer = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: vertices[0])
        for v in vertices {
            path.addLine(to: CGPoint(x: v.x, y: v.y))
        }
        
        layer.path = path.cgPath
        layer.fillColor = territoryColor
        layer.strokeColor = lineColor
        layer.lineWidth = 3
        
        return layer
    }
    
    func drawTerritories() {
        for layer in territoriesLayers {
            worldView.layer.addSublayer(layer)
        }
    }
}

extension WorldViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return worldView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) / 2, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) / 2, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}

extension WorldViewController: TerritoryInfoViewControllerDelegate {
    func loadTerritoryInfo(completion: (Territory, CAShapeLayer) -> Void) {
        guard let selectedTerritory = selectedTerritory else { return }
        guard let selectedTerritoryLayer = selectedTerritoryLayer else { return }
        completion(selectedTerritory, selectedTerritoryLayer)
    }
}

extension WorldViewController: WorldSingletonDelegate {
    func worldCreated() {
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
    }
    
    func worldChanged() {
        guard let subLayersCount = worldView.layer.sublayers?.count else { return }
        worldView.layer.sublayers?.removeLast(subLayersCount - 1)
        initLayers()
        initWorldView()
    }
}
