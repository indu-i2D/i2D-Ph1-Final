//
//  SearchTableViewCell.swift
//  iDonate
//
//  Created by Im043 on 13/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var logoImage: UIImageView!
    @IBOutlet var likeBtn: UIButton!
    @IBOutlet var followingBtn: UIButton!
     @IBOutlet var donateBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
