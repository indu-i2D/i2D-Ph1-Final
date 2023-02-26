//
//  NotificationVC.swift
//  iDonate
//
//  Created by Im043 on 14/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import SideMenu
import MBProgressHUD
import Alamofire

class NotificationVC: BaseViewController,UITableViewDelegate,UITableViewDataSource,UITabBarDelegate{
    
    @IBOutlet var notificationTable: UITableView!
    @IBOutlet var notificationTabBar: UITabBar!
    
    var notification : NotificationModel!
    var notifications:[NotificationArray]? = nil

    @IBOutlet var noresultsview: UIView!
    @IBOutlet var noresultMEssage: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if(iDonateClass.hasSafeArea) {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        }else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(menuAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "menu"), for: .normal)
        getNotificationWebServices()
        
    }
    
    @objc func menuAction(_sender:UIButton)  {
        let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        let menu = SideMenuNavigationController(rootViewController: menuLeftNavigationController)
        menu.setNavigationBarHidden(true, animated: false)
        menu.leftSide = true
        menu.statusBarEndAlpha = 0
        menu.menuWidth = screenWidth
        present(menu, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notification") as! notificationCell
         cell.titleLbl.text = notifications?[indexPath.row].message
        return cell
    }
    
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
        if(item.tag == 0){
            UserDefaults.standard.set(0, forKey: "tab")
            self.navigationController?.pushViewController(vc!, animated: false)
        }
            
        else{
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

extension NotificationVC {
    
    func getNotificationWebServices() {
        
        var userID:String?
        
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            userID = String(myPeopleList.userID)
        }
        
        let postDict: Parameters = [
            "user_id" : userID ?? "",
        ]
        
        let urlString = String(format: URLHelper.iDonateNotification)
        let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        
        WebserviceClass.sharedAPI.performRequest(type: NotificationModel.self ,urlString: urlString, methodType: .post, parameters: postDict, success: { (response) in
            self.notification = response
            self.notifications = response.data ?? [NotificationArray]()
            
            if(self.notification?.status == 1){
                self.noresultsview.isHidden = true
            }else {
                self.noresultsview.isHidden = false
                self.noresultMEssage.text = self.notification?.message
            }
            
            self.notificationTable.reloadData()
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            
        }) { (response) in
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }
    }
}

class notificationCell:UITableViewCell{
    @IBOutlet var logoImage: UIImageView!
    @IBOutlet var titleLbl: UILabel!
}

struct NotificationModel: Codable {
    var status: Int?
    var message: String?
    var data: [NotificationArray]?
}

struct NotificationArray: Codable {
    var user_id: String?
    var title: String?
    var message: String?
    var date: String?
}
