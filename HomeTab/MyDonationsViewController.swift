//
//  MyDonationsViewController.swift
//  iDonate
//
//  Created by PPC-INDIA on 25/10/20.
//  Copyright © 2020 Im043. All rights reserved.
//

import UIKit
import Alamofire

class MyDonationsViewController: BaseViewController {

    var donationModelArray: [DonationArrayModel]?

    var donationModelList: [DonationModel]?

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var noresultsview: UIView!
    @IBOutlet var noresultMEssage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        }else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        if (donationModelArray?.count == 0){
            self.noresultsview.isHidden = false
            self.noresultMEssage.text = "You have made no donations so far"
        }
        tableView.tableFooterView = UIView(frame: .zero)

        // Do any additional setup after loading the view.
        
       // getDonationList()
        self.tableView.reloadData()

    }
    
    
    @objc func backAction(_sender:UIButton)  {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getDonationList() {
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            let postDict: Parameters = ["user_id":myPeopleList.userID]
            let logINString = String(format: URLHelper.iDonateTransactionList)
            WebserviceClass.sharedAPI.performRequest(type: DonationListModel.self, urlString: logINString, methodType: .post, parameters: postDict, success: { (response) in

                if response.status == 1 {
                    self.donationModelList = response.data
                    self.tableView.reloadData()
                    if self.donationModelList?.count != 0{
                        self.noresultsview.isHidden = true
                    }
                }
                
                print(response)
                
            }) { (response) in
                
            }
        } else{
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "For Advance Features Please Log-in/Register", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                
            }
            alertController.addAction(ok)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MyDonationsViewController: UITableViewDataSource, UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return donationModelArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryTableViewCell") as! TransactionHistoryTableViewCell
        let charity = donationModelArray![indexPath.row]

        cell.titleLabel.text = charity.name//donationModelList?[indexPath.row].charity_name ?? ""
        cell.dateLabel.text = charity.history![0].donate_date//donationModelList?[indexPath.row].date ?? ""
        cell.amountLabel.text = charity.history![0].amount ?? ""
     //   cell.paymentModeLabel.text = "Payment Mode: " + "\(donationModelList?[indexPath.row].payment_type ?? "")"//"Payment Mode: " + "\(donationModelList?[indexPath.row].payment_type ?? "")"
        cell.backgroundColor = .clear
        
        
        return cell

    }
    
}
