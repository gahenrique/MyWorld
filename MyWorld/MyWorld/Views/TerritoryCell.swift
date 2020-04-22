//
//  TerritoryCell.swift
//  MyWorld
//
//  Created by gabriel on 20/04/20.
//  Copyright © 2020 gabriel. All rights reserved.
//

import UIKit

class TerritoryCell: UITableViewCell {
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var regentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
