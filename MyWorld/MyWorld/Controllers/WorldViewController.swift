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
    
    var territories: [Territory] = []
    var finalLayers: [CAShapeLayer] = []
    var finalDiagram: Diagram!
    var availableArea: CGFloat! {
        didSet {
            // Corrigindo um pequeno erro de precisao evitando label com -0.00
            if availableArea < 0 { availableArea = 0 }
            availableAreaLbl.text = "Available area: " + String(format: "%.2f", availableArea)
        }
    }
    
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
        
        createTerritories()
    }
    
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        let loc = recognizer.location(in: worldView)
        if !worldView.bounds.contains(loc) { return }

        var minIndex: Int = Int.max
        var minDistance: CGFloat = CGFloat.infinity
        for i in 0..<territories.count {
            let distanceValue = distance(territories[i].site, loc)
            if distanceValue < minDistance { minIndex = i; minDistance = distanceValue }
        }
        
        let territory = territories[minIndex]
        if !territory.hasOwner {
            territory.hasOwner.toggle()
            territory.layer.fillColor = CGColor(srgbRed: 255, green: 0, blue: 0, alpha: 0.5)
            availableArea -= territory.area
        }
    }
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    
    func createTerritories() {
        let fortuneSweep = FortuneSweep()
        var diagram = Diagram()
        let clippingRect = Rectangle(
            origin: Vertex(x: 0, y: 0),
            size: Size(width: Double(self.worldView.bounds.size.width), height: Double(self.worldView.bounds.size.height))
        )
        
        let sitesNumber = Int.random(in: 20...40)
        var sites = Set<Site>()
        
        for _ in 0..<sitesNumber {
            let randX = Double.random(in: clippingRect.origin.x..<clippingRect.width)
            let randY = Double.random(in: clippingRect.origin.x..<clippingRect.height)
            let s = Site(x: randX, y: randY)
            
            sites.insert(s)
        }
        
        if !fortuneSweep.compute(
            sites: sites,
            diagram: &diagram,
            clippingRect: clippingRect
            ) { return }
        
        finalDiagram = diagram
        
        for cell in diagram.cells {
            let cellVertices = cell.hullVerticesCCW()
            var vertices: [CGPoint] = []
            
            for cellV in cellVertices {
                vertices.append(CGPoint(x: cellV.x, y: cellV.y))
            }
            
            let territory = Territory(site: CGPoint(x: cell.site.x, y: cell.site.y),
                                      vertices: vertices)
            territories.append(territory)
            self.worldView.layer.addSublayer(territory.layer)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}

extension WorldViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return worldView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}

class Territory {
    var site: CGPoint
    var area: CGFloat
    var centroid: CGPoint
    var vertices: [CGPoint]
    var layer: CAShapeLayer
    var hasOwner: Bool = false
    
    /*
     Returns:
     -1 -> counter clockwise
     0  -> colinear
     1  -> clockwise
     */
    func getPolygonOrientation(points: [CGPoint]) -> Int {
        let val = (points[1].y - points[0].y) * (points[2].x - points[1].x) -
            (points[1].x - points[0].x) * (points[2].y - points[1].y);
        
        if val == 0 { return 0 }
        
        return (val > 0) ? -1 : 1
    }
    
    init(site: CGPoint, vertices: [CGPoint]) {
        self.site = site
        self.vertices = vertices
        self.vertices.append(self.vertices[0])
        self.centroid = CGPoint()
        self.area = 0
        self.layer = CAShapeLayer()
        
        self.createLayer(territoryColor: UIColor.clear.cgColor,
                         lineColor: CGColor(srgbRed: 255, green: 195, blue: 11, alpha: 0.8))
        
        if getPolygonOrientation(points: self.vertices) == 1 {
            print("clockwise")
            self.vertices.reverse()
        }
        
        self.calculatePolygon()
    }
    
    func calculatePolygon() {
        var tmp: CGFloat = 0
        
        for i in 0 ..< vertices.count - 1 {
            tmp = vertices[i].x * vertices[i+1].y - vertices[i+1].x * vertices[i].y
            area += tmp
            centroid.x += (vertices[i].x + vertices[i+1].x) * tmp;
            centroid.y += (vertices[i].y + vertices[i+1].y) * tmp;
        }
        
        area /= 2
        
        centroid.x *= (1 / (6*area))
        centroid.y *= (1 / (6*area))
        
        area = abs(area)
    }
    
    func createLayer(territoryColor: CGColor, lineColor: CGColor) {
        let path = UIBezierPath()
        path.move(to: vertices[0])
        for v in vertices {
            path.addLine(to: CGPoint(x: v.x, y: v.y))
        }
        
        layer = CAShapeLayer()
        
        layer.path = path.cgPath
        layer.fillColor = territoryColor
        layer.strokeColor = lineColor
        layer.lineWidth = 3
    }

}
