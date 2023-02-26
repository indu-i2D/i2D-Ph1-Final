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

class MySpaceVC: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var mySpaceList: UITableView!
    @IBOutlet var name: UILabel!
    
    let spaceListArray = ["MY DONATIONS","MY FOLLOWINGS","MY LIKES"]
    var charityCountMOdel :  CharityCount?
    var likeCountList : [LikeArrayModel]?
    var followCountList : [FollowArrayModel]?
    var donationCountList : [DonationArrayModel]?

    var charityLikeFollowDonations : CharityLikeFollowCount?
    
    override func viewDidLoad() {
        
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            let capitalString = myPeopleList.name.capitalized + "'s Space"
            name.text = capitalString.capitalized
        }
        
        super.viewDidLoad()
        if(iDonateClass.hasSafeArea) {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else{
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(menuAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "menu"), for: .normal)
       
        // Do any additional setup after loading the view.
    }
    
    
   func getCharityLikeFollowCount() {
    if let data = UserDefaults.standard.data(forKey: "people"),
        let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
        print(myPeopleList.name)
      
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
                self.mySpaceList .reloadData()
            }
            print("Result: \(String(describing: response))")                     // response serialization result
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            
        }) { (response) in
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }
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
            self.tabBarController?.selectedIndex = 0
        }
        alertController.addAction(ok)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    }
    override func viewWillAppear(_ animated: Bool) {
         getCharityLikeFollowCount()
        self.mySpaceList .reloadData()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MySpaceVC
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spaceListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mySpaceList.dequeueReusableCell(withIdentifier: "mySpaceCell") as! mySpaceCell
        cell.borderColor = iDonatecolor.mySpaceCellpinkcolor
        cell.titleLbl.text = spaceListArray[indexPath.row]
        cell.logoImage.image = UIImage(named:  spaceListArray[indexPath.row])
//        let animation = AnimationFactory.makeMoveUpWithFade(rowHeight: 100, duration:0.5, delayFactor: 0.05)
//        let animator = Animator(animation: animation)
//        animator.animate(cell: cell, at: indexPath, in: tableView)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         switch indexPath.row
         {
         case 0:
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MyDonationsViewController") as? MyDonationsViewController
             vc?.donationModelArray = donationCountList
            self.navigationController?.pushViewController(vc!, animated: true)
            break
         case 1:
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MySpaceDetails") as? MySpaceDetails
            vc?.LikeOrFollow = "Follow"
            vc?.charityFollowArray = followCountList
            vc?.likeFOllowCOunt = "\(charityLikeFollowDonations?.following_count ?? 0)"
            self.navigationController?.pushViewController(vc!, animated: true)
            break
         case 2:
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MySpaceDetails") as? MySpaceDetails
            vc?.LikeOrFollow = "Like"
            vc?.charityLikeArray = likeCountList
            vc?.likeFOllowCOunt = "\(charityLikeFollowDonations?.like_count ?? 0)"
            self.navigationController?.pushViewController(vc!, animated: true)
            break
        
         default:
            break
        }
    }
}
class mySpaceCell:UITableViewCell {
    @IBOutlet var logoImage: UIImageView!
     @IBOutlet var titleLbl: UILabel!
    @IBOutlet var countLbl: UILabel!
}
