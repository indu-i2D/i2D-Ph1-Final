//
//  BusinessRegCell.swift
//  i2-Donate
//

import UIKit

/// A custom table view cell used in the i2-Donate app for business registration.
class BusinessRegCell: UITableViewCell {

    /// Called when the cell is loaded from the nib file.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Create and configure a background image view.
        let bgImage = UIImageView(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height))
        bgImage.image = UIImage(named: "backgrounimage")
        
        // Add the background image view to the cell's content view.
        self.contentView.addSubview(bgImage)
    }

    /// Configures the view for the selected state.
    ///
    /// - Parameters:
    ///   - selected: A Boolean value indicating whether the cell is selected.
    ///   - animated: A Boolean value indicating whether the selection is animated.
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
