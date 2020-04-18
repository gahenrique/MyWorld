//
//  TerritoryInfoViewController.swift
//  MyWorld
//
//  Created by gabriel on 17/04/20.
//  Copyright © 2020 gabriel. All rights reserved.
//

import UIKit

protocol TerritoryInfoViewControllerDelegate {
    func loadTerritoryInfo(completion: (_ territory: Territory) -> Void)
    func giveTerritory(regent: String)
}

class TerritoryInfoViewController: UIViewController {
    
    @IBOutlet weak var territoryView: UIView!
    @IBOutlet weak var ownerLbl: UILabel!
    @IBOutlet weak var totalAreaLbl: UILabel!
    @IBOutlet weak var codeLbl: UILabel!
    
    var delegate: TerritoryInfoViewControllerDelegate?
    var territory: Territory!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Info"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Give", style: .plain, target: self, action: #selector(give))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        delegate?.loadTerritoryInfo(completion: { (territory) in
            self.territory = territory
        })
        
        codeLbl.text = "Código: \(territory.code)"
        totalAreaLbl.text = "Área total: " + String(format: "%.2f", territory.area)
        if territory.hasOwner {
            navigationItem.rightBarButtonItem?.isEnabled = false
//            ownerLbl.font = UIFont.systemFont(ofSize: 17)
            ownerLbl.textColor = .label
            ownerLbl.text = "Regente: " + territory.regent!
        }
        guard let territorySize = territory.layer.path?.boundingBox.size else { return }
        DispatchQueue.main.async {
            self.drawTerritory(vertices: self.territory.vertices, size: territorySize)
        }
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func give() {
        //        delegate?.giveTerritory()
        //        navigationItem.rightBarButtonItem?.isEnabled = false
        
        guard let vc = Bundle.main.loadNibNamed("GiveTerritoryView", owner: nil, options: nil)?.first as? GiveTerritoryViewController else {return}
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    private func drawTerritory(vertices: [CGPoint], size: CGSize) {
        if let _ = territoryView.layer.sublayers { return }
        let path = UIBezierPath()
        let offsetTerritoryView: CGSize = CGSize(width: territoryView.bounds.width * 0.8, height: territoryView.bounds.height * 0.8)
        let targetSize: CGSize = CGSize.aspectFit(size, offsetTerritoryView)
        let origin: CGPoint = getTopLeftOrigin(vertices: vertices)
        
        var newX = targetSize.width * ((vertices[0].x - origin.x) / size.width)
        var newY = targetSize.height * ((vertices[0].y - origin.y) / size.height)
        var newVertex = CGPoint(x: newX, y: newY)
        path.move(to: newVertex)
        for v in vertices {
            newX = targetSize.width * ((v.x - origin.x) / size.width)
            newY = targetSize.height * ((v.y - origin.y) / size.height)
            newVertex = CGPoint(x: newX, y: newY)
            path.addLine(to: newVertex)
        }
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        guard let layerPath = layer.path else { return }
        layer.lineWidth = 3
        layer.strokeColor = UIColor.systemYellow.cgColor
        
        let offsetX = territoryView.bounds.midX - layerPath.boundingBox.midX
        let offsetY = territoryView.bounds.midY - layerPath.boundingBox.midY
        
        layer.position.x += offsetX
        layer.position.y += offsetY
        territoryView.layer.addSublayer(layer)
    }
    
    private func getTopLeftOrigin(vertices: [CGPoint]) -> CGPoint {
        var origin: CGPoint = CGPoint(x: CGFloat.infinity, y: CGFloat.infinity)
        for v in vertices {
            if v.x < origin.x { origin.x = v.x }
            if v.y < origin.y { origin.y = v.y }
        }
        return origin
    }
}

extension TerritoryInfoViewController: GiveTerritoryViewControllerDelegate {
    func giveTerritory(regent: String) {
        delegate?.giveTerritory(regent: regent)
    }
}

extension CGSize {
    static func aspectFit(_ aspectRatio : CGSize, _ boundingSize: CGSize) -> CGSize {
        let aspectRatio = aspectRatio
        var boundingSize = boundingSize
        
        let mW = boundingSize.width / aspectRatio.width;
        let mH = boundingSize.height / aspectRatio.height;
        
        if( mH < mW ) {
            boundingSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width;
        }
        else if( mW < mH ) {
            boundingSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height;
        }
        
        return boundingSize;
    }
    
    static func aspectFill(_ aspectRatio :CGSize, _ minimumSize: CGSize) -> CGSize {
        let aspectRatio = aspectRatio
        var minimumSize = minimumSize
        
        let mW = minimumSize.width / aspectRatio.width;
        let mH = minimumSize.height / aspectRatio.height;
        
        if( mH > mW ) {
            minimumSize.width = minimumSize.height / aspectRatio.height * aspectRatio.width;
        }
        else if( mW > mH ) {
            minimumSize.height = minimumSize.width / aspectRatio.width * aspectRatio.height;
        }
        
        return minimumSize;
    }
}
