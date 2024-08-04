//
//  TransactionHistoryTableViewCell.swift
//  i2-Donate
//


import UIKit
///cell class to show transactions in table
class TransactionHistoryTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel! // Label to display the title of the donation
    @IBOutlet weak var dateLabel: UILabel! // Label to display the date of the donation
    @IBOutlet weak var amountLabel: UILabel! // Label to display the amount of the donation
    @IBOutlet weak var paymentModeLabel: UILabel! // Label to display the payment mode of the donation
    
    // MARK: - Lifecycle Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
