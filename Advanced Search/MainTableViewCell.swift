//
//  MainTableViewCell.swift
//  MultipleTableview
//
//  Created by Im043 on 22/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {
   @IBOutlet weak var innerTableView: UITableView!
    @IBOutlet weak var namelbl: UILabel!
     @IBOutlet weak var mainIMage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
     

        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("reload"), object: nil)

        // Initialization code
    }
    @IBOutlet weak var heightCOnstriant: NSLayoutConstraint!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.mainIMage.image = UIImage(named: "minus")
            
        } else {
           self.mainIMage.image = UIImage(named: "plus")
        }
        // Configure the view for the selected state
    }
@objc func methodOfReceivedNotification(notification: Notification) {
     innerTableView .reloadData()
    }
}
extension MainTableViewCell
{
    func setTableViewDataSourceDelegate<D:UITableViewDelegate & UITableViewDataSource>(_dataSourceDelegate: D, forRow row:Int)
    {
        innerTableView.dataSource = _dataSourceDelegate
        innerTableView.delegate = _dataSourceDelegate
        innerTableView .reloadData()
    }
}
