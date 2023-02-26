//
//  AdvancedVC.swift
//  iDonate
//
//  Created by Im043 on 23/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

class AdvancedVC: BaseViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var apply: UIButton!
    @IBOutlet weak var reset: UIButton!
    @IBOutlet weak var typesTableView : UITableView!
    
    var categoryCode = [String]()
    
    var selectedIndex:[Int] = [Int]()
    var advancedResponse :  AdvancedModel?
    
    var typesArray : [Types]?
    
    var selectionFlag :Bool = false

    var selectParentscetion:Int = -1
    
    var countryCode = ""
    var latitude = ""
    var longitude = ""
    var address = ""
    var taxDeductible = ""
    var comingFromType = false
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else{
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        typesTableView.estimatedRowHeight = 60
        typesTableView.rowHeight = UITableView.automaticDimension
        
        typesTableView.delegate = self
        typesTableView.dataSource = self

        getTypesWebservice()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.typesTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }
    
    func getTypesWebservice() {
        
        var userID:String?
        var token:String?
        
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            userID = String(myPeopleList.userID)
            token = myPeopleList.token
        }
        
        let postDict: Parameters = [
            "user_id" : userID ?? "",
            "token" : token ?? "",
        ]
        
        let urlString = String(format: URLHelper.iDonateCategories)
        let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        
        WebserviceClass.sharedAPI.performRequest(type: AdvancedModel.self ,urlString: urlString, methodType: .post, parameters: postDict, success: { (response) in
            self.advancedResponse = response
            self.typesArray  = self.advancedResponse?.data
            self.typesTableView.reloadData()
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            
        }) { (response) in
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }
    }
    
    @IBAction func applyAction(_ sender: Any) {
        switch countryCode {
        case "US":
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
            vc?.headertitle = "UNITED STATES"
            vc?.country = countryCode
            vc?.deductible = taxDeductible
            vc?.categoryCode = categoryCode
            vc?.locationSearch = address
            vc?.lattitude = latitude
            vc?.longitute = longitude
            vc?.hidesBottomBarWhenPushed = false
            self.navigationController?.pushViewController(vc!, animated: true)
            break
        case "INT":
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
            vc?.headertitle = "INTERNATIONAL CHARITIES REGISTERED IN USA"
            vc?.country = countryCode
            vc?.deductible = taxDeductible
            vc?.categoryCode = categoryCode
            vc?.locationSearch = address
            vc?.lattitude = latitude
            vc?.longitute = longitude
            vc?.hidesBottomBarWhenPushed = false
            self.navigationController?.pushViewController(vc!, animated: true)
            break
        default:
             let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByNameVC") as? SearchByNameVC
             vc?.deductible = taxDeductible
             vc?.categoryCode = categoryCode
             vc?.locationSearch = address
             vc?.lattitude = latitude
             vc?.longitute = longitude
             vc?.comingFromType = comingFromType
             self.navigationController?.pushViewController(vc!, animated: true)
            break
        }
    }
    
    @IBAction func resetAction(_ sender: Any) {
        UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseOut],
                       animations: {
                        self.bottomView.isHidden = true
                        self.loadViewIfNeeded()
        }, completion: nil)
        self.selectedIndex.removeAll()
        self.categoryCode.removeAll()
        self.typesTableView.reloadData()
    }
    
    @objc func backAction(_sender:UIButton)  {
        let alert = UIAlertController(title: "", message: "Returning To previous screen without making changes?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    // TABLEVIEW DELEGATE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return typesArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! headercustomCell
        cell.headertitle.text = typesArray?[indexPath.row].category_name
        cell.narrowArrow.tag = indexPath.row
        
        if selectedIndex.contains(indexPath.row) {
            selectedIndex.append(indexPath.row)
            cell.backgroundlbl.backgroundColor = hexStringToUIColor(hex: "F4DEEF")
            cell.selectbtn.isSelected = true
            cell.narrowlabel.isHidden = false
            cell.narrowArrow.isHidden = false
        }else {
            selectedIndex = selectedIndex.filter { $0 != indexPath.row }
            cell.backgroundlbl.backgroundColor = .clear
            cell.selectbtn.isSelected = false
            cell.narrowlabel.isHidden = true
            cell.narrowArrow.isHidden = true
        }
        
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            cell.narrowlabel.text = "Filter by sub-types"
        }
        else{
            cell.narrowlabel.text = "Filter by sub-types (Requires Login)"
        }
        
        cell.narrowArrow.addTarget(self, action: #selector(showSubTypes(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return bottomView
//    }
//
    // MARK:- UITableView Delegate Method
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as! headercustomCell
        
        if !selectedIndex.contains(indexPath.row) {
            selectedIndex.append(indexPath.row)
            cell.backgroundlbl.backgroundColor = hexStringToUIColor(hex: "F4DEEF")
            cell.selectbtn.isSelected = true
            cell.narrowlabel.isHidden = false
            cell.narrowArrow.isHidden = false
            categoryCode.append((typesArray?[indexPath.row].category_code)!)
        }else {
            selectedIndex = selectedIndex.filter { $0 != indexPath.row }
            categoryCode = categoryCode.filter { $0 != (typesArray?[indexPath.row].category_code)!}
            cell.narrowlabel.isHidden = true
            cell.backgroundlbl.backgroundColor = .clear
            cell.selectbtn.isSelected = false
            cell.narrowArrow.isHidden = true
        }
        
        if selectedIndex.count > 0 {
            self.bottomView.isHidden = false
        } else{
            self.bottomView.isHidden = true
        }
        
    }
    
    @objc func showSubTypes(_ sender:UIButton){
        
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SubTypesViewController") as? SubTypesViewController
            vc?.selectedType = typesArray?[sender.tag]
            vc?.countryCode = countryCode
            vc?.taxDeductible = taxDeductible
            vc?.address = address
            vc?.latitude = latitude
            vc?.longitude = longitude
            vc?.comingFromType = true
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else{
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
    
}

