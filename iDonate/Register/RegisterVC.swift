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
import UniformTypeIdentifiers
import AuthenticationServices
import KeychainSwift

extension RegisterVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.height
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessRegCell", for: indexPath) as! BusinessRegCell
        return cell
    }
}
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
    @IBOutlet var passwordHint: UILabel!
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var countryLabel: UILabel!
    @IBOutlet var countrydropdown: UIView!
    @IBOutlet var countryLine: UILabel!
    @IBOutlet var appleLoginBtn:UIButton!
    
    @IBOutlet var businessView: UIView!
    @IBOutlet var firstName: TKFormTextField!
    @IBOutlet var lastName: TKFormTextField!
    @IBOutlet var businessAddress: TKFormTextField!
    @IBOutlet var businessemail:TKFormTextField!
    @IBOutlet var street: TKFormTextField!
    @IBOutlet var optionalStreet: TKFormTextField!
    @IBOutlet var state: TKFormTextField!
    @IBOutlet var city: TKFormTextField!
    @IBOutlet var zipCode: TKFormTextField!
    @IBOutlet var taxField: TKFormTextField!
    @IBOutlet var businessPhone: TKFormTextField!
    @IBOutlet var businessPassword: TKFormTextField!
    @IBOutlet var businessVisibilityBtn: TKFormTextField!
    @IBOutlet var street1: TKFormTextField!


    
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    @IBOutlet weak var nameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fileOptionsHeight: NSLayoutConstraint!
    @IBOutlet weak var fileViews: UIView!
    @IBOutlet var inCorporationDocName: UIButton!
    @IBOutlet var taxIDName: UIButton!
    @IBOutlet var businessCertifi: UIButton!
    @IBOutlet var otherDocName: UIButton!
    @IBOutlet var tableview: UITableView!
    
    @IBOutlet weak var agreeBtnYPos: NSLayoutConstraint!
    
    @IBOutlet weak var connectWithLabel: UILabel!
    @IBOutlet weak var socialLoginView: UIView!
    @IBOutlet weak var lineOne: UIView!
    @IBOutlet weak var lineTwo: UIView!
     
    
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
    var selectedFiles = [Int:Any]()
    var selectedFilesTypes = [String:String]()
    var selectedFileTag = 0
    var fileMetaData = [Int:String]()
    var isSKipUpdateProfile = false
    
    @IBAction func showCityAction(sender:UIButton){
        debugPrint("showCityAction")
    }
    @IBAction func showStateAction(sender:UIButton){
        debugPrint("showStateAction")
    }
    @IBAction func showBUVisibilityAction(sender:UIButton){
        debugPrint("showBUVisibilityAction")
        if sender.isSelected {
            self.businessPassword.isSecureTextEntry = false
            sender.isSelected = false
            
        }else{
            self.businessPassword.isSecureTextEntry = true
            sender.isSelected = true
        }
      
    }
    
    override func viewDidLayoutSubviews() {
//        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 2500)
    }
    override func viewDidLoad() {
        self.businessPhone.enablesReturnKeyAutomatically = true
        self.businessPhone.keyboardType = .phonePad
        self.zipCode.keyboardType = .numberPad
        self.businessAddress.lineView.isHidden = true
        self.businessPassword.isSecureTextEntry = true
        self.businessPassword.enablePasswordToggle()
        self.showhidebtn.isHidden = true
//        self.showhidebtn.setImage(UIImage(named: "passwordhide"), for: .selected)
//        self.showhidebtn.setImage(UIImage(named: "passwordshow"), for: .normal)
       // self.businessPassword.isSecureTextEntry = true
       // self.businessPassword.isSelected = true
        super.viewDidLoad()
        self.registerBusinessView()
        self.showBusinessView(show: false)
        self.scrollView.delaysContentTouches = false

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
        self.appleLoginBtn.layer.cornerRadius = appleLoginBtn.frame.size.width/2
        self.appleLoginBtn.clipsToBounds = true
        self.appleLoginBtn.backgroundColor = .black

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
                             self.isSKipUpdateProfile = true
                             self.socialLogin(socialType: "Apple")
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
    func registerBusinessView(){
        self.tableview.register(UINib(nibName: "BusinessRegCell", bundle: nil), forCellReuseIdentifier: "BusinessRegCell")
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
        self.addTargetForErrorUpdating(self.businessPhone)
        self.addTargetForErrorUpdating(self.businessPassword)
        self.addTargetForErrorUpdating(self.street1)
        self.addTargetForErrorUpdating(self.state)
        self.addTargetForErrorUpdating(self.city)
        self.addTargetForErrorUpdating(self.zipCode)
        self.addTargetForErrorUpdating(self.taxField)
        self.addTargetForErrorUpdating(self.firstName)
        self.addTargetForErrorUpdating(self.lastName)
        
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
        if textField == mobileText {
            return TKDataValidator.mobileNumber(text: textField.text)
        }
        if textField == businessName{
            return TKDataValidator.businessName(text: textField.text)
        }
        if textField == self.businessPhone {
            return TKDataValidator.mobileNumber(text: textField.text)
        }
        if textField == self.businessPassword {
            return TKDataValidator.password(text: textField.text)
        }
        if textField == self.street1 {
            return TKDataValidator.isValidText(textfield: textField)
        }
        if textField == self.city {
            return TKDataValidator.isValidText(textfield: textField)
        }
        if textField == self.state {
            return TKDataValidator.isValidText(textfield: textField)
        }
        if textField == self.zipCode {
            return TKDataValidator.isValidText(textfield: textField)
        }
        if textField == self.firstName {
            return TKDataValidator.isValidText(textfield: textField)
        }
        if textField == self.lastName {
            return TKDataValidator.isValidText(textfield: textField)
        }
        if textField == self.taxField {
            return TKDataValidator.isValidTaxIDText(textfield: textField)
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
        self.showBusinessView(show: true)
      //  nameTopConstraint.constant = 70
        
       
    }
    
    func showBusinessView(show:Bool){
       
        self.businessView.isHidden = show ? false : true
        self.businessName.isHidden = show ? false : true
        
        // individual
        self.lineOne.isHidden = show ? true : false
        self.lineTwo.isHidden = show ? true : false
        self.connectWithLabel.isHidden = show ? true : false
        self.socialLoginView.isHidden = show ? true : false
        self.nameText.isHidden = show ? true : false
        self.emailText.isHidden = show ? true : false
        self.mobileText.isHidden = show ? true : false
        self.passwordText1.isHidden = show ? true : false
        self.showhidebtn.isHidden = show ? true : false
        self.passwordHint.isHidden = show ? true : false
        self.maleBtn.isHidden = show ? true : false
        self.femaleBtn.isHidden = show ? true : false
        self.otherBtn.isHidden = show ? true : false
        self.countryBtn.isHidden = show ? true : false
       // self.countryText.isHidden = show ? true : false
        self.genderLabel.isHidden = show ? true : false
        self.countryLabel.isHidden = show ? true : false
        self.countryLine.isHidden = show ? true : false
        self.countrydropdown.isHidden = show ? true : false
        self.agreeBtnYPos.constant = show ? 880 : 16
        
//        self.scrollView.isHidden = show ? true:false
//        self.tableview.isHidden = show ? false : true
//        self.fileOptionsHeight.constant = show ? 370 : 0
//        self.fileViews.isHidden = show ? false : true
//        self.businessName.isHidden = false
//        self.nameText.isHidden = false
    
    }
    
    @IBAction func individualAction(_ sender: UIButton){
        businessBtn.isSelected = false
        individualBtn.isSelected = true
       // nameTopConstraint.constant = 0
        self.fileOptionsHeight.constant = 0
        self.fileViews.isHidden = true
        self.businessName.isHidden = true
        self.nameText.isHidden = false
        
        self.showBusinessView(show: false)

    }
    
    func updateFileSelection(){
        if self.fileMetaData[0] != nil {
            self.inCorporationDocName.setTitle(self.fileMetaData[0], for: .normal)
            self.inCorporationDocName.setTitleColor(.blue, for: .normal)
        }else{
            self.inCorporationDocName.setTitle("No file choosen", for: .normal)
            self.inCorporationDocName.setTitleColor(.black, for: .normal)
        }
        if self.fileMetaData[1] != nil {
            self.taxIDName.setTitle(self.fileMetaData[1], for: .normal)
            self.taxIDName.setTitleColor(.blue, for: .normal)
        }else{
            self.taxIDName.setTitle("No file choosen", for: .normal)
            self.taxIDName.setTitleColor(.black, for: .normal)
        }
        if self.fileMetaData[2] != nil {
            self.businessCertifi.setTitle(self.fileMetaData[2], for: .normal)
            self.businessCertifi.setTitleColor(.blue, for: .normal)
        }else{
            self.businessCertifi.setTitle("No file choosen", for: .normal)
            self.businessCertifi.setTitleColor(.black, for: .normal)
        }
        if self.fileMetaData[3] != nil {
            self.otherDocName.setTitle(self.fileMetaData[3], for: .normal)
            self.otherDocName.setTitleColor(.blue, for: .normal)
        }else{
            self.otherDocName.setTitle("No file choosen", for: .normal)
            self.otherDocName.setTitleColor(.black, for: .normal)
        }
    }
    @IBAction func onFileUploadAction(sender:UIButton){
        debugPrint("onFileUploadAction",sender.tag)
        self.selectedFileTag = sender.tag
        self.openFilePicker(tag: sender.tag)
    }
    
    func openFilePicker(tag:Int){
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item", "public.content","public.text", "public.data","public.composite-content","public.png","public.jpeg"], in: .import)

        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    func isAllFilesUpdated() -> Bool {
       // debugPrint("selectedFiles",self.selectedFiles)
        let keys = self.selectedFiles.keys
        //debugPrint("selectedFiles.keys",keys)
        if keys.contains(0) && keys.contains(1) && keys.contains(2) {
            return true
        }
        return false
        
//        return true
    }
    func getKeyName(tag:Int) -> String {
        switch tag{
        case 0:
            return "incorp_doc"
        case 1:
            return "tax_id_doc"
        case 2:
            return "good_standing_doc"
        case 3:
            return "oth_doc"
        default:
            return ""
        }
    }
    
    func isAllFieldsValid() -> Bool {
        //|| self.optionalStreet.text!.isBlankOrEmpty()
        if self.businessBtn.isSelected {
            if self.businessName.text!.isBlankOrEmpty() || self.firstName.text!.isBlankOrEmpty()
                || self.lastName.text!.isBlankOrEmpty() || self.businessemail.text!.isBlankOrEmpty()
                || self.businessPhone.text!.isBlankOrEmpty()
                || self.businessPassword.text!.isBlankOrEmpty()
                || self.street1.text!.isBlankOrEmpty()
                
                || self.state.text!.isBlankOrEmpty()
                || self.city.text!.isBlankOrEmpty()
                || self.zipCode.text!.isBlankOrEmpty() || self.taxField.text!.isBlankOrEmpty()
                || self.isAllFilesUpdated() == false {
                return false
            }
                
        }
        else {
            
            if ((nameText.text == "") || (emailText.text == "") || (passwordText1.text == "" || (TKDataValidator.password(text: passwordText1.text) != nil))) {
                return false
            }
            
        }
        
        return true
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
            return
        }
        
        if !self.isAllFieldsValid() {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string:"Fill the all required field", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if self.businessBtn.isSelected {
            let pswdValid = TKDataValidator.password(text: self.businessPassword.text)
            if pswdValid != nil {
                let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
                let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
                let messageAttrString = NSMutableAttributedString(string:pswdValid!, attributes: messageFont)
                alertController.setValue(messageAttrString, forKey: "attributedMessage")
                let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                }
                alertController.addAction(contact)
                self.present(alertController, animated: true, completion: nil)
                return
            }
        }
        
        var postDict: Parameters = ["name":nameText.text ?? "",
                                                   "email":emailText.text ?? "" ,
                                                   "password":passwordText1.text ?? "",
                                                   "phone":mobileText.text ?? "",
                                                   "country":UserDefaults.standard.value(forKey: "selectedcountry") ?? "US",
                                                   "gender":genterText ?? "",
                                                   "type": businessBtn.isSelected ? "business" : "individual",
                                                   "business_name": businessName.text ?? "",
                                                   "terms":"Yes"]
        
        if self.businessBtn.isSelected {
            postDict["ein"] = self.taxField.text!
            postDict["email"] = self.businessemail.text!
            postDict["type"] = "business"
            postDict["business_name"] = self.businessName.text!
            postDict["name"] = self.firstName.text! + " " + self.lastName.text!
            postDict["phone"] = self.businessPhone.text!
            postDict["address1"] = self.street1.text!
            postDict["address2"] = self.optionalStreet.text!
            postDict["city"] = self.city.text!
            postDict["state"] = self.state.text!
            postDict["zip"] = self.zipCode.text!
            postDict["country"] = "US"
            postDict["terms"] = "Yes"
            postDict["password"] = self.businessPassword.text!
            
            for (key,val) in self.selectedFiles {
                let keyName = self.getKeyName(tag:key)
                postDict[keyName] = val
                
            }
            for (key,val) in self.selectedFilesTypes {
                postDict[key] = val
                
            }
        }
        
        debugPrint("PostDict",postDict)
        
        // ["terms": "Yes", "country": US, "password": "Abcd@123", "name": "Sample user", "gender": "M", "type": "individual", "business_name": "", "phone": "7200798409", "email": "share2dinesh93+10@gmail.com"]
        
        let registerUrl = String(format: URLHelper.iDonateRegister)
        let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        
        WebserviceClass.sharedAPI.performRequest(isFileAdded:businessBtn.isSelected ? true : false,type:  RegisterModel.self, urlString: registerUrl, methodType: .post, parameters: postDict, success: { (response)
            in
            self.RegisterModelResponse = response
            self.RegisterArray  = self.RegisterModelResponse?.registerArray
            self.registerResponse()
            print("Result: \(String(describing: self.RegisterModelResponse))")                     // response serialization result
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            
        }) { (response) in
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }
        
        
        
        
   /*     if(termcondition == false) {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string:"Please select term and condition", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
        }
           
        else if (businessBtn.isSelected == false && (nameText.text == "") || (emailText.text == "") || (passwordText1.text == "" || (TKDataValidator.password(text: passwordText1.text) != nil)))  {
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
           
           
           if (businessName.text!.isBlankOrEmpty()) || (emailText.text!.isBlankOrEmpty()) || (passwordText1.text!.isBlankOrEmpty()) || (businessName.text!.isBlankOrEmpty()) || self.isAllFilesUpdated() == false {
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
               
            /*   var postDict: Parameters = ["name":nameText.text ?? "",
                                           "email":emailText.text ?? "" ,
                                           "password":passwordText1.text ?? "",
                                           "phone":mobileText.text ?? "",
                                           "country":UserDefaults.standard.value(forKey: "selectedcountry") ?? "US",
                                           "gender":genterText ?? "",
                                           "type": businessBtn.isSelected ? "business" : "individual",
                                           "business_name": businessName.text ?? "",
                                           "terms":"Yes",
                                           "city":"",
                                           "zip":"",
                                           "state":"",
                                           "address1":"",
                                           "address2":""]
               
               for (key,val) in self.selectedFiles {
                   let keyName = self.getKeyName(tag:key)
                   postDict[keyName] = val
               } */
               
               var postDict: Parameters = ["name":nameText.text ?? "",
                                                          "email":emailText.text ?? "" ,
                                                          "password":passwordText1.text ?? "",
                                                          "phone":mobileText.text ?? "",
                                                          "country":UserDefaults.standard.value(forKey: "selectedcountry") ?? "US",
                                                          "gender":genterText ?? "",
                                                          "type": businessBtn.isSelected ? "business" : "individual",
                                                          "business_name": businessName.text ?? "",
                                                          "terms":"Yes"]
               if self.businessBtn.isSelected {
                   
                 /*  ein
                   email
                   type
                   business_name
                   name
                   phone
                   address1
                   address2
                   city
                   state
                   zip
                   country
                   terms
                   incorp_doc
                   incorp_doc_type
                   tax_id_doc
                   tax_id_doc_type
                   good_standing_doc
                   good_standing_doc_type
                   oth_doc
                   oth_doc_type
                   password */

                   postDict["ein"] = self.taxField.text!
                   postDict["email"] = self.businessemail.text!
                   postDict["type"] = "business"
                   postDict["business_name"] = self.businessName.text!
                   postDict["name"] = self.firstName.text! + " " + self.lastName.text!
                   postDict["phone"] = self.businessPhone.text!
                   postDict["address1"] = self.street.text!
                   postDict["address2"] = self.optionalStreet.text!
                   postDict["city"] = self.city.text!
                   postDict["state"] = self.state.text!
                   postDict["zip"] = self.zipCode.text!
                   postDict["country"] = "US"
                   postDict["terms"] = "Yes"
                   postDict["password"] = self.businessPassword.text!
                   
                   for (key,val) in self.selectedFiles {
                       let keyName = self.getKeyName(tag:key)
                       postDict[keyName] = val
                       
                   }
                   for (key,val) in self.selectedFilesTypes {
                       postDict[key] = val
                       
                   }
                   
                  /* postDict["incorp_doc"] = ""
                   postDict["incorp_doc_type"] = ""
                   postDict["tax_id_doc"] = ""
                   postDict["tax_id_doc_type"] = ""
                   postDict["good_standing_doc"] = ""
                   postDict["good_standing_doc_type"] = ""
                   postDict["oth_doc"] = ""
                   postDict["oth_doc_type"] = "" */
               }
               
               debugPrint("postDict",postDict)
               
               if true {
                   
               }
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
                
                WebserviceClass.sharedAPI.performRequest(isFileAdded:businessBtn.isSelected ? true : false,type:  RegisterModel.self, urlString: registerUrl, methodType: .post, parameters: postDict, success: { (response)
                    in
                    self.RegisterModelResponse = response
                    self.RegisterArray  = self.RegisterModelResponse?.registerArray
                    self.registerResponse()
                    print("Result: \(String(describing: self.RegisterModelResponse))")                     // response serialization result
                    MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                    
                }) { (response) in
                    MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                }
            } */
        
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
                                    vc?.userEmail = self.faceBookDict["email"] as! String
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
        let postDict: Parameters = ["name": userName,"email":email ,"login_type":socialType,"photo":profileUrl,"type":self.businessBtn.isSelected ? "business" : "individual"]
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
            
            let newPerson = UserDetails(name: self.loginArray!.name!, email: self.loginArray!.email!, mobileNumber: self.loginArray?.phone_number ?? "", gender: self.loginArray?.gender ?? "", profileUrl:self.loginArray?.photo ?? "", country: self.loginArray?.country ?? "US",token: self.loginArray?.token ?? "",userID:self.loginArray?.user_id ?? "", type: self.loginArray?.type ?? "", businessName: self.loginArray?.business_name ?? "", terms: self.loginArray?.terms ?? "No")
            
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: newPerson)
            UserDefaults.standard.set(encodedData, forKey: "people")
            UserDefaults.standard.set( self.loginArray!.name, forKey: "username")
            
            if(loginType == "Social") &&  (self.isSKipUpdateProfile == false){
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UpdateProfileVC") as? UpdateProfileVC
                vc?.userName = self.userName
                vc?.userEmail = self.email
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
            
            debugPrint("mobile validation")
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
        
        
    
        if(textField == self.businessPhone) {
            
            
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92) {
                    print("Backspace was pressed")
                    return true
                }
            }
            if((businessPhone.text?.count)! < 10) {
                return true
            } else{
                return false
            }
            
            
            
            
            
        }
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

extension RegisterVC:UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        debugPrint("docs.url",urls)
        let firstDoc = urls.first
        debugPrint("docs.url",firstDoc?.lastPathComponent)
        do {
            self.fileMetaData[self.selectedFileTag] = firstDoc?.lastPathComponent
            let contenType = firstDoc?.pathExtension
            self.selectedFiles[self.selectedFileTag] = try Data(contentsOf: firstDoc!).base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
            self.selectedFilesTypes[self.getKeyName(tag: self.selectedFileTag)] = contenType
           
        }
        catch {
            debugPrint("file.picker.error",error.localizedDescription)
        }
        self.updateFileSelection()
        debugPrint("selected files",self.selectedFiles.keys)
        
    }
    
}


extension String {
    func isBlankOrEmpty() -> Bool {

      // Check empty string
      if self.isEmpty {
          return true
      }
      // Trim and check empty string
      return (self.trimmingCharacters(in: .whitespaces) == "")
   }
}
@available(iOS 13.0, *)
extension RegisterVC: ASAuthorizationControllerDelegate {
    
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
        self.isSKipUpdateProfile = true
        self.userName = name ?? ""
        self.email = email ?? ""
        self.profileUrl = ""
        
        self.socialLogin(socialType: "Apple")

    }
}

@available(iOS 13.0, *)
extension RegisterVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
   
}
