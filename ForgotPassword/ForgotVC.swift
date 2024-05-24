import UIKit
import TKFormTextField
import Alamofire
import MBProgressHUD

/// View controller responsible for handling the "Forgot Password" functionality.
class ForgotVC: BaseViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet var emailText: TKFormTextField!
    @IBOutlet var headingTag: UILabel!
    @IBOutlet var sendBtn: UIButton!
    
    // MARK: - Properties
    
    var forgotModel: ForgotModel?
    var forgotData: Forgotdata?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation image
        self.navIMage.isHidden = true
        
        // Adjust menu button position for devices with safe area
        if iDonateClass.hasSafeArea {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        // Add menu button to view
        menuBtn.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        self.view.addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        // Configure email text field
        configureEmailTextField()
        
        // Add tap gesture recognizer to dismiss keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update heading tag text
        if constantFile.changemail {
            headingTag.text = "CHANGE EMAIL"
        } else {
            headingTag.text = "FORGOT PASSWORD"
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Reset heading tag text and flag
        headingTag.text = "FORGOT PASSWORD"
        constantFile.changemail = false
    }
    
    // MARK: - UI Setup
    
    /// Configure email text field appearance and behavior.
    private func configureEmailTextField() {
        emailText.placeholder = "Email"
        emailText.enablesReturnKeyAutomatically = true
        emailText.returnKeyType = .done
        emailText.delegate = self
        emailText.accessibilityIdentifier = "email-textfield"
        
        // Customize appearance
        emailText.titleLabel.font = UIFont.systemFont(ofSize: 18)
        emailText.font = UIFont.systemFont(ofSize: 18)
        emailText.selectedTitleColor = .darkGray
        emailText.titleColor = .darkGray
        emailText.placeholderColor = .darkGray
        emailText.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        emailText.selectedLineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        emailText.selectedLineHeight = 2
        
        // Add target for error updating
        addTargetForErrorUpdating(emailText)
    }
    
    /// Add target for updating error message.
    private func addTargetForErrorUpdating(_ textField: TKFormTextField) {
        textField.addTarget(self, action: #selector(clearErrorIfNeeded), for: .editingChanged)
        textField.addTarget(self, action: #selector(updateError), for: .editingDidEnd)
    }
    
    // MARK: - Actions
    
    @objc private func returnTextView(gesture: UIGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc private func backAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Alert", message: "Returning To Login Without Making Changes?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Error Handling
    
    /// Update error message for the text field.
    @objc private func updateError(textField: TKFormTextField) {
        textField.error = validationError(textField)
    }
    
    /// Clear error message for the text field if needed.
    @objc private func clearErrorIfNeeded(textField: TKFormTextField) {
        if validationError(textField) == nil {
            textField.error = nil
        }
    }
    
    /// Validate the text field and return an error message if invalid.
    private func validationError(_ textField: TKFormTextField) -> String? {
        if textField == emailText {
            return TKDataValidator.email(text: textField.text)
        }
        return nil
    }
    
    // MARK: - Web Service
    
    @IBAction func sendAction(_sender : UIButton) {
           self.view .endEditing(true)
           if(emailText.text?.count == 0) {
               let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
               let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
               let messageAttrString = NSMutableAttributedString(string:"Please enter email id", attributes: messageFont)
               alertController.setValue(messageAttrString, forKey: "attributedMessage")
               let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
               }
               alertController.addAction(contact)
               self.present(alertController, animated: true, completion: nil)
           }
           else {
               let postDict:Parameters = ["email":emailText.text?.trimmingCharacters(in: .whitespaces) ?? ""]
               let forgotPasswordUrl = String(format: URLHelper.iDonateForgotPassword)
               let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
               loadingNotification.mode = MBProgressHUDMode.indeterminate
               loadingNotification.label.text = "Loading"
               
               WebserviceClass.sharedAPI.performRequest(type: ForgotModel.self ,urlString: forgotPasswordUrl, methodType: .post, parameters: postDict, success: { (response) in
                   
                   self.forgotModel = response
                   self.forgotData = self.forgotModel?.data
                   self.forgotResponse()
                   print("Result: \(String(describing: self.forgotModel))")                     // response serialization result
                   MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
               }) { (response) in
                   MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
               }
           }
       }
    
    /// Perform the forgot password request to the server.
    private func performForgotPasswordRequest() {
        let postDict: Parameters = ["email": emailText.text?.trimmingCharacters(in: .whitespaces) ?? ""]
        let forgotPasswordUrl = String(format: URLHelper.iDonateForgotPassword)
        let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        loadingNotification.label.text = "Loading"
        
        WebserviceClass.sharedAPI.performRequest(type: ForgotModel.self, urlString: forgotPasswordUrl, methodType: .post, parameters: postDict, success: { (response) in
            
            self.forgotModel = response
            self.forgotData = self.forgotModel?.data
            self.forgotResponse()
            print("Result: \(String(describing: self.forgotModel))") // Response serialization result
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }) { (response) in
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }
    }
    
    /// Handle the response received after the forgot password request.
    private func forgotResponse() {
        if self.forgotModel?.status == 1 {
            // Navigate to OTP verification screen
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "VerifyOTP") as? VerifyOTP
            vc?.email = self.emailText.text?.trimmingCharacters(in: .whitespaces)
            vc?.user_id = self.forgotData?.user_id
            self.navigationController?.pushViewController(vc!, animated: false)
        } else {
            // Display error message
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: (self.forgotModel?.message!)!, attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: .default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
