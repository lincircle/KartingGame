//
//  SettingTableViewCell.swift
//  KartingGame
//
//  Created by Yuhsuan Lin on 2017/6/11.
//  Copyright © 2017年 cgua. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title_label: UILabel!
    
    @IBOutlet weak var icon_img: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
