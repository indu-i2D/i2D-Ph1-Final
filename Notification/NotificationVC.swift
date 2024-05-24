//
//  NotificationVC.swift
//  i2-Donate


import UIKit
import SideMenu
import MBProgressHUD
import Alamofire

/// View controller for displaying user notifications.
class NotificationVC: BaseViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {
    
    /// Table view displaying notifications.
    @IBOutlet var notificationTable: UITableView!
    
    /// Tab bar for switching between different views.
    @IBOutlet var notificationTabBar: UITabBar!
    
    /// Model for storing notification data.
    var notification: NotificationModel!
    
    /// Array containing notifications.
    var notifications: [NotificationArray]? = nil
    
    /// View to display when no notifications are available.
    @IBOutlet var noresultsview: UIView!
    
    /// Label displaying a message when no notifications are available.
    @IBOutlet var noresultMEssage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adjust menu button position for devices with safe area
        if iDonateClass.hasSafeArea {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        // Add menu button and set its action
        menuBtn.addTarget(self, action: #selector(menuAction(_sender: )), for: .touchUpInside)
        self.view.addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "menu"), for: .normal)
        
        // Fetch notification data
        getNotificationWebServices()
    }
    
    /// Action method for displaying the side menu.
    ///
    /// - Parameter _sender: The button triggering the action.
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

}
// MARK: - Web Service Methods

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
/// Custom UITableViewCell for displaying notifications.

class notificationCell:UITableViewCell{
    /// ImageView displaying the notification icon.
        @IBOutlet var logoImage: UIImageView!
        
        /// Label displaying the notification title.
        @IBOutlet var titleLbl: UILabel!
    }

    /// Model representing the notification response.
    struct NotificationModel: Codable {
        var status: Int?
        var message: String?
        var data: [NotificationArray]?
    }

    /// Model representing an individual notification.
    struct NotificationArray: Codable {
        var user_id: String?
        var title: String?
        var message: String?
        var date: String?
    }
