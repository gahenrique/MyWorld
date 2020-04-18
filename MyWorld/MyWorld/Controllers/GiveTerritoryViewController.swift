//
//  GiveTerritoryViewController.swift
//  MyWorld
//
//  Created by gabriel on 18/04/20.
//  Copyright © 2020 gabriel. All rights reserved.
//

import UIKit

protocol GiveTerritoryViewControllerDelegate {
    func giveTerritory(regent: String)
}

class GiveTerritoryViewController: UIViewController {
    
    @IBOutlet weak var regentTextField: UITextField!
    
    var delegate: GiveTerritoryViewControllerDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Give"
                
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Confirm", style: .done, target: self, action: #selector(confirm))
        
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    

    @objc private func confirm() {
        guard let vc = Bundle.main.loadNibNamed("ContractView", owner: nil, options: nil)?.first as? ContractViewController,
            let regentName = regentTextField.text else { return }
        delegate?.giveTerritory(regent: regentName)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func textFieldValueChanged(_ sender: Any) {
        guard let regentName = regentTextField.text else { return }
        navigationItem.rightBarButtonItem?.isEnabled = regentName.count > 0 ? true : false
    }
    
}
