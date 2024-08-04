//
//  LoginVC.swift
//  i2-Donate


import UIKit
import GoogleSignIn
import FBSDKLoginKit
import Alamofire
import MBProgressHUD
import TKFormTextField
import AuthenticationServices
import KeychainSwift

/// View controller for handling user login.

class LoginVC: BaseViewController, GIDSignInDelegate, ASAuthorizationControllerDelegate, UITextFieldDelegate {
 
    
    // Properties to store login information
    var loginArray: loginModelArray?
    var loginModelResponse:  loginModel?
    var activeField: UITextField?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    var userName: String = ""
    var email: String = ""
    var profileUrl: String = ""
    var loginType: String = ""
    var faceBookDict: [String:Any] = [:]
    var RegisterArray: RegisterModelArray?
    var RegisterModelResponse: RegisterModel?
    
    // Outlets for UI elements
    @IBOutlet var containerView: UIView!
    @IBOutlet var passwordText: TKFormTextField!
    @IBOutlet var emailText: TKFormTextField!
    @IBOutlet var showhidebtn: UIButton!
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var appleLoginBtn:UIButton!
    
    // Flags
    var comingFromTypes = false
    var isSKipUpdateProfile = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add menu button to the view
        self.view.addSubview(menuBtn)
        
        // Set menu button frame based on safe area
        if(iDonateClass.hasSafeArea) {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        // Add target for menu button action
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        // Add tap gesture to dismiss keyboard
        self.containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        
        // Check if user is logged in with Facebook
        if AccessToken.current != nil {
            // User is logged in, use 'accessToken' here.
        }
        
        // Setup text fields
        setUpTextfield()
        
        // Customize Apple login button
        self.appleLoginBtn.layer.cornerRadius = appleLoginBtn.frame.size.width/2
        self.appleLoginBtn.clipsToBounds = true
        self.appleLoginBtn.backgroundColor = .black
    }
    
    @IBAction func handleAuthorizationAppleIDButtonPress(sender:Any){
        // Handle Apple ID authorization button press
        
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let keychain = KeychainSwift()
            if let userID = keychain.get("Apple_user") {
                appleIDProvider.getCredentialState(forUserID: userID) {  (credentialState, error) in
                    switch credentialState {
                    case .authorized:
                        // The Apple ID credential is valid.
                        debugPrint("AppleLoginDetails authorized")
                        DispatchQueue.main.async {
                            let email = keychain.get("Apple_email")
                            let name = keychain.get("Apple_name")
                            
                            self.userName = keychain.get("Apple_name") ?? ""
                            self.email = keychain.get("Apple_email") ?? ""
                            self.profileUrl = ""
                            self.isSKipUpdateProfile = true
                            self.soacialLogin(socialType: "Apple")
                        }
                        break
                    case .revoked:
                        // The Apple ID credential is revoked.
                        self.appleLogin()
                        break
                    case .notFound:
                        // No credential was found, so show the sign-in UI.
                        self.appleLogin()
                        break
                    default:
                        break
                    }
                }
            } else {
                self.appleLogin()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func appleLogin(){
        // Start Apple login process
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    func setUpTextfield() {
        // Set up text fields
        
        // Set placeholder, return key type, and delegate for email text field
        self.emailText.placeholder = "Email"
        self.emailText.enablesReturnKeyAutomatically = true
        self.emailText.returnKeyType = .next
        self.emailText.delegate = self
        
        // Set placeholder, return key type, delegate, and secure text entry for password text field
        self.passwordText.placeholder = "Password"
        self.passwordText.enablesReturnKeyAutomatically = true
        self.passwordText.returnKeyType = .done
        self.passwordText.delegate = self
        self.passwordText.isSecureTextEntry = true
        
        // Add target for error updating for both email and password text fields
        self.addTargetForErrorUpdating(self.emailText)
        self.addTargetForErrorUpdating(self.passwordText)
        
        // Customize text field labels and error appearance
        self.emailText.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.emailText.font = UIFont.systemFont(ofSize: 18)
        self.emailText.selectedTitleColor = UIColor.darkGray
        self.emailText.titleColor = UIColor.darkGray
        self.emailText.placeholderColor = UIColor.darkGray
        self.emailText.errorLabel.font = UIFont.systemFont(ofSize: 18)
        
        self.passwordText.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.passwordText.font = UIFont.systemFont(ofSize: 18)
        self.passwordText.errorLabel.font = UIFont.systemFont(ofSize: 18)
        self.passwordText.selectedTitleColor = UIColor.darkGray
        self.passwordText.placeholderColor = UIColor.darkGray
        self.passwordText.titleColor = UIColor.darkGray
        
        // Customize line colors and heights for text fields
        self.emailText.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.emailText.selectedLineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.emailText.selectedLineHeight = 2
        
        self.passwordText.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.passwordText.selectedLineColor  = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.passwordText.selectedLineHeight = 2
        
        // Set accessibility identifiers for UI testing
        self.emailText.accessibilityIdentifier = "email-textfield"
        self.passwordText.accessibilityIdentifier = "password-textfield"
    }
    
    func addTargetForErrorUpdating(_ textField: TKFormTextField) {
        // Add targets for error updating
        
        // Add targets for editing changed and editing did end events
        textField.addTarget(self, action: #selector(clearErrorIfNeeded), for: .editingChanged)
        textField.addTarget(self, action: #selector(updateError), for: .editingDidEnd)
    }
    
    @objc func updateError(textField: TKFormTextField) {
        // Update error for the given text field
        
        // Set error label based on validation error
        textField.error = validationError(textField)
    }
    
    @objc func clearErrorIfNeeded(textField: TKFormTextField) {
        // Clear error if needed for the given text field
        
        // Clear error label if there is no validation error
        if validationError(textField) == nil {
            textField.error = nil
        }
    }
    
    private func validationError(_ textField: TKFormTextField) -> String? {
        // Check validation error for the given text field
        
        // Check validation error for email and password text fields
        if textField == emailText {
            return TKDataValidator.email(text: textField.text)
        }
        if textField == passwordText {
            return TKDataValidator.password(text: textField.text)
        }
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Register for keyboard notifications and set Google sign-in delegate
        
        // Register for keyboard show and hide notifications
        NotificationCenter.default.addObserver(self, selector: #selector(LoginVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Set Google sign-in delegate
        GIDSignIn.sharedInstance().delegate = self
    }
    
    @IBAction func showORHideAction(_ sender: UIButton) {
        // Handle show/hide action for password text field
        
        // Toggle secure text entry for password text field
        if(sender.isSelected == true){
            sender.isSelected = false
            passwordText.isSecureTextEntry = true
        }
        else{
            sender.isSelected = true
            passwordText.isSecureTextEntry = false
        }
    }
    
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        // Handle tap gesture to dismiss keyboard
        
        // Resign first responder if active field is not nil
        guard activeField != nil else {
            return
        }
        activeField?.resignFirstResponder()
        activeField = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Sign out from Google sign-in and remove keyboard notifications
        
        // Sign out from Google sign-in
        GIDSignIn.sharedInstance()?.signOut()
        
        // Remove keyboard notifications observer
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func backAction(_sender:UIButton) {
        // Handle back button action
        
        // Dismiss keyboard
        self.view.endEditing(true)
        
        // Check if coming from types
        if comingFromTypes == true {
            // Pop view controller if coming from types
            self.navigationController?.popViewController(animated: true)
        } else {
            // Navigate to HomeTabViewController if not coming from types
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
            self.navigationController?.pushViewController(vc!, animated: false)
        }
    }
    
    @IBAction func googleSignIN(_ sender: UIButton) {
        // Handle Google sign-in button action
        
        // Set presenting view controller and sign in with Google
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.shouldFetchBasicProfile = true
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    
    @IBAction func loginAction(_ sender:UIButton) {
        // Check if email and password are empty
        if(emailText.text == "") && (passwordText.text == "") {
            // Show alert if username and password are not entered
            showAlert(message: "Please enter username and password")
        }
        else {
            // Create dictionary with email and password
            let postDict: Parameters = ["email":emailText.text ?? "" ,"password":passwordText.text ?? ""]
            
            // Construct the URL string for login API
            let logINString = String(format: URLHelper.iDonateLogin)
            
            // Show loading indicator
            let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Loading"
            
            // Call the login API using shared API manager
            WebserviceClass.sharedAPI.performRequest(type: loginModel.self ,urlString: logINString, methodType: .post, parameters: postDict, success: { (response) in
                // Handle successful API response
                
                // Store response in login model
                self.loginModelResponse = response
                self.loginArray  = self.loginModelResponse?.data
                self.loginType = "Login"
                
                // Process login response
                self.loginResponsemethod()
                
                // Save email as username in UserDefaults
                UserDefaults.standard.setValue(self.emailText.text!, forKey: "password")
                
                // Print login array result
                print("Result: \(String(describing: self.loginArray))") // response serialization result
                
                // Hide loading indicator
                MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                
            }) { (response) in
                // Handle API error response
                // Hide loading indicator
                MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            }
        }
    }
    
    /**
     Method to handle the response after attempting login.
     - If the login is successful, it saves user details in UserDefaults and navigates to the HomeTabViewController.
     - If the login fails, it displays an alert with the error message.
     */
    func loginResponsemethod() {
        // Check if login status is successful
        if(self.loginModelResponse?.status == 1) {
            // Create UserDetails object with login data
            let newPerson = UserDetails(name: self.loginArray!.name!, email: self.loginArray!.email!, mobileNumber: self.loginArray?.phone_number ?? "", gender: self.loginArray?.gender ?? "", profileUrl:self.loginArray?.photo ?? "", country: self.loginArray?.country ?? "",token: self.loginArray?.token ?? "",userID:self.loginArray?.user_id ?? "", type: self.loginArray?.type ?? "",businessName: self.loginArray?.business_name ?? "", terms: "Yes")
            
            // Archive UserDetails object and save to UserDefaults
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: newPerson)
            UserDefaults.standard.set(encodedData, forKey: "people")
            UserDefaults.standard.set( self.loginArray!.name, forKey: "username")
            UserDefaults.standard.synchronize()
            
            // Navigate to appropriate view controller based on login type
            if comingFromTypes == true {
                self.navigationController?.popViewController(animated: true)
            } else {
                constantFile.changepasswordBack = true
                UserDefaults.standard.set("Login", forKey: "loginType")
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
                vc?.selectedIndex = 0
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        } else {
            // Display an alert if login fails
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string:(self.loginModelResponse?.message ?? "")!, attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /**
     Method to display an alert with a given message.
     - Parameter message: The message to be displayed in the alert.
     */
    func showAlert(message:String) {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
        let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
        let messageAttrString = NSMutableAttributedString(string:message, attributes: messageFont)
        alertController.setValue(messageAttrString, forKey: "attributedMessage")
        let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in }
        alertController.addAction(contact)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /**
     Method to navigate to the ForgotVC for resetting password.
     */
    @IBAction func forgotPassword(_ sender:UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ForgotVC") as? ForgotVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    /**
     Method to handle Facebook login.
     - Logs in with Facebook credentials and retrieves user data.
     - If successful, navigates to the UpdateProfileVC for further processing.
     */
    @IBAction func facebookLogin(_ sender:UIButton) {
        let fbLoginManager : LoginManager = LoginManager()
        
        // Log out if user is already logged in
        if let token = AccessToken.current, !token.isExpired {
            fbLoginManager.logOut()
        }
        
        // Log in with Facebook credentials
        fbLoginManager.logIn(permissions: ["email","public_profile"], from: self) { (result, error) in
            if((result?.isCancelled)!) {
                // Handle cancelation of login
                self.view.endEditing(true)
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RegisterVC") as? RegisterVC
                self.navigationController?.pushViewController(vc!, animated: false)
            }
            if (error == nil){
                let fbloginresult : LoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email")) {
                        if((AccessToken.current) != nil){
                            // Retrieve user data from Facebook
                            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completion: { (connection, result, error) -> Void in
                                if (error == nil){
                                    // Process user data if retrieval is successful
                                    self.faceBookDict = result as! [String : AnyObject]
                                    print( self.faceBookDict["email"] as Any)
                                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UpdateProfileVC") as? UpdateProfileVC
                                    vc?.userEmail = self.faceBookDict["email"] as! String
                                    vc?.userName =  self.faceBookDict["name"] as! String
                                    let facebookID = self.faceBookDict["id"]
                                    let facebookProfile: String = "http://graph.facebook.com/\(facebookID ?? "")/picture?type=small"
                                    self.userName = self.faceBookDict["name"] as! String
                                    self.email = self.faceBookDict["email"] as! String
                                    self.profileUrl = facebookProfile
                                    self.soacialLogin(socialType: "Facebook")
                                }
                            })
                        }
                    }
                }
            }
            else {
                // Handle error during Facebook login
                print("cancel by user")
            }
        }
    }
    
    
    /**
     Method triggered when the Twitter login button is pressed.
     - Uses TwitterHandler to perform Twitter login.
     - Handles the completion and failure blocks.
     */
    @IBAction func twitterLogin(_ sender: UIButton) {
        TwitterHandler.shared.loginWithTwitter(self, { userinfo in
            // Handle successful Twitter login
            self.view.isUserInteractionEnabled = true
            self.userName = userinfo.userfName
            self.email = userinfo.email
            self.profileUrl = userinfo.userProfileUrl
            self.soacialLogin(socialType: "Twitter")
        }, {
            // Handle Twitter login failure
        })
    }
    
    /**
     Delegate method called after Google sign-in.
     - Handles the successful sign-in and retrieves user information.
     - Handles sign-in errors.
     */
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            // Handle Google sign-in error
            self.view.endEditing(true)
            print("\(error.localizedDescription)")
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RegisterVC") as? RegisterVC
            self.navigationController?.pushViewController(vc!, animated: false)
        } else {
            // Handle successful Google sign-in
            print(user.userID)
            print(user.profile.name)
            var pictures :URL?
            if (GIDSignIn.sharedInstance().currentUser.profile.hasImage) {
                let dimension = round(100 * UIScreen.main.scale);
                pictures = user.profile.imageURL(withDimension: UInt(dimension))
            }
            userName = user.profile.name
            email = user.profile.email
            profileUrl = pictures?.absoluteString ?? ""
            soacialLogin(socialType: "Gmail")
        }
    }
    
    /**
     Method to perform social login.
     - Constructs post data with user information.
     - Sends a request to the server for social login.
     - Handles success and failure responses.
     */
    func soacialLogin(socialType:String) {
        let postDict = ["name": userName,"email":email ,"login_type":socialType,"photo":profileUrl,"type":"individual"] as [String : Any]
        let socialLoginUrl = String(format: URLHelper.iDonateSocialLogin)
        let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        debugPrint("Social.Request",postDict)
        WebserviceClass.sharedAPI.performRequest(type: loginModel.self ,urlString: socialLoginUrl, methodType: .post, parameters: postDict, success: { (response) in
            self.loginModelResponse = response
            self.loginArray  = self.loginModelResponse?.data
            self.loginType = "Social"
            UserDefaults.standard.set("Social", forKey: "loginType")
            self.loginResponsemethod()
            print("Result: \(String(describing: self.loginArray))") // response serialization result
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }) { (response) in
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }
    }
    
    /**
     Method to validate email format.
     - Validates whether the given email string follows the correct format.
     - Returns true if the email format is valid, otherwise false.
     */
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    /**
     Notification observer method called when the keyboard will show.
     - Adjusts the content inset of the scroll view to accommodate the keyboard.
     */
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 100
        scrollView.contentInset = contentInset
    }
    
    /**
     Notification observer method called when the keyboard will hide.
     - Resets the content inset of the scroll view after the keyboard hides.
     */
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
}
extension LoginVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
}
