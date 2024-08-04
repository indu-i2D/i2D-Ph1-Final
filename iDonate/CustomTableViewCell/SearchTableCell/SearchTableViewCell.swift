//
//  SearchTableViewCell.swift
//  i2-Donate

import UIKit

import UIKit

/// Custom table view cell for search results.
class SearchTableViewCell: UITableViewCell {
    /// Outlet for the title label.
    @IBOutlet var title: UILabel!
    /// Outlet for the address label.
    @IBOutlet var address: UILabel!
    /// Outlet for the logo image view.
    @IBOutlet var logoImage: UIImageView!
    /// Outlet for the like button.
    @IBOutlet var likeBtn: UIButton!
    /// Outlet for the following button.
    @IBOutlet var followingBtn: UIButton!
    /// Outlet for the donate button.
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
