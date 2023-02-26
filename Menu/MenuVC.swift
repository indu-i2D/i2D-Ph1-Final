//
//  MenuVC.swift
//  iDonate
//
//  Created by sureshkumar on 05/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import SafariServices

class MenuVC:BaseViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet var menuList: UITableView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var namelbl: UILabel!
    
    var menuArrayList = [String]()
    let imagesArray = ["notification","settings","about","helpsupport","logout"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.borderColor = iDonatecolor.menuBackColor
        
        if((UserDefaults.standard.value(forKey: "people")) != nil){
            menuArrayList = ["My Notifications","My Settings","About i2~Donate","Help/Support","Logout"]
        }
        else{
            menuArrayList = ["My Notifications","My Settings","About i2~Donate","Help/Support","Login"]
        }
        
        
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        }
        else{
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(menuAction), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)

        updateProfile()
        self.profileImage.layer.cornerRadius = 50//self.profileImage.frame.size.width / 2
        self.profileImage.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    
    @objc func menuAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updatection(_ sender:UIButton) {
        if UserDefaults.standard.data(forKey: "people") != nil{
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UpdateProfileVC") as? UpdateProfileVC
            vc?.updateType = "update"
            vc?.modalPresentationStyle = .fullScreen
            self.navigationController?.present(vc!, animated: true, completion: nil)
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
    
    func updateProfile() {
        
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            
            self.namelbl.text = myPeopleList.name.capitalized
            
            self.profileImage.image = #imageLiteral(resourceName: "defaultImageCharity")
            
            if(myPeopleList.profileUrl == "") {
                self.profileImage.image = UIImage(named: "defaultImageCharity")
            } else {
                let profileImage = URL(string: myPeopleList.profileUrl)!
                self.profileImage.af.setImage(withURL: profileImage, placeholderImage: #imageLiteral(resourceName: "defaultImageCharity"))
            }
            // Joe 10
        } else {
            print("There is an issue")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArrayList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = menuList.dequeueReusableCell(withIdentifier: "menuCell") as! menuTableviewCell
        cell.titleLbl.text = menuArrayList[indexPath.row]
        cell.logoImage.image = UIImage(named: imagesArray[indexPath.row])
//        let animation = AnimationFactory.makeSlideIn(duration:0.5, delayFactor: 0.05)
//        let animator = Animator(animation: animation)
//        animator.animate(cell: cell, at: indexPath, in: tableView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NotificationVC") as? NotificationVC
            self.navigationController?.pushViewController(vc!, animated: true)
        case 1:
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SettingsVC") as? SettingsVC
            self.navigationController?.pushViewController(vc!, animated: true)
        case 2:
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AboutVC") as? AboutVC
            vc?.headerString = "About i2~Donate"
            self.navigationController?.pushViewController(vc!, animated: true)
        case 3:
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AboutVC") as? AboutVC
            vc?.headerString = "Help/Support"
            self.navigationController?.pushViewController(vc!, animated: true)
        case 4:
            UserDefaults.standard.removeObject(forKey: "people")
            constantFile.changepasswordBack = false
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
            self.navigationController?.pushViewController(vc!, animated: true)
        default:
            return
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

class menuTableviewCell:UITableViewCell{
    @IBOutlet var logoImage: UIImageView!
    @IBOutlet var titleLbl: UILabel!
}
