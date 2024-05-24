//
//  MenuVC.swift
//  i2-Donate

import UIKit
import AlamofireImage
import Alamofire
import SafariServices
import MBProgressHUD

/// ViewController for displaying the menu options and user profile.
class MenuVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    /// TableView displaying the menu options.
    @IBOutlet var menuList: UITableView!
    
    /// ImageView displaying the user's profile picture.
    @IBOutlet var profileImage: UIImageView!
    
    /// Label displaying the user's name.
    @IBOutlet var namelbl: UILabel!
    
    /// Array containing the menu options.
    var menuArrayList = [String]()
    
    /// Array containing the names of the menu icons.
    let imagesArray = ["notification", "settings", "about", "helpsupport", "logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateProfile()
        
        // Customize view appearance
        self.view.borderColor = iDonatecolor.menuBackColor
        
        // Set up menu options based on user authentication status
        if UserDefaults.standard.data(forKey: "people") != nil {
            menuArrayList = ["My Notifications", "My Settings", "About i2~Donate", "Help/Support", "Logout"]
        } else {
            menuArrayList = ["My Notifications", "My Settings", "About i2~Donate", "Help/Support", "Login"]
        }
        
        // Adjust menu button position for devices with safe area
        if iDonateClass.hasSafeArea {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        // Add menu button and set its action
        menuBtn.addTarget(self, action: #selector(menuAction), for: .touchUpInside)
        self.view.addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        // Customize profile image view
        self.profileImage.layer.cornerRadius = 50
        self.profileImage.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateProfile()
    }
    
    /// Action method to dismiss the menu.
    @objc func menuAction() {
        dismiss(animated: true, completion: nil)
    }
    
    // Function to show login alert if user attempts to access authenticated features without logging in
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
    /// Action method to navigate to the update profile screen.
       ///
       /// - Parameter sender: The button triggering the action.
    @IBAction func updatection(_ sender:UIButton) {
        if UserDefaults.standard.data(forKey: "people") != nil{
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UpdateProfileVC") as! UpdateProfileVC
            vc.updateType = "update"
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
        else{
            self.showLoginAlert()
        }
    }
    // Function to update user profile information

    func updateProfile() {

        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            
            self.namelbl.text = myPeopleList.name.capitalized
            
            self.profileImage.image = #imageLiteral(resourceName: "defaultImageCharity")
            
            if(myPeopleList.profileUrl == "") {
                self.profileImage.image = UIImage(named: "defaultImageCharity")
            } else {
//                let profileImage = URL(string: myPeopleList.profileUrl)!
                let imgUrl = String(format: "%@%@", UPLOAD_URL,myPeopleList.profileUrl)
                let profileImage = URL(string: imgUrl)!
                self.profileImage.contentMode = .scaleAspectFill
                self.profileImage.af.setImage(withURL: profileImage, placeholderImage: #imageLiteral(resourceName: "defaultImageCharity"))
            }
            // Joe 10
        } else {
            print("There is an issue")
        }
    }
    // MARK: - UITableView Delegate and DataSource Methods

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
            if UserDefaults.standard.data(forKey: "people") != nil{
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NotificationVC") as? NotificationVC
                self.navigationController?.pushViewController(vc!, animated: true)
            }else{
                self.showLoginAlert()
            }
            
        case 1:
            if UserDefaults.standard.data(forKey: "people") != nil{
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SettingsVC") as? SettingsVC
                self.navigationController?.pushViewController(vc!, animated: true)
            }else{
                self.showLoginAlert()
            }
            
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
    
   
    
}
/// Custom UITableViewCell for displaying menu options.
class menuTableviewCell:UITableViewCell{
    /// ImageView displaying the menu option icon.
    @IBOutlet var logoImage: UIImageView!
    
    /// Label displaying the menu option title.
    @IBOutlet var titleLbl: UILabel!
}
