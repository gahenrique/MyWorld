//
//  WorldView.swift
//  MyWorld
//
//  Created by gabriel on 16/04/20.
//  Copyright © 2020 gabriel. All rights reserved.
//

import UIKit

class WorldView: UIView {

    func drawLayer(layer: CAShapeLayer) {
        guard let subLayers = self.layer.sublayers, !subLayers.contains(layer) else { return }
        self.layer.addSublayer(layer)
    }

}
