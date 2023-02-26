




//
//  InnerTableViewCell.swift
//  MultipleTableview
//
//  Created by Im043 on 22/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

class InnerTableViewCell: UITableViewCell {
  @IBOutlet weak var namelbl: UILabel!
    @IBOutlet weak var selectBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
