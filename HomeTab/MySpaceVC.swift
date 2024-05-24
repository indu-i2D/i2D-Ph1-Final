//
//  MySpaceVC.swift
//  iDonate
//
//  Created by Im043 on 24/04/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import SideMenu
import MBProgressHUD
import Alamofire

/// MySpaceVC: Manages the My Space section of the iDonate App
///
/// This class handles the display of user's personal space, which includes their donations, followings, and likes.
class MySpaceVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    /// TableView displaying the My Space options.
    @IBOutlet var mySpaceList: UITableView!
    
    /// Label showing the user's name.
    @IBOutlet var name: UILabel!
    
    /// Array of My Space options.
    let spaceListArray = ["MY DONATIONS","MY FOLLOWINGS","MY LIKES"]
    
    /// Model for charity count.
    var charityCountMOdel :  CharityCount?
    
    /// Array of like count models.
    var likeCountList : [LikeArrayModel]?
    
    /// Array of follow count models.
    var followCountList : [FollowArrayModel]?
    
    /// Array of donation count models.
    var donationCountList : [DonationArrayModel]?

    /// Model for charity like, follow, and donation counts.
    var charityLikeFollowDonations : CharityLikeFollowCount?
    
    override func viewDidLoad() {
        
        // Retrieve user data from UserDefaults and set the name label.
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            let capitalString = myPeopleList.name.capitalized + "'s Space"
            name.text = capitalString.capitalized
        }
        
        super.viewDidLoad()
        
        // Configure the menu button.
        if(iDonateClass.hasSafeArea) {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else{
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        menuBtn.addTarget(self, action: #selector(menuAction(_sender:)), for: .touchUpInside)
        self.view.addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "menu"), for: .normal)
    }
    
    /// Retrieves the charity like, follow, and donation counts from the server.
    func getCharityLikeFollowCount() {
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            let postDict: Parameters = ["token":myPeopleList.token,"user_id":myPeopleList.userID]
            let likeCountUrl = String(format: URLHelper.iDonateCharityFollowLikeCount)
            let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Loading"
            
            WebserviceClass.sharedAPI.performRequest(type: CharityCount.self, urlString: likeCountUrl, methodType: .post, parameters: postDict, success: { (response) in
                self.charityCountMOdel = response
                self.charityLikeFollowDonations = self.charityCountMOdel?.CharityLikeFollowCount
                self.likeCountList = self.charityLikeFollowDonations?.likeArray
                self.followCountList = self.charityLikeFollowDonations?.followArray
                self.donationCountList = self.charityLikeFollowDonations?.paymentArray
                
                UIView.performWithoutAnimation {
                    self.mySpaceList.reloadData()
                }
                MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                
            }) { (response) in
                MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            }
        } else {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "For Advance Features Please Log-in/Register", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                self.tabBarController?.selectedIndex = 0
            }
            alertController.addAction(ok)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCharityLikeFollowCount()
        mySpaceList.reloadData()
    }
    
    /// Handles the menu button action to display the side menu.
    ///
    /// - Parameter _sender: The menu button that triggered the action.
    @objc func menuAction(_sender:UIButton)  {
        
        let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        let menu = SideMenuNavigationController(rootViewController: menuLeftNavigationController)
        menu.setNavigationBarHidden(true, animated: false)
        menu.leftSide = true
        menu.statusBarEndAlpha = 0
        menu.menuWidth = screenWidth

        present(menu, animated: true, completion: nil)
        
    }

}

extension MySpaceVC
{
    /// Returns the number of rows in the specified section of the table view.
    ///
    /// - Parameters:
    ///   - tableView: The table view requesting the information.
    ///   - section: The section of the table view.
    /// - Returns: The number of rows in the section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spaceListArray.count
    }
    
    /// Configures and returns the cell for the specified row in the table view.
    ///
    /// - Parameters:
    ///   - tableView: The table view requesting the cell.
    ///   - indexPath: The index path of the row.
    /// - Returns: The configured cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mySpaceList.dequeueReusableCell(withIdentifier: "mySpaceCell") as! mySpaceCell
        cell.borderColor = iDonatecolor.mySpaceCellpinkcolor
        cell.titleLbl.text = spaceListArray[indexPath.row]
        cell.logoImage.image = UIImage(named:  spaceListArray[indexPath.row])
        
        switch indexPath.row
        {
        case 0:
            cell.countLbl.text = "\(charityLikeFollowDonations?.paymentCount ?? 0)"
        break
        case 1:
            cell.countLbl.text = "\(charityLikeFollowDonations?.following_count ?? 0)"
        break
        case 2:
            cell.countLbl.text = "\(charityLikeFollowDonations?.like_count ?? 0)"
            break
        default:
            break
        }
        
        return cell
    }
    
    /// Returns the height for the specified row in the table view.
    ///
    /// - Parameters:
    ///   - tableView: The table view requesting the information.
    ///   - indexPath: The index path of the row.
    /// - Returns: The height of the row.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    /// Handles the selection of a row in the table view and navigates to the appropriate view controller.
    ///
    /// - Parameters:
    ///   - tableView: The table view that is notifying about the selection.
    ///   - indexPath: The index path of the selected row.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MyDonationsViewController") as? MyDonationsViewController
            vc?.donationModelArray = donationCountList
            self.navigationController?.pushViewController(vc!, animated: true)
        case 1:
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MySpaceDetails") as? MySpaceDetails
            vc?.LikeOrFollow = "Follow"
            vc?.charityFollowArray = followCountList
            vc?.likeFOllowCOunt = "\(charityLikeFollowDonations?.following_count ?? 0)"
            self.navigationController?.pushViewController(vc!, animated: true)
        case 2:
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MySpaceDetails") as? MySpaceDetails
            vc?.LikeOrFollow = "Like"
            vc?.charityLikeArray = likeCountList
            vc?.likeFOllowCOunt = "\(charityLikeFollowDonations?.like_count ?? 0)"
            self.navigationController?.pushViewController(vc!, animated: true)
        default:
            break
        }
    }
}

/// Custom UITableViewCell used in the My Space table view.
class mySpaceCell: UITableViewCell {
    /// ImageView displaying the logo of the My Space option.
    @IBOutlet var logoImage: UIImageView!
    /// Label displaying the title of the My Space option.
    @IBOutlet var titleLbl: UILabel!
    /// Label displaying the count of the My Space option.
    @IBOutlet var countLbl: UILabel!
}
