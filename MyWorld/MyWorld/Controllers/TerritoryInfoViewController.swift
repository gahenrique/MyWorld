//
//  TerritoryInfoViewController.swift
//  MyWorld
//
//  Created by gabriel on 17/04/20.
//  Copyright © 2020 gabriel. All rights reserved.
//

import UIKit

protocol TerritoryInfoViewControllerDelegate {
    func loadTerritoryInfo(completion: (_ territory: Territory, _ territoryLayer: CAShapeLayer) -> Void)
}

class TerritoryInfoViewController: UIViewController {
    
    @IBOutlet weak var territoryView: UIView!
    @IBOutlet weak var ownerLbl: UILabel!
    @IBOutlet weak var totalAreaLbl: UILabel!
    @IBOutlet weak var codeLbl: UILabel!
    
    var delegate: TerritoryInfoViewControllerDelegate?
    var territory: Territory!
    var territoryLayer: CAShapeLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Info"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Fechar", style: .done, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Atribuir", style: .plain, target: self, action: #selector(give))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        delegate?.loadTerritoryInfo(completion: { (territory, territoryLayer) in
            self.territory = territory
            self.territoryLayer = territoryLayer
        })
        
        codeLbl.text = "Código: \(territory.code)"
        totalAreaLbl.text = "Área total: " + String(format: "%.2f", territory.area) + "km²"
        if territory.hasOwner {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Tomar", style: .done, target: self, action: #selector(take))
            ownerLbl.textColor = .label
            ownerLbl.text = "Regente: " + territory.regent!
        }
        guard let territorySize = territoryLayer.path?.boundingBox.size else { return }
        DispatchQueue.main.async {
            self.drawTerritory(vertices: self.territory.vertices, size: territorySize)
        }        
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func give() {
        let alert = UIAlertController(title: "Atribuir regente",
                                      message: "Máximo 20 caracteres",
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        let confirmAction = UIAlertAction(title: "Confirmar", style: .default) { (action) in
            // Limitando o nome para 20 caracteres
            guard let regentName = alert.textFields?.first?.text,
                !regentName.isEmpty,
                regentName.count <= 20 else { return }
            
            guard let contractVC = Bundle.main.loadNibNamed("ContractView", owner: nil, options: nil)?.first as? ContractViewController else { return }
            
            contractVC.delegate = self
            
            if !self.territory.hasOwner {
                self.territory.regent = regentName
                
                self.territory.hasOwner = true
                
                WorldSingleton.shared().saveWorld()
            }
            
            self.navigationController?.pushViewController(contractVC, animated: true)
        }
        
        alert.addTextField()
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        present(alert, animated: true)
    }
    
    @objc func take() {
        territory.hasOwner = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Atribuir", style: .plain, target: self, action: #selector(give))
        ownerLbl.text = "Nenhum regente"
        ownerLbl.textColor = UIColor.systemRed
        WorldSingleton.shared().saveWorld()
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

extension TerritoryInfoViewController: ContractViewControllerDelegate {
    func setup(_ completion: (Territory) -> Void) {
        completion(territory)
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
}
