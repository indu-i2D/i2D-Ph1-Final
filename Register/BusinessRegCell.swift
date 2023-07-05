//
//  BusinessRegCell.swift
//  i2-Donate
//
//

import UIKit

class BusinessRegCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let bgImage = UIImageView(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height))
        bgImage.image = UIImage(named: "backgrounimage")
        self.contentView.addSubview(bgImage)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
