//
//  SearchDetailsVC.swift
//  i2-Donate
//

import UIKit
import SideMenu
import AlamofireImage
import Alamofire
import TKFormTextField
import MBProgressHUD
import WebKit
import SafariServices

/**
 `SearchDetailsVC` displays details about a charity and allows users to interact with it.
 
 This view controller inherits from `BaseViewController` and conforms to multiple protocols including `UICollectionViewDelegate`, `UICollectionViewDataSource`, `UICollectionViewDelegateFlowLayout`, `UITabBarDelegate`, `UITextFieldDelegate`, `WKNavigationDelegate`, `WKScriptMessageHandler`, `WKUIDelegate`, and `SFSafariViewControllerDelegate`.
 */
class SearchDetailsVC: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITabBarDelegate, UITextFieldDelegate, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate, SFSafariViewControllerDelegate {
 
    
    /// Represents the details of the charity.
    var charityList: CharityListArray?
    
    /// An array containing the options for browsing details.
    let browseList = ["Leadership & Team", "Values", "Impact", "Contact"]
    
    /// IBOutlet for the UICollectionView displaying browse options.
    @IBOutlet var browseCollectionList: UICollectionView!
    
    /// IBOutlet for the UITabBar.
    @IBOutlet var notificationTabBar: UITabBar!
    
    /// IBOutlet for the header label displaying the charity name.
    @IBOutlet var headerLBL: UILabel!
    
    /// IBOutlet for the label displaying the charity address.
    @IBOutlet var adderssLbl: UILabel!
    
    /// IBOutlet for the like button.
    @IBOutlet var likeBTN: UIButton!
    
    /// IBOutlet for the follow button.
    @IBOutlet var followBTn: UIButton!
    
    /// IBOutlet for the donate button.
    @IBOutlet var donateBTn: UIButton!
    
    /// IBOutlet for the logo image view.
    @IBOutlet var logoIMage: UIImageView!
    
    /// IBOutlet for the UIVisualEffectView used for blurring.
    @IBOutlet var blurView: UIVisualEffectView!
    
    /// IBOutlet for the cancel button.
    @IBOutlet var cancelBtn: UIButton!
    
    /// IBOutlet for the UITextField for entering donation amount.
    @IBOutlet var amountText: TKFormTextField!
    @IBOutlet var continuePaymentBTn : UIButton!

    /// Represents the response after liking the charity.
    var charityLikeResponse: CharityLikeModel?
    
    /// Represents the response after following the charity.
    var followResponse: FollowModel?
    
    /// Represents the user ID.
    var userID: String = ""
    
    /// Indicates if a donation is in progress.
    var donateFlag: Bool = false
    
    /// A weak reference to the PaymentDelegate protocol.
    weak var payDelegate: PaymentDelegate?
    
    /// A WKWebView used for displaying web content.
    var webView: WKWebView!
    
    /// A UIView used to contain the WKWebView.
    var webViewContainer: UIView!
    
    /// A UIButton used for navigating back in the WKWebView.
    var backButton: UIButton!
    
    /// A view displaying processing charges.
    var processingCharges = ProcessingChargesView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
    
    /// The maximum number of digits allowed before the decimal point in donation amount.
    let digitBeforeDecimal = 5
    
    /// The maximum number of digits allowed after the decimal point in donation amount.
    let digitAfterDecimal = 2
    
    /// Indicates if a decimal point has been added.
    var decimalAdded = false
    
    /**
     This method is called when the view is loaded into memory.
     It sets up UI elements, adds gesture recognizers, and initializes web view configuration.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up menu button position based on safe area
        if iDonateClass.hasSafeArea {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        // Add menu button and set image
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view.addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        // Update charity details UI
        updateDetails()
        
        // Add tap gesture recognizer to blur view for dismissing view
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cancelView))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.cancelsTouchesInView = false
        self.blurView.addGestureRecognizer(tapGestureRecognizer)
        
        // Add observers for keyboard show and hide notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Configure WKWebView
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "dismissWebView")
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.preferences.javaScriptEnabled = true
        self.webView = WKWebView(frame: self.view.frame, configuration: configuration)
        self.webView.navigationDelegate = self
        self.webView?.uiDelegate = self
    }
    
    /**
     Validates the entered donation amount in the text field.
     
     - Parameters:
     - textField: The text field being edited.
     - range: The range of characters to be replaced.
     - string: The replacement string.
     
     - Returns: A boolean value indicating whether the replacement should be made.
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Check if amountText is empty
        if self.amountText.text!.isEmpty {
            decimalAdded = false
        }
        
        // Check if decimal point is already added
        if self.amountText.text!.contains(".") {
            decimalAdded = true
        } else {
            decimalAdded = false
        }
        
        // Prevent entering multiple decimal points
        if decimalAdded && string == "." {
            return false
        }
        
        // Validate maximum number of digits before and after decimal point
        if textField != self.amountText {
            return true
        }
        let computationString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if computationString.contains("..") {
            return false
        }
        let arrayOfSubStrings = computationString.components(separatedBy: ".")
        if arrayOfSubStrings.count == 1 && computationString.count > digitBeforeDecimal {
            return false
        } else if arrayOfSubStrings.count == 2 {
            let stringPostDecimal = arrayOfSubStrings[1]
            return stringPostDecimal.count <= digitAfterDecimal
        }
        return true
    }
    
    
    /**
     Adjusts the view's frame when the keyboard is about to be shown.
     
     - Parameter notification: Notification containing information about the keyboard.
     */
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            // Check if donation flag is true
            if donateFlag == true {
                // Check if view's origin is at its initial position
                if self.view.frame.origin.y == 0 {
                    // Shift the view upwards by the height of the keyboard
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }
    
    /**
     Adjusts the view's frame when the keyboard is about to be hidden.
     
     - Parameter notification: Notification containing information about the keyboard.
     */
    @objc func keyboardWillHide(notification: NSNotification) {
        // Check if view's origin is not at its initial position
        if self.view.frame.origin.y != 0 {
            // Reset the view's origin to its initial position
            self.view.frame.origin.y = 0
        }
    }
    
    /**
     Updates the details of the charity displayed on the view.
     */
    func updateDetails() {
        // Set header label text to charity name
        headerLBL.text = charityList!.name
        // Set address label text to charity street and city
        adderssLbl.text = charityList!.street! + "," + charityList!.city!
        // Set like button title with like count
        let likeCount = charityList?.like_count ?? "0"
        let likeString = likeCount + " Likes"
        // Use likeString
        likeBTN.setTitle(likeString, for: .normal)
        
        // Set placeholder image
        let placeholderImage = UIImage(named: "defaultImageCharity")!
        
        // Load charity logo if available
        if let logoURL = charityList?.logo {
            if let url = URL(string: logoURL) {
                logoIMage.af.setImage(withURL: url, placeholderImage: placeholderImage)
            }
        } else {
            // Set default placeholder image if logo is not available
            logoIMage.image = placeholderImage
        }
        
        // Set follow button state and title based on charity follow status
        if charityList!.followed == "0" {
            followBTn.isSelected = false
            followBTn.setTitle("Follow", for: .normal)
        } else {
            followBTn.isSelected = true
            followBTn.setTitle("Following", for: .normal)
        }
        
        // Set like button state based on charity like status
        if charityList!.liked == "0" {
            likeBTN.isSelected = false
        } else {
            likeBTN.isSelected = true
        }
    }
    
    
    /**
     Handles the action when the back button is tapped.
     
     - Parameter _sender: The button triggering the action.
     */
    @objc func backAction(_sender: UIButton) {
        // Pops the current view controller from the navigation stack with animation
        self.navigationController?.popViewController(animated: true)
    }
    
    /**
     Handles the action when the like button is tapped.
     
     - Parameter sender: The button triggering the action.
     */
    @IBAction func likeAction(_ sender: UIButton) {
        if let data = UserDefaults.standard.data(forKey: "people"),
           let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            // Access user details from UserDefaults
            var likeCount: String = ""
            userID = myPeopleList.userID
            
            if sender.isSelected {
                sender.isSelected = false
                likeCount = "0"
                
            } else {
                likeCount = "1"
                sender.isSelected = true
            }
            
            // Perform charity like action with updated like count
            charityLikeAction(like: likeCount, charityId: charityList!.id!)
        } else {
            // Display alert prompting user to log in or register for advanced features
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "For Advanced Features Please Log-in/Register", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result: UIAlertAction) -> Void in
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { (result: UIAlertAction) -> Void in
                // Handle cancel action if needed
            }
            alertController.addAction(ok)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /**
     Handles the action when the view is tapped to cancel an action.
     
     - Parameter recognizer: The tap gesture recognizer.
     */
    @objc func cancelView(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    /**
     Handles the action when the cancel button is tapped.
     
     - Parameter sender: The button triggering the action.
     */
    @IBAction func cancelAction(_ sender: UIButton) {
        blurView.removeFromSuperview()
    }
    
    /**
     Handles the action when the back button is tapped in the web view.
     */
    @objc func backButtonTapped() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    /**
     Handles the action when the follow button is tapped.
     
     - Parameter sender: The button triggering the action.
     */
    @IBAction func followAction(_ sender: UIButton) {
        if let data = UserDefaults.standard.data(forKey: "people"),
           let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            var follow: String = ""
            if sender.isSelected {
                sender.isSelected = false
                follow = "0"
            } else {
                follow = "1"
                sender.isSelected = true
            }
            // Construct parameters for the follow action
            let postDict = ["user_id": myPeopleList.userID, "token": myPeopleList.token, "charity_id": charityList?.id, "status": follow]
            let charityFollowUrl = String(format: URLHelper.iDonateCharityFollow)
            
            // Perform follow action API call
            WebserviceClass.sharedAPI.performRequest(type: FollowModel.self, urlString: charityFollowUrl, methodType:  HTTPMethod.post, parameters: postDict as Parameters, success: { (response) in
                self.followResponse = response
                self.fellowResponse(follow: follow)
                print("Result: \(String(describing: response))") // Log response
            }) { (response) in
                // Handle error response if needed
            }
        } else {
            // Prompt user to log in/register for advanced features if not logged in
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "For Advanced Features Please Log-in/Register", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                // Handle cancel action if needed
            }
            alertController.addAction(ok)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /**
     Handles the action when the donate button is tapped.
     
     - Parameter sender: The button triggering the action.
     */
    @IBAction func donateAction(_ sender: UIButton)  {
        if let data = UserDefaults.standard.data(forKey: "people"),
           let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            // Show blur view and set continue payment button's tag
            blurView.frame = self.view.frame
            self.continuePaymentBTn.tag = sender.tag
            self.view.addSubview(blurView)
        } else {
            // Prompt user to log in/register for advanced features if not logged in
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "For Advanced Features Please Log-in/Register", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                // Handle cancel action if needed
            }
            alertController.addAction(ok)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /**
     Performs the donation to charity action.
     */
    func donateToCharity(charityID: String) {
        // Display loading indicator
        MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        
        if let data = UserDefaults.standard.data(forKey: "people"), let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            let userID = myPeopleList.userID
            let postDict: [String: String] = ["user_id": userID, "charity_id": charityID]
            let iDonateTransString = String(format: URLHelper.iDonateTrans)
            
            AF.request(iDonateTransString, method: .post, parameters: postDict, encoder: URLEncodedFormParameterEncoder.default).responseJSON { response in
                MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any], let urlString = json["url"] as? String, let paymentURL = URL(string: urlString) {
                        let safariViewController = SFSafariViewController(url: paymentURL)
                        safariViewController.delegate = self
                        self.present(safariViewController, animated: true, completion: nil)
                    } else {
                        print("Error: Invalid payment URL")
                        // You may display an error message to the user if needed
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    // You may display an error message to the user if needed
                }
            }
        }
    }

    
    /**
     Called when the web view finishes loading a navigation.
     
     - Parameter webView: The web view that finished navigation.
     - Parameter navigation: The navigation that finished.
     */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Check if the current URL contains success or cancel payment messages
        if let currentURL = webView.url {
            let payButtonScript = "document.getElementById('payButton').onclick = function() { window.webkit.messageHandlers.dismissWebView.postMessage('dismissWebView'); }"
            webView.evaluateJavaScript(payButtonScript, completionHandler: nil)
            print(webView.url)
            if currentURL.absoluteString.contains("donation_payment_show_successfull_msg") {
                // Dismiss the web view upon successful payment
                dismissWebView()
            }
            if currentURL.absoluteString.contains("donation_payment_cancel_payment") {
                // Dismiss the web view and display a message for cancelled payment
                dismissWebView()
                let alertController = UIAlertController(title: "Payment Cancelled", message: "Your donation payment has been cancelled.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    /**
     Handles the action when the payment button is tapped.
     
     - Parameter sender: The button triggering the action.
     */
    @IBAction func paymentAction(_ sender: UIButton) {
        if let data = UserDefaults.standard.data(forKey: "people"),
           let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            donateToCharity(charityID:  charityList!.id!)// Proceed with donation if user is logged in
        }
    }
    
    /**
     Called when the text field begins editing.
     
     - Parameter textField: The text field being edited.
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        donateFlag = true // Set donate flag when text field begins editing
        textField.becomeFirstResponder()
    }
    
    /**
     Called when the text field should return.
     
     - Parameter textField: The text field.
     - Returns: Always returns `true`.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    /**
     Performs the like action for the charity.
     
     - Parameters:
     - like: The status of the like action.
     - charityId: The ID of the charity.
     */
    func charityLikeAction(like: String, charityId: String) {
        if let data = UserDefaults.standard.data(forKey: "people"),
           let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            // Construct parameters for like action
            let postDict = ["user_id": myPeopleList.userID, "token": myPeopleList.token, "charity_id": charityId, "status": like]
            let charityLikeUrl = String(format: URLHelper.iDonateCharityLike)
            
            // Perform API call for like action
            WebserviceClass.sharedAPI.performRequest(type: CharityLikeModel.self, urlString: charityLikeUrl, methodType:  HTTPMethod.post, parameters: postDict as Parameters, success: { (response) in
                self.charityLikeResponse = response
                print("Result: \(String(describing: response))") // Log response
                self.charityResponse(like: like)
            }) { (response) in
                // Handle error response if needed
            }
        } else {
            // Handle condition if user data is not available
        }
    }
    
    /**
     Handles the response of charity like action.
     
     - Parameter like: The status of the like action.
     */
    func charityResponse(like: String) {
        if self.charityLikeResponse?.status == 1 {
            let charityCount = self.charityLikeResponse?.likecount
            let likeString = charityCount!.likeCount! + " Likes"
            likeBTN.setTitle(likeString, for: .normal)
        }
    }
    
    /**
     Handles the response of charity follow action.
     
     - Parameter follow: The status of the follow action.
     */
    func fellowResponse(follow: String) {
        if self.followResponse?.status == 1 {
            if follow == "1" {
                self.followBTn.setTitle("Following", for: .normal)
            } else {
                self.followBTn.setTitle("Follow", for: .normal)
            }
        }
    }
    
    /**
     Dismisses the web view.
     */
    @objc func dismissWebView() {
        webView.isHidden = true
        blurView.removeFromSuperview()
        webView.navigationDelegate = nil
        // Perform additional actions if needed after dismissing the web view
    }
    
    /**
     Called when the web content receives a message from JavaScript.
     
     - Parameters:
     - userContentController: The user content controller.
     - message: The message received from JavaScript.
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody = message.body as? String, messageBody == "dismissWebView" {
            dismissWebView()
        }
    }}
    // MARK: - Collection View Cell
    //cell for search detail table
    class searchDetailsCell: UICollectionViewCell {
        @IBOutlet var lbl_title: UILabel!
        @IBOutlet var img_view: UIImageView!
    
}
extension SearchDetailsVC {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return browseList.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchDetailsCell", for: indexPath)as! searchDetailsCell
        cell.lbl_title.text = browseList[indexPath.row]
        cell.img_view.image = UIImage(named: browseList[indexPath.row])
        return cell
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  20
        let collectionViewSize = collectionView.frame.size.width-padding
        return CGSize(width: collectionViewSize/2.0, height:collectionViewSize/2.0)
    }
}
