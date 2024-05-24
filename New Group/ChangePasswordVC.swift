//
//  ChangePasswordVC.swift
//  i2-Donate


import UIKit
import TKFormTextField
import Alamofire
import MBProgressHUD

/// Define the class `ChangePasswordVC` which inherits from `BaseViewController` and conforms to `UITextFieldDelegate`
class ChangePasswordVC: BaseViewController, UITextFieldDelegate {
    // MARK: - IBOutlets
    
    // IBOutlets for old and new password text fields, and buttons
    @IBOutlet var oldPassword: TKFormTextField!
    @IBOutlet var newPassword: TKFormTextField!
    @IBOutlet var oldPasswordBTN: UIButton!
    @IBOutlet var newPasswordBTN: UIButton!
    
    // MARK: - Properties
    
    // Model objects and other properties
    var forgotModel: ForgotModel? // Model for forgot password
    var forgotData: Forgotdata? // Data for forgot password
    var changeOrForgot: String? // Indicates whether it's a change or forgot password action
    var changeModel: ChangeModel? // Model for password change
    var email: String? // User's email
    var userId: String? // User ID
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adjust menu button frame based on safe area
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        // Set up menu button
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view.addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        // Register for keyboard show and hide notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Add tap gesture recognizer to dismiss keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        
        // Configure old password text field
        self.oldPassword.placeholder = "Old password"
        // Set up properties for old password text field...
        
        // Configure new password text field
        self.newPassword.placeholder = "New password"
        // Set up properties for new password text field...
        
        // Adjust placeholders based on change or forgot password action
        if(changeOrForgot == "Forgot") {
            self.oldPassword.placeholder = "New password"
            self.newPassword.placeholder = "Confirm password"
        } else {
            self.oldPassword.placeholder = "Old password"
            self.newPassword.placeholder = "New password"
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    
    
    
    // MARK: - Keyboard Handling
    
    // Method to adjust the view frame when the keyboard will show
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    // Method to reset the view frame when the keyboard will hide
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    // Method to dismiss the keyboard when tapping outside of text fields
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - Error Handling
    
    // Method to add target actions for error updating of text fields
    func addTargetForErrorUpdating(_ textField: TKFormTextField) {
        textField.addTarget(self, action: #selector(clearErrorIfNeeded), for: .editingChanged)
        textField.addTarget(self, action: #selector(updateError), for: .editingDidEnd)
    }
    
    // Method to update error messages for text fields
    @objc func updateError(textField: TKFormTextField) {
        textField.error = validationError(textField)
    }
    
    // Method to clear error messages if needed for text fields
    @objc func clearErrorIfNeeded(textField: TKFormTextField) {
        if validationError(textField) == nil {
            textField.error = nil
        }
    }
    
    // Private method to validate text fields for errors
    private func validationError(_ textField: TKFormTextField) -> String? {
        if textField == oldPassword || textField == newPassword {
            return TKDataValidator.password(text: textField.text)
        }
        return nil
    }
    
    // MARK: - Button Actions
    
    // Action method for toggling visibility of old password
    @IBAction func oldPassword(_ sender: UIButton) {
        sender.isSelected.toggle()
        oldPassword.isSecureTextEntry = !sender.isSelected
    }
    
    // Action method for toggling visibility of new password
    @IBAction func newPassword(_ sender: UIButton) {
        sender.isSelected.toggle()
        newPassword.isSecureTextEntry = !sender.isSelected
    }
    
    // Action method for handling back button action
    @objc func backAction(_sender:UIButton)  {
        let alertTitle = constantFile.changepasswordBack ? "Returning To settings Without Making Changes?" : "Returning To login Without Making Changes?"
        let alert = UIAlertController(title: "", message: alertTitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.view.endEditing(true)
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Action method for handling change password button action
    @IBAction func changePassword(_ sender: UIButton) {
        self.view.endEditing(true)
        if changeOrForgot == "Forgot" {
            upadtePassword()
        } else {
            changePassword()
        }
    }
    
    // Method to handle updating the password for the "Forgot" password case
    func upadtePassword() {
        
        // Check if either oldPassword or newPassword fields are empty
        if(oldPassword.text == "") || (newPassword.text == "") {
            // Create and present an alert for empty fields
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "Please enter all fields", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
        }
        // Check if oldPassword and newPassword fields do not match
        else if (oldPassword.text != newPassword.text) {
            // Create and present an alert for incorrect password match
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "Please enter correct password", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
        }
        // Check if both oldPassword and newPassword fields are not valid passwords
        else if self.oldPassword.text?.tk_isValidPassword() == false && self.newPassword.text?.tk_isValidPassword() == false {
            // Create and present an alert for invalid passwords
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "Please enter valid password", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        // Proceed to update the password
        else {
            let postDict = ["user_id": userId!, "password": newPassword.text as Any] as [String : Any]
            let updatePasswordString = String(format: URLHelper.iDonateUpdatePassword)
            let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Loading"
            
            // Perform the password update request
            WebserviceClass.sharedAPI.performRequest(type: ForgotModel.self, urlString: updatePasswordString, methodType: .post, parameters: postDict, success: { (response) in
                self.forgotModel = response
                self.result(status: (self.forgotModel?.status)!, message: (self.forgotModel?.message)!)
                print("Result: \(String(describing: response))") // Response serialization result
                MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            }) { (response) in
                MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            }
        }
    }
    
    
    func updatePasswordResponse() {
        
    }
    
    // Method to handle changing the password
    func changePassword() {
        
        // Check if either oldPassword or newPassword fields are empty
        if(oldPassword.text == "") || (newPassword.text == "") {
            showAlert(msg: "Please enter all fields")
        }
        // Check if oldPassword and newPassword fields are the same
        else if oldPassword.text == newPassword.text {
            showAlert(msg: "Old and New password have to be different")
        }
        // Check if newPassword is a valid password
        else if self.newPassword.text?.tk_isValidPassword() == false {
            showAlert(msg: "Please enter valid new password")
        }
        // Proceed to change the password
        else {
            // Retrieve user details from UserDefaults
            if let data = UserDefaults.standard.data(forKey: "people"),
               let user = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
                
                // Prepare the parameters for the password change request
                let postDict = ["user_id": user.userID, "token": user.token, "old_password": oldPassword.text as Any, "new_password": newPassword.text as Any] as [String : Any]
                let changePasswordUrl = String(format: URLHelper.iDonateChangePassword)
                
                // Show a loading notification
                let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
                loadingNotification.mode = MBProgressHUDMode.indeterminate
                loadingNotification.label.text = "Loading"
                
                // Perform the password change request
                WebserviceClass.sharedAPI.performRequest(type: ChangeModel.self, urlString: changePasswordUrl, methodType: .post, parameters: postDict, success: { (response) in
                    self.changeModel = response
                    self.result(status: (self.changeModel?.status)!, message: (self.changeModel?.message)!)
                    print("Result: \(String(describing: response))") // Response serialization result
                    MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                }) { (response) in
                    MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                }
            }
        }
    }
    
    // Method to handle the result of the password change request
    func result(status: Int, message: String) {
        // Check if the status is success (1)
        if(status == 1) {
            // Create and present a success alert
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: message, attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result: UIAlertAction) -> Void in
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
        } else {
            // Create and present an error alert
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: message, attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result: UIAlertAction) -> Void in }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // Method to show an alert with a given message
    func showAlert(msg: String) {
        // Create and present an alert with the provided message
        let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
        let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
        let messageAttrString = NSMutableAttributedString(string: msg, attributes: messageFont)
        alertController.setValue(messageAttrString, forKey: "attributedMessage")
        let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result: UIAlertAction) -> Void in }
        alertController.addAction(contact)
        self.present(alertController, animated: true, completion: nil)
    }
}
