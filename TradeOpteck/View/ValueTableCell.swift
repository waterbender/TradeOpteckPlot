//
//  ValueTableCell.swift
//  TradeOpteck
//
//  Created by Yevgenii Pasko on 4/26/18.
//  Copyright © 2018 Yevgenii Pasko. All rights reserved.
//

import UIKit

class ValueTableCell: UITableViewCell {

    @IBOutlet weak var instrument: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var change: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setParameters(dict: [String:String]) {
     
        let num = dict[Constants.CellChangeTD]
        instrument.text = dict[Constants.CellAssetName]
        rate.text = dict.keys.contains(Constants.CellSellTdUp) ? dict[Constants.CellSellTdUp] : dict[Constants.CellSellTdDown]
        change.text = num
        if (num?.contains("-") ?? false) {
            rate.textColor = UIColor.red
        } else {
            rate.textColor = UIColor.green
        }
    }

}
