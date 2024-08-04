//
//  MyDonationsViewController.swift
//  iDonate
//
//  Created by PPC-INDIA on 25/10/20.
//  Copyright © 2020 Im043. All rights reserved.
//

import UIKit
import Alamofire
/// `MyDonationsViewController`: This view controller manages the user's donation history.
///
/// This view controller fetches the user's donation history from the server and displays it in a table view.
///
class MyDonationsViewController: BaseViewController {
    
    // MARK: - Properties
    
    var donationModelArray: [DonationArrayModel]? // Array of donation models
    var dataSource =  [DonationArrayModel]() // Data source for the table view
    var donationModelList: [DonationModel]? // Array of donation models
    
    @IBOutlet weak var tableView: UITableView! // Table view to display donation history
    @IBOutlet var noresultsview: UIView! // View to display when there are no donations
    @IBOutlet var noresultMEssage: UILabel! // Label to display message when there are no donations
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up back button
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view.addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        // Show no results view if there are no donations
        if (donationModelArray?.count == 0){
            self.noresultsview.isHidden = false
            self.noresultMEssage.text = "You have made no donations so far"
        }
        
        // Configure table view
        tableView.tableFooterView = UIView(frame: .zero)
        
        // Populate data source with individual donations
        for item in self.donationModelArray! {
            for history in item.history! {
                self.dataSource.append(item)
            }
        }
        
        // Reload table view
        self.tableView.reloadData()
        
        // Fetch donation list from server
        getDonationList()
    }
    
    // MARK: - Actions
    
    /**
     Handles back button action.
     
     - Parameter _sender: The button triggering the action.
     */
    @objc func backAction(_sender:UIButton)  {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Network Request
    
    /**
     Fetches donation list from the server.
     */
    func getDonationList() {
        // Check if user is logged in
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            // Make API request to fetch donation list
            let postDict: Parameters = ["user_id":myPeopleList.userID]
            let logINString = String(format: URLHelper.iDonateTransactionList)
            WebserviceClass.sharedAPI.performRequest(type: DonationListModel.self, urlString: logINString, methodType: .post, parameters: postDict, success: { (response) in
                // Handle successful response
                if response.status == 1 {
                    self.donationModelList = response.data
                    self.tableView.reloadData()
                    if self.donationModelList?.count != 0{
                        self.noresultsview.isHidden = true
                    }
                }
            }) { (response) in
                // Handle failure
            }
        } else {
            // Prompt user to log in or register for advanced features
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "For Advanced Features Please Log-in/Register", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                // Handle cancel action
            }
            alertController.addAction(ok)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - Table View Data Source and Delegate Methods

extension MyDonationsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryTableViewCell") as! TransactionHistoryTableViewCell
        let charity = self.dataSource[indexPath.row]
        
        // Populate cell with donation details
        cell.titleLabel.text = charity.name
        cell.dateLabel.text = charity.history!.first?.donate_date
        cell.amountLabel.text = charity.history!.first?.amount
        cell.backgroundColor = .clear
        
        return cell
    }
}
