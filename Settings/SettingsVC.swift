//
//  SettingsVC.swift
//  iDonate
//
//  Created by Im043 on 06/06/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import SideMenu
import MBProgressHUD
class SettingsVC: BaseViewController,UITableViewDataSource,UITableViewDelegate,UITabBarDelegate {
     @IBOutlet var notificationTabBar: UITabBar!
     @IBOutlet weak var settingsTableview: UITableView!
     var userId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        }else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
            
        }
        
       menuBtn.addTarget(self, action: #selector(menuAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "menu"), for: .normal)
        // Do any additional setup after loading the view.
    }
    
    @objc func menuAction(_sender:UIButton){
        // let menuLeftNavigationController = uis(rootViewController:MenuVC )
        // UISideMenuNavigationController is a subclass of UINavigationController, so do any additional configuration
        // of it here like setting its viewControllers. If you're using storyboards, you'll want to do something like:
        let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        let menu = SideMenuNavigationController(rootViewController: menuLeftNavigationController)
        menu.setNavigationBarHidden(true, animated: false)
        menu.leftSide = true
        menu.statusBarEndAlpha = 0
        menu.menuWidth = screenWidth

        present(menu, animated: true, completion: nil)
    }
    func deleteAccount() {
        // Display an alert with confirmation message
        let deleteAlert = UIAlertController(title: "Delete Account", message: "Are you sure you wish to delete your account?", preferredStyle: .alert)
        
        // Add cancel option
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // Take user back to Menu if cancel is selected
            self.dismiss(animated: true, completion: nil)
        }))
        
        // Add continue option
        deleteAlert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { action in
            if let data = UserDefaults.standard.data(forKey: "people"),
               let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails{
                let postDict = ["User ID": myPeopleList.userID] as [String : Any]
                let revokeUserString = String(format: URLHelper.iDonateRevokeUser)
                let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
                loadingNotification.mode = MBProgressHUDMode.indeterminate
                loadingNotification.label.text = "Loading"
                
                WebserviceClass.sharedAPI.performRequest(type: DeleteAcc.self, urlString: revokeUserString, methodType: .post, parameters: postDict, success: { (response) in
                    // Hide loading indicator
                    MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                    print("RESPONSE",response)
                    // Show confirmation alert if API call is successful
                    let confirmationAlert = UIAlertController(title: "Confirmation", message: "You will receive an email with status of your account deletion request within 7 working days. If your profile does not have an email, please update your profile and resubmit your account cancellation request.", preferredStyle: .alert)
                    
                    // Add OK button to dismiss the pop-up
                
                    confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        UserDefaults.standard.removeObject(forKey: "people")

                        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }))

                    self.present(confirmationAlert, animated: true, completion: nil)
                }) { (error) in
                    // Hide loading indicator
                    MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                    
                    // Handle error if API call fails
                    print("Error: \(error)")
                    // You may display an error message to the user if needed
                }}
            }))

        // Present the delete alert
        self.present(deleteAlert, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let data = UserDefaults.standard.data(forKey: "people"),
            let _ = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            if(UserDefaults.standard.value(forKey: "loginType") as! String == "Social") {
                return 2
            }
            else{
             return 4
            }// Joe 10
        } else {
                return 2
        }
      
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
            return cell
        }
        else if(indexPath.row == 1)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
            return cell
        }
            
        else if(indexPath.row == 2)
            
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell4", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func showLoginAlert(){
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if(indexPath.row == 2)
        {
             if UserDefaults.standard.data(forKey: "people") != nil{
                 let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChangePasswordVC") as? ChangePasswordVC
                 vc?.changeOrForgot = "Change"
                 self.navigationController?.pushViewController(vc!, animated: false)
             }
             else{
                 self.showLoginAlert()
             }
             
         }
             else if(indexPath.row == 3)
             {
                 deleteAccount()
             }
             
        }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
        if(item.tag == 0)
        {
            UserDefaults.standard.set(0, forKey: "tab")
            self.navigationController?.pushViewController(vc!, animated: false)
        }
            
            
            
        else
        {
            UserDefaults.standard.set(1, forKey: "tab")
            self.navigationController?.pushViewController(vc!, animated: false)
            
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
