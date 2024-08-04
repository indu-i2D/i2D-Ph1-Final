//
//  MySpaceDetails.swift
//  iDonate
//
//  Created by Im043 on 04/07/19.
//  Copyright © 2019 Im043. All rights reserved.
//

/**
 View controller managing the user's likes, donations, or followings.

 This view controller displays a list of charities based on the user's likes, donations, or followings. It provides functionality to like, donate to, or follow charities.


 */
import UIKit
import MBProgressHUD
import Alamofire
import TKFormTextField
/// This view controller displays a list of charities based on the user's likes, donations, or followings. It provides functionality to like, donate to, or follow charities.

class MySpaceDetails: BaseViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, UITextFieldDelegate {
    
    /// Table view displaying the list of charities.
    @IBOutlet var searchTableView: UITableView!
    
    /// Label displaying the header title.
    @IBOutlet var header: UILabel!
    
    /// Tab bar for switching between different views.
    @IBOutlet var notificationTabBar: UITabBar!
    
    /// View displayed when there are no search results.
    @IBOutlet var noresultsview: UIView!
    
    /// Label displaying the message when there are no search results.
    @IBOutlet var noresultMEssage: UILabel!
    
    /// Blur view used for overlaying when additional actions are performed.
    @IBOutlet var blurView: UIVisualEffectView!
    
    /// Button for canceling actions.
    @IBOutlet var cancelBtn: UIButton!
    
    /// Text field for entering the donation amount.
    @IBOutlet var amountText: TKFormTextField!
    
    /// Button for initiating the donation process.
    @IBOutlet var donateBTn: UIButton!
    
    /// Button for continuing the payment process.
    @IBOutlet var continuePaymentBTn: UIButton!
    
    /// View for displaying processing charges during the donation process.
    var processingCharges = ProcessingChargesView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
    
    /// Array containing liked charities.
    var charityLikeArray: [LikeArrayModel]?
    
    /// Array containing followed charities.
    var charityFollowArray: [FollowArrayModel]?
    
    /// Array containing donated charities.
    var charityDonationArray: [DonationArrayModel]?
    
    /// Indicates whether the action is for liking, donating, or following.
    var LikeOrFollow: String?
    
    /// Total count of likes or follows.
    var likeFOllowCOunt: String?
    
    /// ID of the selected charity.
    var charityID: String?
    
    /// Total count of charities.
    var charityCount: String?
    
    /// Array containing category codes.
    var categoryCode: [String]?
    
    /// Array containing sub-category codes.
    var subCategoryCode: [String]?
    
    /// Array containing child categories.
    var childCategory: [String]?
    
    /// Delegate for handling payment operations.
    weak var payDelegate: PaymentDelegate?
    
    /// Flag indicating whether the user is donating.
    var donateFlag: Bool = false
    
    /// Selected charity for donation.
    var selectedCharity: LikeArrayModel? = nil
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register custom cell for table view.
        searchTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "searchcell")
        
        // Set up header title and check for empty data.
        if LikeOrFollow == "Like" {
            header.text = "MY LIKES"
            if likeFOllowCOunt == "0" {
                self.noresultsview.isHidden = false
                self.noresultMEssage.text = "You haven't liked any non-profits"
            }
        } else if LikeOrFollow == "Donation" {
            header.text = "MY DONATIONS"
            if likeFOllowCOunt == "0" {
                self.noresultsview.isHidden = false
                self.noresultMEssage.text = "You haven't liked any non-profits"
            }
        } else {
            header.text = "MY FOLLOWINGS"
            if likeFOllowCOunt == "0" {
                self.noresultsview.isHidden = false
                self.noresultMEssage.text = "You haven't followed any non-profits"
            }
        }
        
        // Set up menu button position.
        if iDonateClass.hasSafeArea {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        // Add action for the menu button.
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view.addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        // Add tap gesture recognizer for canceling actions.
        let mytapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(cancelView))
        mytapGestureRecognizer1.numberOfTapsRequired = 1
        mytapGestureRecognizer1.cancelsTouchesInView = false
        self.blurView.addGestureRecognizer(mytapGestureRecognizer1)
        
        // Add observers for keyboard show/hide notifications.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Set table view delegate and data source.
        searchTableView.delegate = self
        searchTableView.dataSource = self
    }
    
    // MARK: - Keyboard Handling
    
    /**
     Adjusts the view when the keyboard is about to show.
     
     - Parameter notification: Notification object containing keyboard information.
     */
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if donateFlag == true {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }
    
    /**
     Adjusts the view when the keyboard is about to hide.
     
     - Parameter notification: Notification object containing keyboard information.
     */
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    // MARK: - Tab Bar Delegate
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
        if item.tag == 0 {
            UserDefaults.standard.set(0, forKey: "tab")
            self.navigationController?.pushViewController(vc!, animated: false)
        } else {
            UserDefaults.standard.set(1, forKey: "tab")
            self.navigationController?.pushViewController(vc!, animated: false)
        }
    }
    
    // MARK: - Button Actions
    
    /**
     Action method for back button.
     
     - Parameter _sender: The back button.
     */
    @objc func backAction(_sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - TableView DataSource and Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(LikeOrFollow == "Like") {
            return charityLikeArray?.count ?? 0
        } else if (LikeOrFollow == "Donation") {
            return charityDonationArray?.count ?? 0
        } else{
            return charityFollowArray?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Check the value of LikeOrFollow to determine the behavior of the cell
        if LikeOrFollow == "Like" {
            // Handle the "Like" case
            let charity = charityLikeArray![indexPath.row]
            let cell = searchTableView.dequeueReusableCell(withIdentifier: "searchcell") as! SearchTableViewCell
            // Configure cell properties based on charity data
            cell.title.text = charity.name
            cell.address.text = charity.street! + "," + charity.city!
            let likeString = charity.like_count! + " Likes"
            cell.likeBtn.setTitle(likeString, for: .normal)
            let placeholderImage = UIImage(named: "defaultImageCharity")!
            if let logo = charity.logo, !logo.isEmpty, let url = URL(string: logo) {
                cell.logoImage.af.setImage(withURL: url, placeholderImage: placeholderImage)
            } else {
                cell.logoImage.image = placeholderImage
            }
            // Set tags and addTarget for buttons
            cell.followingBtn.tag = indexPath.row
            cell.likeBtn.tag = indexPath.row
            cell.donateBtn.tag = indexPath.row
            cell.followingBtn.addTarget(self, action: #selector(followAction(_:)), for: .touchUpInside)
            cell.likeBtn.addTarget(self, action: #selector(likeAction), for: .touchUpInside)
            cell.donateBtn.addTarget(self, action: #selector(donateAction), for: .touchUpInside)
            // Set button selection state based on charity data
            if charity.liked == "0" {
                cell.likeBtn.isSelected = false
            } else {
                cell.likeBtn.isSelected = true
            }
            if charity.followed == "0" {
                cell.followingBtn.isSelected = false
                cell.followingBtn.setTitle("Follow", for: .normal)
            } else {
                cell.followingBtn.isSelected = true
                cell.followingBtn.setTitle("Following", for: .normal)
            }
            return cell
        } else if LikeOrFollow == "Donation" {
            // Handle the "Donation" case
            let charity = charityDonationArray![indexPath.row]
            let cell = searchTableView.dequeueReusableCell(withIdentifier: "searchcell") as! SearchTableViewCell
            // Configure cell properties based on charity data
            cell.title.text = charity.name
            cell.address.text = charity.street! + "," + charity.city!
            let likeString = charity.like_count! + " Likes"
            cell.likeBtn.setTitle(likeString, for: .normal)
            let placeholderImage = UIImage(named: "defaultImageCharity")!
            if let logo = charity.logo, !logo.isEmpty, let url = URL(string: logo) {
                cell.logoImage.af.setImage(withURL: url, placeholderImage: placeholderImage)
            } else {
                cell.logoImage.image = placeholderImage
            }
            // Set tags and addTarget for buttons
            cell.followingBtn.tag = indexPath.row
            cell.likeBtn.tag = indexPath.row
            cell.donateBtn.tag = indexPath.row
            cell.followingBtn.addTarget(self, action: #selector(followAction(_:)), for: .touchUpInside)
            cell.likeBtn.addTarget(self, action: #selector(likeAction), for: .touchUpInside)
            cell.donateBtn.addTarget(self, action: #selector(donateAction), for: .touchUpInside)
            // Set button selection state based on charity data
            if charity.liked == "0" {
                cell.likeBtn.isSelected = false
            } else {
                cell.likeBtn.isSelected = true
            }
            if charity.followed == "0" {
                cell.followingBtn.isSelected = false
                cell.followingBtn.setTitle("Follow", for: .normal)
            } else {
                cell.followingBtn.isSelected = true
                cell.followingBtn.setTitle("Following", for: .normal)
            }
            return cell
        } else {
            // Handle other cases of LikeOrFollow
            let charity = charityFollowArray![indexPath.row]
            let cell = searchTableView.dequeueReusableCell(withIdentifier: "searchcell") as! SearchTableViewCell
            // Configure cell properties based on charity data
            cell.title.text = charity.name
            cell.address.text = charity.street! + "," + charity.city!
            let likeString = charity.like_count! + " Likes"
            cell.likeBtn.setTitle(likeString, for: .normal)
            let placeholderImage = UIImage(named: "defaultImageCharity")!
            if let logo = charity.logo, !logo.isEmpty, let url = URL(string: logo) {
                cell.logoImage.af.setImage(withURL: url, placeholderImage: placeholderImage)
            } else {
                cell.logoImage.image = placeholderImage
            }
            // Set tags and addTarget for buttons
            cell.followingBtn.tag = indexPath.row
            cell.likeBtn.tag = indexPath.row
            cell.donateBtn.tag = indexPath.row
            cell.followingBtn.addTarget(self, action: #selector(followAction(_:)), for: .touchUpInside)
            cell.likeBtn.addTarget(self, action: #selector(likeAction), for: .touchUpInside)
            cell.donateBtn.addTarget(self, action: #selector(donateAction), for: .touchUpInside)
            // Set button selection state based on charity data
            if charity.liked == "0" {
                cell.likeBtn.isSelected = false
            } else {
                cell.likeBtn.isSelected = true
            }
            if charity.followed == "0" {
                cell.followingBtn.isSelected = false
                cell.followingBtn.setTitle("Follow", for: .normal)
            } else {
                cell.followingBtn.isSelected = true
                cell.followingBtn.setTitle("Following", for: .normal)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    // MARK: - IBActions
    
    /**
     Handles the action when the like button is tapped.
     
     - Parameter sender: The button triggering the action.
     */
    @IBAction func likeAction(_ sender:UIButton) {
        // Handling Like Action based on LikeOrFollow
        if(LikeOrFollow == "Like") {
            let charity = charityLikeArray![sender.tag]
            
            if(sender.isSelected){
                sender.isSelected = false
                charityCount = "0"
            }
            else {
                charityCount = "1"
                sender.isSelected = true
            }
            charityLikeAction(like: charityCount!, charityId: charity.id!,index:sender.tag)
            
        } else if (LikeOrFollow == "Donation") {
            let charity = charityDonationArray![sender.tag]
            if(sender.isSelected) {
                sender.isSelected = false
                charityCount = "0"
            } else{
                charityCount = "1"
                sender.isSelected = true
            }
            
            charityLikeAction(like: charityCount!, charityId: charity.id!,index:sender.tag)
            
        }
        else{
            
            let charity = charityFollowArray![sender.tag]
            if(sender.isSelected) {
                sender.isSelected = false
                charityCount = "0"
            }else {
                charityCount = "1"
                sender.isSelected = true
            }
            charityLikeAction(like: charityCount!, charityId: charity.id!,index:sender.tag)
            
        }
    }
    
    /**
     Handles the action when the donate button is tapped.
     
     - Parameter sender: The button triggering the action.
     */
    @IBAction func donateAction(_ sender:UIButton)  {
        // Checking if User is Logged In
        if let data = UserDefaults.standard.data(forKey: "people"),
           let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            blurView.frame =  self.view.frame
            self.continuePaymentBTn.tag = sender.tag
            self.view .addSubview(blurView)
        } else {
            // Prompting User to Log In or Register
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
    
    /**
     Handles the payment action when the payment button is tapped.
     
     This method validates the entered donation amount and initiates the payment process.
     If no amount is entered, it presents an alert prompting the user to enter an amount.
     If the entered amount is less than $1, it presents an alert informing the user that the amount should be a minimum of $1.
     If the entered amount is valid, it retrieves the Braintree client token from the server and hides the progress indicator.
     
     - Parameter sender: The button triggering the action.
     */
    @IBAction func paymentAction(_ sender:UIButton) {
        // Check if the donation amount is entered
        if(amountText.text == "") {
            // Prompt user to enter an amount if empty
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string:"please enter amount", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            // Validate entered amount
            let amount = self.amountText.text?.replacingOccurrences(of: "$", with: "")
            let amountWithoutDollar = amount!.trimmingCharacters(in: .whitespacesAndNewlines)
            let price = Double(amountWithoutDollar)
            
            // Check if amount is less than $1
            if (price! < 1) {
                // Prompt user that amount should be minimum of $1
                let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
                let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
                let messageAttrString = NSMutableAttributedString(string:"Amount should be minimum of 1$", attributes: messageFont)
                alertController.setValue(messageAttrString, forKey: "attributedMessage")
                let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                }
                alertController.addAction(contact)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            // Show progress indicator
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            // Request Braintree client token from the server
            let urlString = "\(URLHelper.baseURL)braintree_client_token"
            let url = URL(string: urlString)!
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            
            // Perform request to retrieve Braintree client token
            AF.request(request).responseJSON { (response) in
                // Hide progress indicator
                MBProgressHUD.hide(for: self.view, animated: true)
                // Handle response as needed
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        donateFlag = true
        textField.becomeFirstResponder()
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    /**
     Handles the action when the follow button is tapped.
     
     - Parameter sender: The button triggering the action.
     */
    @IBAction func followAction(_ sender:UIButton) {
        
        if(LikeOrFollow == "Like") {
            let charity = charityLikeArray![sender.tag]
            if(sender.isSelected) {
                sender.isSelected = false
                charityCount = "0"
            }else {
                charityCount = "1"
                sender.isSelected = true
            }
            followAction(follow: charityCount!, charityId: charity.id!,index:sender.tag)
        } else if(LikeOrFollow == "Donation") {
            let charity = charityDonationArray![sender.tag]
            if(sender.isSelected) {
                sender.isSelected = false
                charityCount = "0"
            }else {
                charityCount = "1"
                sender.isSelected = true
            }
            followAction(follow: charityCount!, charityId: charity.id!,index:sender.tag)
        } else {
            let charity = charityFollowArray![sender.tag]
            if(sender.isSelected) {
                sender.isSelected = false
                charityCount = "0"
            } else{
                charityCount = "1"
                sender.isSelected = true
            }
            followAction(follow: charityCount!, charityId: charity.id!,index:sender.tag)
        }
        
    }
    
    /**
     Dismisses the keyboard when tapping outside of text fields.
     
     - Parameter recognizer: The gesture recognizer triggering the action.
     */
    @objc func cancelView(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    /**
     Handles the action when the cancel button is tapped.
     
     This method removes the blur view from the superview.
     
     - Parameter sender: The button triggering the action.
     */
    @IBAction func cancelAction(_ sender:UIButton) {
        blurView.removeFromSuperview()
    }
    
    /**
     Handles the action of liking or unliking a charity.
     
     This method sends a network request to like or unlike a charity based on the provided parameters.
     If the user is not logged in, it presents an alert prompting the user to log in or register.
     Upon successful response, it updates the UI based on the charity's like status.
     
     - Parameters:
     - like: Indicates whether to like or unlike the charity (0 for unlike, 1 for like).
     - charityId: The ID of the charity to be liked or unliked.
     - index: The index of the charity in the array.
     */
    func charityLikeAction(like: String, charityId: String, index: Int) {
        // Check if user is logged in
        if let data = UserDefaults.standard.data(forKey: "people"),
           let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            // User is logged in, proceed with like/unlike action
            let postDict: Parameters = ["user_id": myPeopleList.userID,
                                        "token": myPeopleList.token,
                                        "charity_id": charityId,
                                        "status": like]
            let logINString = String(format: URLHelper.iDonateCharityLike)
            WebserviceClass.sharedAPI.performRequest(type: CharityLikeModel.self, urlString: logINString, methodType: .post, parameters: postDict, success: { (response) in
                // Handle successful response
                self.charityLIkeResponseMEthod(index: index, liked: like)
            }) { (response) in
                // Handle failure
            }
        } else {
            // User is not logged in, prompt to log in or register
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "For Advanced Features Please Log in/Register", attributes: messageFont)
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
    
    /**
     Handles the action of following or unfollowing a charity.
     
     This method sends a network request to follow or unfollow a charity based on the provided parameters.
     If the user is not logged in, it presents an alert prompting the user to log in or register.
     Upon successful response, it updates the UI based on the charity's follow status.
     
     - Parameters:
     - follow: Indicates whether to follow or unfollow the charity (0 for unfollow, 1 for follow).
     - charityId: The ID of the charity to be followed or unfollowed.
     - index: The index of the charity in the array.
     */
    func followAction(follow: String, charityId: String, index: Int) {
        // Check if user is logged in
        if let data = UserDefaults.standard.data(forKey: "people"),
           let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            // User is logged in, proceed with follow/unfollow action
            let postDict: Parameters = ["user_id": myPeopleList.userID,
                                        "token": myPeopleList.token,
                                        "charity_id": charityId,
                                        "status": follow]
            let charityFollowUrl = String(format: URLHelper.iDonateCharityFollow)
            WebserviceClass.sharedAPI.performRequest(type: CharityLikeFollowStatus.self, urlString: charityFollowUrl, methodType: .post, parameters: postDict, success: { (response) in
                // Handle successful response

                self.charityfollowResponseMethod(index: index, followed: follow)
            }) { (response) in
                // Handle failure
            }
        } else {
            // User is not logged in, prompt to log in or register
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "For Advanced Features Please Log in/Register", attributes: messageFont)
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
    func charityfollowResponseMethod(index: Int, followed: String) {
        // Update UI based on LikeOrFollow type
        if LikeOrFollow == "Like" {
            let charity = self.charityLikeArray?[index]
            charity?.followed = followed
            self.charityLikeArray?[index] = charity!
        } else if LikeOrFollow == "Donation" {
            var charity = self.charityDonationArray?[index]
            charity?.followed = followed
            self.charityDonationArray?[index] = charity!
        } else {
            let charity = self.charityFollowArray?[index]
            charity?.followed = followed
            self.charityFollowArray?[index] = charity!
        }
        
        // Reload table view to reflect changes
        self.searchTableView.reloadData()
    }

    /**
     Updates the UI based on the charity's like status after a like/unlike action.
     
     This method adjusts the like count and status of the charity based on the provided parameters.
     It also updates the respective charity array and reloads the table view to reflect the changes.
     
     - Parameters:
     - index: The index of the charity in the array.
     - liked: Indicates whether the charity is liked or unliked (0 for unliked, 1 for liked).
     */
    func charityLIkeResponseMEthod(index: Int, liked: String) {
        // Update UI based on LikeOrFollow type
        if (LikeOrFollow == "Like")  {
            let charity = self.charityLikeArray?[index]
            if (liked == "1") {
                // Charity is liked
                charity?.liked = "1"
                let likedCount = (Int(charity?.like_count ?? "0") ?? 0) + 1
                charity?.like_count = String(likedCount)
            } else {
                // Charity is unliked
                charity?.liked = "0"
                let likedCount = (Int(charity?.like_count ?? "0") ?? 0) - 1
                charity?.like_count = String(likedCount)
            }
            self.charityLikeArray?[index] = charity!
        } else if (LikeOrFollow == "Donation")  {
            var charity = self.charityDonationArray?[index]
            if (liked == "1") {
                // Charity is liked
                charity?.liked = "1"
                let likedCount = (Int(charity?.like_count ?? "0") ?? 0) + 1
                charity?.like_count = String(likedCount)
            } else {
                // Charity is unliked
                charity?.liked = "0"
                let likedCount = (Int(charity?.like_count ?? "0") ?? 0) - 1
                charity?.like_count = String(likedCount)
            }
            self.charityDonationArray?[index] = charity!
        } else {
            let charity = self.charityFollowArray?[index]
            if (liked == "1") {
                // Charity is liked
                charity?.liked = "1"
                let likedCount = (Int(charity?.like_count ?? "0") ?? 0) + 1
                charity?.like_count = String(likedCount)
            } else {
                // Charity is unliked
                charity?.liked = "0"
                let likedCount = (Int(charity?.like_count ?? "0") ?? 0) - 1
                charity?.like_count = String(likedCount)
            }
            self.charityFollowArray?[index] = charity!
        }
        
        // Reload table view to reflect changes
        self.searchTableView.reloadData()
    }
}
extension MySpaceDetails {
    
    /**
     Displays processing charges based on the entered donation amount.
     
     This method calculates and displays the processing fees, merchant charges, and total amount
     for the entered donation. It adds the processing charges view to the current view.
     
     - Parameter sender: The button triggering the action.
     */
    @IBAction func showProcessingCharges(_ sender: UIButton) {
        // Dismiss keyboard
        self.view.endEditing(true)
        
        // Show processing charges view
        processingCharges.isHidden = false
        processingCharges.layer.cornerRadius = 10
        
        // Extract entered donation amount
        guard let amount = amountText.text else {
            return
        }
        
        let amountWithoutDollar = amount.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard Double(amountWithoutDollar) != 0 else {
            return
        }
        
        // Calculate processing fees, merchant charges, and total amount
        let processingValue = self.calculatePercentage(value: Double(amountWithoutDollar) ?? 0, percentageVal: 1)
        let amountWithProcessingValue = (Double(amountWithoutDollar) ?? 0) + processingValue
        let merchantChargesValue = self.calculatePercentage(value: amountWithProcessingValue , percentageVal: 2.9) + 0.30
        let totalAmount = amountWithProcessingValue + merchantChargesValue
        
        // Display calculated values in processing charges view
        processingCharges.donationAmountValue.text = "$ " + amountWithoutDollar
        processingCharges.processingFeeValue.text = "$ " + String(format: "%.2f", processingValue)
        processingCharges.merchantChargesValue.text = "$ " + String(format: "%.2f", merchantChargesValue)
        processingCharges.totalAmountValue.text = "$ " + String(format: "%.2f", totalAmount)
        
        // Add processing charges view to the current view
        self.view.addSubview(processingCharges)
        
        // Set up close button action
        processingCharges.closeBtn.addTarget(self, action: #selector(hideProcessingCharges), for: .touchUpInside)
    }
    
    /**
     Hides the processing charges view.
     
     This method hides the processing charges view from the current view.
     */
    @objc func hideProcessingCharges() {
        processingCharges.isHidden = true
        processingCharges.removeFromSuperview()
    }
}
