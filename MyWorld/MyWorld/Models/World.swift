//
//  World.swift
//  MyWorld
//
//  Created by gabriel on 17/04/20.
//  Copyright © 2020 gabriel. All rights reserved.
//

import FortunesAlgorithm
import UIKit

public class World {
    var territories: [Territory] = []
    var worldRect: CGRect
    
    init(worldRect: CGRect) {
        self.worldRect = worldRect
        
        createTerritories()
    }
    
    private func createTerritories() {
        let fortuneSweep = FortuneSweep()
        var diagram = Diagram()
        let clippingRect = Rectangle(
            origin: Vertex(x: 0, y: 0),
            size: Size(width: Double(worldRect.size.width), height: Double(worldRect.size.height))
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
                
        var territoryCode = 1
        for cell in diagram.cells {
            let cellVertices = cell.hullVerticesCCW()
            var vertices: [CGPoint] = []
            
            for cellV in cellVertices {
                vertices.append(CGPoint(x: cellV.x, y: cellV.y))
            }
            
            let territory = Territory(code: territoryCode, site: CGPoint(x: cell.site.x, y: cell.site.y),
                                      vertices: vertices)
            territories.append(territory)
            territoryCode += 1
        }
    }
    
    func getClosestTerritory(point: CGPoint) -> Territory {
        var minIndex: Int = Int.max
        var minDistance: CGFloat = CGFloat.infinity
        for i in 0..<territories.count {
            let distanceValue = distance(territories[i].site, point)
            if distanceValue < minDistance { minIndex = i; minDistance = distanceValue }
        }
        return territories[minIndex]
    }
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
}

class Territory {
    var code: Int
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
    
    init(code: Int, site: CGPoint, vertices: [CGPoint]) {
        self.code = code
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
