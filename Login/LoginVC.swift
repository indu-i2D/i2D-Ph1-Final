//
//  LoginVC.swift
//  iDonate
//
//  Created by sureshkumar on 05/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit
import Alamofire
import MBProgressHUD
import TKFormTextField
import AuthenticationServices
import KeychainSwift


class LoginVC: BaseViewController,GIDSignInDelegate {
    
    var loginArray : loginModelArray?
    var loginModelResponse :  loginModel?
    var activeField: UITextField?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    var userName:String = ""
    var email:String = ""
    var profileUrl:String = ""
    var loginType:String = ""
    var faceBookDict : [String:Any] = [:]
    var RegisterArray :  RegisterModelArray?
    var RegisterModelResponse :  RegisterModel?
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var passwordText: TKFormTextField!
    @IBOutlet var emailText: TKFormTextField!
    @IBOutlet var showhidebtn: UIButton!
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var appleLoginBtn:UIButton!
    var comingFromTypes = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view .addSubview(menuBtn)

        if(iDonateClass.hasSafeArea) {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        }
        else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        self.containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        if AccessToken.current != nil {
            // User is logged in, use 'accessToken' here.
        }
        setUpTextfield()
        self.appleLoginBtn.layer.cornerRadius = appleLoginBtn.frame.size.width/2
        self.appleLoginBtn.clipsToBounds = true
    }
    
    @IBAction func handleAuthorizationAppleIDButtonPress(sender:Any){
        
       
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
            }else{
                
                self.appleLogin()
            }
        
           
          
        } else {
            // Fallback on earlier versions
        }
            
    }
    
    func appleLogin(){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    func setUpTextfield() {
        
        self.emailText.placeholder = "Email"
        self.emailText.enablesReturnKeyAutomatically = true
        self.emailText.returnKeyType = .next
        self.emailText.delegate = self
        
        self.passwordText.placeholder = "Password"
        self.passwordText.enablesReturnKeyAutomatically = true
        self.passwordText.returnKeyType = .done
        self.passwordText.delegate = self
        self.passwordText.isSecureTextEntry = true
        
        // Validation logic
        self.addTargetForErrorUpdating(self.emailText)
        self.addTargetForErrorUpdating(self.passwordText)
        
        // Customize labels
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
        self.emailText.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.emailText.selectedLineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.emailText.selectedLineHeight = 2
        self.passwordText.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.passwordText.selectedLineColor  = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.passwordText.selectedLineHeight = 2
        
        self.emailText.accessibilityIdentifier = "email-textfield"
        self.passwordText.accessibilityIdentifier = "password-textfield"
        
    }
    
    func addTargetForErrorUpdating(_ textField: TKFormTextField) {
        textField.addTarget(self, action: #selector(clearErrorIfNeeded), for: .editingChanged)
        textField.addTarget(self, action: #selector(updateError), for: .editingDidEnd)
    }
    
    @objc func updateError(textField: TKFormTextField) {
        textField.error = validationError(textField)
        
    }
    
    @objc func clearErrorIfNeeded(textField: TKFormTextField) {
        if validationError(textField) == nil {
            textField.error = nil
        }
    }
    
    private func validationError(_ textField: TKFormTextField) -> String? {
        if textField == emailText {
            return TKDataValidator.email(text: textField.text)
        }
        if textField == passwordText {
            return TKDataValidator.password(text: textField.text)
        }
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        GIDSignIn.sharedInstance().delegate = self
        //        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    @IBAction func showORHideAction(_ sender: UIButton) {
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
        
        guard activeField != nil else {
            return
        }
        
        activeField?.resignFirstResponder()
        activeField = nil
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        GIDSignIn.sharedInstance()?.signOut()
        NotificationCenter.default.removeObserver(self)
        
    }
    
    @objc func backAction(_sender:UIButton)  {
        self.view .endEditing(true)

        if comingFromTypes == true {
            self.navigationController?.popViewController(animated: true)
        } else {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
            self.navigationController?.pushViewController(vc!, animated: false)
        }
        
    }
    
    @IBAction func googleSignIN(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.shouldFetchBasicProfile = true
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func loginAction(_ sender:UIButton) {
        /*emailText.text = "indiv02@i2-donate.com"
        passwordText.text = "Indiv!02test" */
//        emailText.text = "share2dinesh93@gmail.com"
//        passwordText.text = "Abcd@123"
        if(emailText.text == "") && (passwordText.text == "") {
            showAlert(message: "please enter username and password")
        }
        else {
            let postDict: Parameters = ["email":emailText.text ?? "" ,"password":passwordText.text ?? ""]
            let logINString = String(format: URLHelper.iDonateLogin)
            let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Loading"
            
            WebserviceClass.sharedAPI.performRequest(type: loginModel.self ,urlString: logINString, methodType: .post, parameters: postDict, success: { (response) in
                
                self.loginModelResponse = response
                self.loginArray  = self.loginModelResponse?.data
                self.loginType = "Login"
                self.loginResponsemethod()
                UserDefaults.standard.setValue(self.emailText.text!, forKey: "password")
                print("Result: \(String(describing: self.loginArray))") // response serialization result
                MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                
            }) { (response) in
                MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            }
    
        }
        
    }
    
    func loginResponsemethod() {
        
        if(self.loginModelResponse?.status == 1) {
            
            let newPerson = UserDetails(name: self.loginArray!.name!, email: self.loginArray!.email!, mobileNUmber: self.loginArray?.phone_number ?? "", gender: self.loginArray?.gender ?? "", profileUrl:self.loginArray?.photo ?? "", country: self.loginArray?.country ?? "",token: self.loginArray?.token ?? "",userID:self.loginArray?.user_id ?? "", type: self.loginArray?.type ?? "",businessName: self.loginArray?.business_name ?? "", terms: "Yes")
            
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: newPerson)

            UserDefaults.standard.set(encodedData, forKey: "people")
            UserDefaults.standard.set( self.loginArray!.name, forKey: "username")
            UserDefaults.standard.synchronize()
        
            if(loginType == "Social") {
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UpdateProfileVC") as? UpdateProfileVC
                vc?.loginType = "Social"
                self.navigationController?.pushViewController(vc!, animated: true)
            } else {
                
                if comingFromTypes == true {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    constantFile.changepasswordBack = true
                    UserDefaults.standard.set("Login", forKey: "loginType")
                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
                    vc?.selectedIndex = 0
                    self.navigationController?.pushViewController(vc!, animated: true)
                    
                   
                }
                
            }
            
        } else {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string:(self.loginModelResponse?.message ?? "")!, attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showAlert(message:String) {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
        let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
        let messageAttrString = NSMutableAttributedString(string:message, attributes: messageFont)
        alertController.setValue(messageAttrString, forKey: "attributedMessage")
        let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
        }
        alertController.addAction(contact)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func forgotPassword(_ sender:UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ForgotVC") as? ForgotVC
        //   vc!.changeOrForgot = "Forgot"
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    @IBAction func facebookLogin(_ sender:UIButton) {
        
        let fbLoginManager : LoginManager = LoginManager()
        
        if let token = AccessToken.current,
           !token.isExpired {
            // User is logged in, do work such as go to next view controller.
            fbLoginManager.logOut()
        }
        fbLoginManager.logIn(permissions: ["email","public_profile"], from: self) { (result, error) in
            print(result?.isCancelled as Any)
            
            if((result?.isCancelled)!) {
                self.view .endEditing(true)
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RegisterVC") as? RegisterVC
                self.navigationController?.pushViewController(vc!, animated: false)
            }
            
            if (error == nil){
                let fbloginresult : LoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email")) {
                        if((AccessToken.current) != nil){
                            
                            
                            
                            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completion: { (connection, result, error) -> Void in
                            //.start(completionHandler: { (connection, result, error) -> Void in
                                print(result!)
                                
                                if (error == nil){
                                    self.faceBookDict = result as! [String : AnyObject]
                                    print( self.faceBookDict["email"] as Any)
                                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UpdateProfileVC") as? UpdateProfileVC
                                    vc?.email = self.faceBookDict["email"] as! String
                                    vc?.userName =  self.faceBookDict["name"] as! String
                                    let facebookID = self.faceBookDict["id"]
                                    let facebookProfile: String = "http://graph.facebook.com/\(facebookID ?? "")/picture?type=small"
                                    
                                    self.userName = self.faceBookDict["name"] as! String
                                    self.email = self.faceBookDict["email"] as! String
                                    self.profileUrl = facebookProfile
                                    
                                    self.soacialLogin(socialType: "Facebook")
                                    //print(self.dict)
                                }
                            })
                        }
                    }
                }
                else {
                    
                }
            }
            else {
                print("cancel by user")
            }
        }
        
    }
    
    //MARK:- TWITTER LOGIN
    
    @IBAction func twitterLogin(_ sender: UIButton) {
        
        TwitterHandler.shared.loginWithTwitter(self,{ userinfo in
            self.view.isUserInteractionEnabled = true
            print(userinfo.userfName)
            self.userName = userinfo.userfName
            self.email = userinfo.email
            self.profileUrl = userinfo.userProfileUrl
            self.soacialLogin(socialType: "Twitter")
        }, {
            
        })
    
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {

        if let error = error {
            self.view .endEditing(true)
            print("\(error.localizedDescription)")
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RegisterVC") as? RegisterVC
            self.navigationController?.pushViewController(vc!, animated: false)
        } else {
            
            
            print(user.userID )
            print(user.profile.name )
            
            var pictures :URL?
            if (GIDSignIn .sharedInstance().currentUser.profile.hasImage) {
                let dimension = round(100 * UIScreen.main.scale);
                pictures = user.profile.imageURL(withDimension: UInt(dimension))
            }
            
            userName = user.profile.name
            email = user.profile.email
            profileUrl = pictures?.absoluteString ?? ""
            soacialLogin(socialType: "Gmail")
                    
        }
        
    }
    
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
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
   @objc func keyboardWillShow(notification: NSNotification) {
          let userInfo = notification.userInfo!
          var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
          keyboardFrame = self.view.convert(keyboardFrame, from: nil)
          
          var contentInset:UIEdgeInsets = self.scrollView.contentInset
          contentInset.bottom = keyboardFrame.size.height + 100
          scrollView.contentInset = contentInset
      }
      
      @objc func keyboardWillHide(notification: NSNotification) {
          let contentInset:UIEdgeInsets = UIEdgeInsets.zero
          scrollView.contentInset = contentInset
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
extension LoginVC:UITextFieldDelegate
{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        lastOffset = self.scrollView.contentOffset
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField  == emailText)
        {
            
        }
        else
        {
            
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField  == emailText)
        {
            let isValid = isValidEmail(testStr: emailText.text!)
            if(emailText.text?.count == 0)
            {
                
            }
            else if(isValid == false)
            {
                
            }
        }
        else
        {
            if(passwordText.text?.count == 0)
            {
                
                
            }
            else  if((passwordText.text?.count)! < 6)
            {
                
            }
        }
    }
}

//extension LoginVC: GIDSignInUIDelegate{
//    private func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
//
//    }
//
//    // Present a view that prompts the user to sign in with Google
//    private func signIn(signIn: GIDSignIn!,
//                presentViewController viewController: UIViewController!) {
//        self.present(viewController, animated: true, completion: nil)
//    }
//
//    // Dismiss the "Sign in with Google" view
//    private func signIn(signIn: GIDSignIn!,
//                dismissViewController viewController: UIViewController!) {
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    class func convertImageToBase64(image: UIImage) -> String {
//        let imageData = image.pngData()!
//        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
//    }
//}
@available(iOS 13.0, *)
extension LoginVC: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        debugPrint("authorizationController:didCompleteWithError",error.localizedDescription)
        
        var alert = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true)
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            debugPrint("Apple fullName",fullName?.givenName)
            debugPrint("Apple email",email)
            debugPrint("Apple userIdentifier",userIdentifier)
            let keychain = KeychainSwift()
            
            if userIdentifier != nil {
                keychain.set(email ?? "", forKey: "Apple_email")
                keychain.set(userIdentifier, forKey: "Apple_user")
                keychain.set(fullName?.givenName ?? "", forKey: "Apple_name")
            }
            
            
            self.doAppleLogin(email:email ?? "",name: fullName?.givenName)
           
            
           
        
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
           
            let username = passwordCredential.user
            let password = passwordCredential.password
            debugPrint("Apple username",username)
            let keychain = KeychainSwift()
            keychain.set("", forKey: "Apple_email")
            keychain.set(username, forKey: "Apple_user")
            keychain.set("", forKey: "Apple_name")
            self.doAppleLogin(email: "",name: "")
           
        default:
            break
        }
    }
    
    func doAppleLogin(email:String? = "",name:String? = "") {
        self.userName = name ?? ""
        self.email = email ?? ""
        self.profileUrl = ""
        
       
        self.soacialLogin(socialType: "Apple")

    }
}

@available(iOS 13.0, *)
extension LoginVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
   
}
