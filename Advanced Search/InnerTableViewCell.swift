//
// InnerTableViewCell.swift
// MultipleTableview

//

import UIKit

/// Custom table view cell for displaying inner categories.
class InnerTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var namelbl: UILabel!
    @IBOutlet weak var selectBtn: UIButton!
    
    // MARK: - Lifecycle Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Additional setup can be done here if needed
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

