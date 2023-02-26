//
//  RegisterVC.swift
//  iDonate
//
//  Created by Im043 on 07/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import TKFormTextField
import MBProgressHUD
import Alamofire
import GoogleSignIn
import FBSDKLoginKit

class RegisterVC: BaseViewController,GIDSignInDelegate {
    @IBOutlet var maleBtn: UIButton!
    @IBOutlet var femaleBtn: UIButton!
    @IBOutlet var businessBtn: UIButton!
    @IBOutlet var individualBtn: UIButton!
    @IBOutlet var otherBtn: UIButton!
    @IBOutlet var countryBtn: UIButton!
    @IBOutlet var containerView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var agreeBtn: UIView!
    @IBOutlet var nameText: TKFormTextField!
    @IBOutlet var emailText: TKFormTextField!
    @IBOutlet var mobileText: TKFormTextField!
    @IBOutlet var passwordText1: TKFormTextField!
    @IBOutlet var countryText: TKFormTextField!
    @IBOutlet var businessName: TKFormTextField!
    @IBOutlet var showhidebtn: UIButton!

    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    @IBOutlet weak var nameTopConstraint: NSLayoutConstraint!
    
    var activeField: UITextField?
    var lastOffset: CGPoint?
    var keyboardHeight: CGFloat!
    var genterText:String?
    var RegisterArray :  RegisterModelArray?
    var RegisterModelResponse :  RegisterModel?
    var faceBookDict : [String:Any] = [:]
    var termcondition:Bool = false
    var userName:String = ""
    var email:String = ""
    var profileUrl:String = ""
    var loginType:String = ""
    var loginArray : loginModelArray?
    var loginModelResponse :  loginModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        }
        else{
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        self.containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        // Do any additional setup after loading the view.
        setUpTextfield()
        self.individualBtn.isSelected = true
        
        self.navigationController?.isNavigationBarHidden = true
        
    }
    @IBAction func showORHideAction(_ sender: UIButton) {
        if(sender.isSelected == true){
            sender.isSelected = false
            passwordText1.isSecureTextEntry = true
        }
        else{
            sender.isSelected = true
            passwordText1.isSecureTextEntry = false
        }
    }
    func setUpTextfield() {
        self.emailText.placeholder = "Email*"
        self.emailText.enablesReturnKeyAutomatically = true
        self.emailText.returnKeyType = .done
        self.emailText.delegate = self
        
        self.passwordText1.placeholder = "Password*"
        self.passwordText1.enablesReturnKeyAutomatically = true
        self.passwordText1.returnKeyType = .done
        self.passwordText1.delegate = self
        self.passwordText1.isSecureTextEntry = true
        
        self.nameText.placeholder = "Name*"
        self.nameText.enablesReturnKeyAutomatically = true
        self.nameText.returnKeyType = .done
        self.nameText.delegate = self
        
        self.mobileText.placeholder = "Mobile number"
        self.mobileText.enablesReturnKeyAutomatically = true
        self.mobileText.returnKeyType = .done
        self.mobileText.delegate = self
        
        self.businessName.placeholder = "Business Name*"
        self.businessName.enablesReturnKeyAutomatically = true
        self.businessName.returnKeyType = .done
        self.businessName.delegate = self
        
        // Validation logic
        self.addTargetForErrorUpdating(self.emailText)
        self.addTargetForErrorUpdating(self.passwordText1)
        self.addTargetForErrorUpdating(self.nameText)
        self.addTargetForErrorUpdating(self.mobileText)
        self.addTargetForErrorUpdating(self.businessName)
        
        // Customize labels
        self.businessName.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.businessName.font = UIFont.systemFont(ofSize: 18)
        self.businessName.selectedTitleColor = UIColor.darkGray
        self.businessName.titleColor = UIColor.darkGray
        self.businessName.placeholderColor = UIColor.darkGray
        self.emailText.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.emailText.font = UIFont.systemFont(ofSize: 18)
        self.emailText.selectedTitleColor = UIColor.darkGray
        self.emailText.titleColor = UIColor.darkGray
        self.emailText.placeholderColor = UIColor.darkGray;
        self.emailText.errorLabel.font = UIFont.systemFont(ofSize: 18)
        self.passwordText1.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.passwordText1.font = UIFont.systemFont(ofSize: 18)
        self.passwordText1.errorLabel.font = UIFont.systemFont(ofSize: 18)
        self.passwordText1.selectedTitleColor = UIColor.darkGray
        self.passwordText1.titleColor = UIColor.darkGray
        self.passwordText1.placeholderColor = UIColor.darkGray
        self.nameText.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.nameText.font = UIFont.systemFont(ofSize: 18)
        self.nameText.errorLabel.font = UIFont.systemFont(ofSize: 18)
        self.nameText.selectedTitleColor = UIColor.darkGray
        self.nameText.titleColor = UIColor.darkGray
        self.nameText.placeholderColor = UIColor.darkGray
        self.mobileText.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.mobileText.font = UIFont.systemFont(ofSize: 18)
        self.mobileText.errorLabel.font = UIFont.systemFont(ofSize: 18)
        self.mobileText.selectedTitleColor = UIColor.darkGray
        self.mobileText.titleColor = UIColor.darkGray
        self.mobileText.placeholderColor = UIColor.darkGray
        
        
        self.emailText.accessibilityIdentifier = "email-textfield"
        self.passwordText1.accessibilityIdentifier = "password-textfield"
        self.nameText.accessibilityIdentifier = "name-textfield"
        self.mobileText.accessibilityIdentifier = "mobile-textfield"
        self.businessName.accessibilityIdentifier = "business-textfield"
        
        
        self.emailText.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.emailText.selectedLineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.emailText.selectedLineHeight = 2
        self.passwordText1.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.passwordText1.selectedLineColor  = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.passwordText1.selectedLineHeight = 2
        self.mobileText.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.mobileText.selectedLineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.mobileText.selectedLineHeight = 2
        self.nameText.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.nameText.selectedLineColor  = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.nameText.selectedLineHeight = 2
        self.businessName.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.businessName.selectedLineColor  = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.businessName.selectedLineHeight = 2
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
        if textField == passwordText1 {
            return TKDataValidator.password(text: textField.text)
        }
        if textField == nameText
        {
            return TKDataValidator.name(text: textField.text)
        }
        if textField == mobileText{
            return TKDataValidator.mobileNumber(text: textField.text)
        }
        if textField == businessName{
            return TKDataValidator.businessName(text: textField.text)
        }
        return nil
    }
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        guard activeField != nil else {
            return
        }
        
        activeField?.resignFirstResponder()
        activeField = nil
    }
    
    @IBAction func maleOrFemaleAction(_ sender: UIButton) {
        if(sender.tag == 0)
        {
            femaleBtn.isSelected = false
            otherBtn.isSelected = false
            maleBtn.isSelected = true
            genterText = "M"
        }
        else if(sender.tag == 1)
        {
            
            femaleBtn.isSelected = true
            maleBtn.isSelected = false
            otherBtn.isSelected = false
            genterText = "F"
        }
        else
        {
            femaleBtn.isSelected = false
            maleBtn.isSelected = false
            otherBtn.isSelected = true
            genterText = "O"
        }
        
    }
    
    @IBAction func businessAction(_ sender: UIButton){
        businessBtn.isSelected = true
        individualBtn.isSelected = false
      //  nameTopConstraint.constant = 70
        self.businessName.isHidden = false
        self.nameText.isHidden = true
       
    }
    
    @IBAction func individualAction(_ sender: UIButton){
        businessBtn.isSelected = false
        individualBtn.isSelected = true
       // nameTopConstraint.constant = 0
        self.businessName.isHidden = true
        self.nameText.isHidden = false

    }
    
    
    
    @IBAction func registerAction(_ sender: UIButton){
        self.view .endEditing(true)
        
        if(termcondition == false) {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string:"Please select term and condition", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
        }
           
            else if(nameText.text == "") || (emailText.text == "") || (passwordText1.text == "") {
                let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
                let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
                let messageAttrString = NSMutableAttributedString(string:"Fill the all required field", attributes: messageFont)
                alertController.setValue(messageAttrString, forKey: "attributedMessage")
                let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                }
                alertController.addAction(contact)
                self.present(alertController, animated: true, completion: nil)
                
                
            }
       else if(businessBtn.isSelected == true ){
            
            if(nameText.text == "") || (emailText.text == "") || (passwordText1.text == "") || (businessName.text == "") {
                let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
                let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
                let messageAttrString = NSMutableAttributedString(string:"Fill the all required field", attributes: messageFont)
                alertController.setValue(messageAttrString, forKey: "attributedMessage")
                let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                }
                alertController.addAction(contact)
                self.present(alertController, animated: true, completion: nil)
            }
           else{
               
               let postDict: Parameters = ["name":nameText.text ?? "",
                                           "email":emailText.text ?? "" ,
                                           "password":passwordText1.text ?? "",
                                           "phone":mobileText.text ?? "",
                                           "country":UserDefaults.standard.value(forKey: "selectedcountry") ?? "US",
                                           "gender":genterText ?? "",
                                           "type": businessBtn.isSelected ? "business" : "individual",
                                           "business_name": businessName.text ?? "",
                                           "terms":"Yes"]
               
               let registerUrl = String(format: URLHelper.iDonateRegister)
               let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
               loadingNotification.mode = MBProgressHUDMode.indeterminate
               loadingNotification.label.text = "Loading"
               
               WebserviceClass.sharedAPI.performRequest(type:  RegisterModel.self, urlString: registerUrl, methodType: .post, parameters: postDict, success: { (response)
                   in
                   self.RegisterModelResponse = response
                   self.RegisterArray  = self.RegisterModelResponse?.registerArray
                   self.registerResponse()
                   print("Result: \(String(describing: self.RegisterModelResponse))")                     // response serialization result
                   MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                   
               }) { (response) in
                   MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
               }
           }
        }
            else {
                
                let postDict: Parameters = ["name":nameText.text ?? "",
                                            "email":emailText.text ?? "" ,
                                            "password":passwordText1.text ?? "",
                                            "phone":mobileText.text ?? "",
                                            "country":UserDefaults.standard.value(forKey: "selectedcountry") ?? "US",
                                            "gender":genterText ?? "",
                                            "type": businessBtn.isSelected ? "business" : "individual",
                                            "business_name": businessName.text ?? "",
                                            "terms":"Yes"]
                
                let registerUrl = String(format: URLHelper.iDonateRegister)
                let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
                loadingNotification.mode = MBProgressHUDMode.indeterminate
                loadingNotification.label.text = "Loading"
                
                WebserviceClass.sharedAPI.performRequest(type:  RegisterModel.self, urlString: registerUrl, methodType: .post, parameters: postDict, success: { (response)
                    in
                    self.RegisterModelResponse = response
                    self.RegisterArray  = self.RegisterModelResponse?.registerArray
                    self.registerResponse()
                    print("Result: \(String(describing: self.RegisterModelResponse))")                     // response serialization result
                    MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                    
                }) { (response) in
                    MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                }
            }
        
    }
    
    
    func registerResponse() {
        
        if(self.RegisterModelResponse?.status == 1) {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string:(self.RegisterModelResponse?.message)!, attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string:(self.RegisterModelResponse?.message)!, attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
//                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
//                self.navigationController?.pushViewController(vc!, animated: true)
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    @objc func backAction(_sender:UIButton)  {
        let alert = UIAlertController(title: "", message: "Returning To Login Without Making Changes?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.view .endEditing(true)
            self.navigationController?.popViewController(animated: true)
            
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        //  Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if((UserDefaults.standard.value(forKey: "selectedname")) != nil){
            let object = UserDefaults.standard.value(forKey: "selectedname") as! String
            countryBtn.setTitle(object, for: .normal)
        }
        
        GIDSignIn.sharedInstance().delegate = self

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
//    func isValidText(testStr:String) -> Bool {
//        // print("validate calendar: \(testStr)")
//        let emailRegEx = "[A-Za-z_-]"
//
//        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//        return emailTest.evaluate(with: testStr)
//    }
    
    @IBAction func googleSignIN(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.shouldFetchBasicProfile = true
        GIDSignIn.sharedInstance()?.signIn()
        
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
                                    
                                    self.socialLogin(socialType: "Facebook")
                                    //print(self.dict)
                                }
                            })
                        }
                    }
                }
            }
            else{
                print("cancel by user")
            }
        }
        
    }
    
    @IBAction func twitterLogin(_ sender: UIButton) {
        
        TwitterHandler.shared.loginWithTwitter(self,{ userinfo in
            self.view.isUserInteractionEnabled = true
            print(userinfo.email)
            
            self.userName = userinfo.userfName
            self.email = userinfo.email
            self.socialLogin(socialType: "Twitter")
            
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
            socialLogin(socialType: "Gmail")
                        
        }
        
    }
    
    func socialLogin(socialType:String) {
        let postDict: Parameters = ["name": userName,"email":email ,"login_type":socialType,"photo":profileUrl]
        let socialLoginUrl = String(format: URLHelper.iDonateSocialLogin)
        let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        
        WebserviceClass.sharedAPI.performRequest(type: loginModel.self, urlString: socialLoginUrl, methodType: HTTPMethod.post, parameters: postDict,success: { (response) in
            self.loginModelResponse = response
            self.loginArray  = response.data
            self.loginType = "Social"
            UserDefaults.standard.set("Social", forKey: "loginType")
            self.loginResponsemethod()
            print("Result: \(String(describing: response))") // response serialization result
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }) { (response) in
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }
        
    }
    
    func loginResponsemethod() {
        
        if(self.loginModelResponse?.status == 1) {
            
            let newPerson = UserDetails(name: self.loginArray!.name!, email: self.loginArray!.email!, mobileNUmber: self.loginArray?.phone_number ?? "", gender: self.loginArray?.gender ?? "", profileUrl:self.loginArray?.photo ?? "", country: self.loginArray?.country ?? "US",token: self.loginArray?.token ?? "",userID:self.loginArray?.user_id ?? "", type: self.loginArray?.type ?? "", businessName: self.loginArray?.business_name ?? "", terms: self.loginArray?.terms ?? "No")
            
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: newPerson)
            UserDefaults.standard.set(encodedData, forKey: "people")
            UserDefaults.standard.set( self.loginArray!.name, forKey: "username")
            
            if(loginType == "Social"){
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UpdateProfileVC") as? UpdateProfileVC
                vc?.userName = self.userName
                vc?.email = self.email
                vc?.loginType = self.loginType
                self.navigationController?.pushViewController(vc!, animated: true)
            }else {
                UserDefaults.standard.set("Login", forKey: "loginType")
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            
        }else {
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
    
    @IBAction func showTermsAndCondition(_ sender:UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TermsAndConditionsViewController") as? TermsAndConditionsViewController
        vc?.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func agreeaction(_ sender: UIButton){
        if(sender.isSelected == true){
            sender.isSelected = false
            termcondition = false
        } else {
            sender.isSelected = true
            termcondition = true
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

extension RegisterVC:UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        lastOffset = self.scrollView.contentOffset
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == nameText){
            
        } else if(textField == emailText){
            
        } else if(textField == mobileText){
            
        } else if(textField == passwordText1){
            
        }
        else if(textField == businessName){
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField == nameText) {
            if(nameText.text?.count == 0) {

            }
//            else{
//                let isValid = isValidText(testStr: nameText.text!)
//                if(isValid == false) {
//                    
//                }
//            }
        }
       
        else if(textField == emailText)
        {
            if(emailText.text?.count == 0)
            {
                
            }else{
                let isValid = isValidEmail(testStr: emailText.text!)
                if(isValid == false) {
                    
                }
            }
        }
        else if(textField == mobileText)
        {
            if(mobileText.text?.count == 0)
            {
                
            }
            else if((mobileText.text?.count)! < 10)
                
            {
                
            }
        }
        else if(textField == passwordText1)
        {
            if(passwordText1.text?.count == 0)
            {
                
            }
            else if((passwordText1.text?.count)! < 6)
                
            {
                
            }
        }
        else if(textField == businessName)
        {
            if(businessName.text?.count == 0)
            {
                
            }
            else if((businessName.text?.count)! < 6)
                
            {
                
            }
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //       // activeField?.resignFirstResponder()
        //        activeField = nil
        if(textField == mobileText) {
            
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92) {
                    print("Backspace was pressed")
                    return true
                }
            }
            
            if((mobileText.text?.count)! < 10) {
                return true
            } else{
                return false
            }
            
        } else{
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
}

//extension RegisterVC:GIDSignInUIDelegate {
//
//    private func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
//
//    }
//
//    // Present a view that prompts the user to sign in with Google
//    private func signIn(signIn: GIDSignIn!,
//                        presentViewController viewController: UIViewController!) {
//        self.present(viewController, animated: true, completion: nil)
//    }
//
//    // Dismiss the "Sign in with Google" view
//    private func signIn(signIn: GIDSignIn!,
//                        dismissViewController viewController: UIViewController!) {
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    class func convertImageToBase64(image: UIImage) -> String {
//        let imageData = image.pngData()!
//        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
//    }
//}
