//
// MainTableViewCell.swift
// MultipleTableview
import UIKit

/// Custom table view cell for displaying main categories.
class MainTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var innerTableView: UITableView!
    @IBOutlet weak var namelbl: UILabel!
    @IBOutlet weak var mainIMage: UIImageView!
    @IBOutlet weak var heightCOnstriant: NSLayoutConstraint!
    
    // MARK: - Lifecycle Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Register to receive notification to reload inner table view data
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("reload"), object: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Update main image based on cell selection
        if selected {
            self.mainIMage.image = UIImage(named: "minus")
        } else {
            self.mainIMage.image = UIImage(named: "plus")
        }
    }
    
    // MARK: - Notification Handling
    
    /// Method called when a notification to reload data is received.
    @objc func methodOfReceivedNotification(notification: Notification) {
        innerTableView.reloadData()
    }
}

// MARK: - Extension

extension MainTableViewCell {
    
    /// Sets the data source and delegate for the inner table view.
    ///
    /// - Parameters:
    ///   - _dataSourceDelegate: The delegate and data source for the inner table view.
    ///   - row: The row index of the main table view.
    func setTableViewDataSourceDelegate<D:UITableViewDelegate & UITableViewDataSource>(_dataSourceDelegate: D, forRow row:Int) {
        innerTableView.dataSource = _dataSourceDelegate
        innerTableView.delegate = _dataSourceDelegate
        innerTableView.reloadData()
    }
}

