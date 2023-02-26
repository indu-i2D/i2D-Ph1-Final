//
//  UpdateProfileVC.swift
//  iDonate
//
//  Created by Im043 on 27/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import TKFormTextField
import Alamofire
import AlamofireImage
import MBProgressHUD
class UpdateProfileVC: BaseViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate,UITextFieldDelegate {
    @IBOutlet var containerView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet var maleBtn: UIButton!
    @IBOutlet var femaleBtn: UIButton!
    @IBOutlet var otherBtn: UIButton!
    @IBOutlet var countryBtn: UIButton!
    @IBOutlet var updateBtn: UIButton!
    @IBOutlet var skipBtn: UIButton!
    @IBOutlet var businessBtn: UIButton!
    @IBOutlet var individualBtn: UIButton!
    @IBOutlet var nameText: TKFormTextField!
    @IBOutlet var emailText: TKFormTextField!
    @IBOutlet var mobileText: TKFormTextField!
    @IBOutlet var businessName: TKFormTextField!
    @IBOutlet weak var nameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var businessBtnLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var termsView: UIView!

    @IBOutlet var registerAsLabel: UILabel!

    let picker = UIImagePickerController()
    var updateArray :  loginModelArray?
    var UpdateModelResponse :  UpdateModel?
    var activeField: UITextField?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    var yAxix: CGFloat = 10
    var height : CGFloat = 10
    var genterText:String = ""
    var updateType:String = ""
    var userName:String = ""
    var email:String = ""
    var loginType:String = ""

    var registeredType = String()
        
    var comingFromTypes = false
    var termcondition:Bool = false

    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UpdateProfileVC.tapAction(_:)))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(mytapGestureRecognizer)
        mytapGestureRecognizer.numberOfTapsRequired = 1
        self.profileImage.layer.cornerRadius = 60
        self.profileImage.clipsToBounds = true
        
        if(iDonateClass.hasSafeArea) {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        }
        else{
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        self.containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(UpdateProfileVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UpdateProfileVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        setUpTextfield()
        
        if(updateType == "update"){
            self.skipBtn.isHidden = true
            registerAsLabel.text = "Registered as"
            self.businessBtn.isUserInteractionEnabled = false
            self.individualBtn.isUserInteractionEnabled = false
            comingFromTypes = true
        }
        
        updateProfileDetails()

        self.updateBtn.isHidden = false
        
        // Do any additional setup after loading the view.
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
        
//        if textField == mobileText {
//            return TKDataValidator.mobileNumber(text: textField.text)
//        }
        
        return nil
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if((UserDefaults.standard.value(forKey: "selectedname")) != nil){
            let object = UserDefaults.standard.value(forKey: "selectedname") as! String
            countryBtn.setTitle(object, for: .normal)
        }
    }
    
    @objc func tapAction(_ sender:AnyObject) {

        print("you tap image number : \(sender.view.tag)")
        
        let alert:UIAlertController=UIAlertController(title: "Take A Photo To Upload", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.openCamera()
        }
        
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.openGallary()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel){
            UIAlertAction in
        }
        
        // Add the actions
        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = profileImage
            presenter.sourceRect = profileImage.bounds
        }
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func openCamera(){
        picker.allowsEditing = true
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    
    func openGallary(){
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.view .endEditing(true)
    }
    
    func setUpTextfield() {
        self.emailText.placeholder = "Email"
        self.emailText.enablesReturnKeyAutomatically = true
        self.emailText.returnKeyType = .next
        self.emailText.delegate = self
        
        self.nameText.placeholder = "Name"
        self.nameText.enablesReturnKeyAutomatically = true
        self.nameText.returnKeyType = .done
        self.nameText.delegate = self
        self.nameText.isSecureTextEntry = false
        
        self.businessName.placeholder = "Business Name"
        self.businessName.enablesReturnKeyAutomatically = true
        self.businessName.returnKeyType = .done
        self.businessName.delegate = self
        self.businessName.isSecureTextEntry = false
        
        self.mobileText.placeholder = "Mobile number"
        self.mobileText.enablesReturnKeyAutomatically = true
        self.mobileText.returnKeyType = .next
        self.mobileText.delegate = self
        
        self.emailText.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.emailText.font = UIFont.systemFont(ofSize: 18)
        self.emailText.selectedTitleColor = UIColor.darkGray
        self.emailText.titleColor = UIColor.darkGray
        self.emailText.placeholderColor = UIColor.darkGray;
        self.emailText.errorLabel.font = UIFont.systemFont(ofSize: 18)
        
        self.businessName.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.businessName.font = UIFont.systemFont(ofSize: 18)
        self.businessName.selectedTitleColor = UIColor.darkGray
        self.businessName.titleColor = UIColor.darkGray
        self.businessName.placeholderColor = UIColor.darkGray;
        self.businessName.errorLabel.font = UIFont.systemFont(ofSize: 18)
        
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
        self.nameText.accessibilityIdentifier = "name-textfield"
        self.mobileText.accessibilityIdentifier = "mobile-textfield"
        self.businessName.accessibilityIdentifier = "business-textfield"
        
        self.emailText.lineColor = UIColor(red:0.96, green:0.87, blue:0.94, alpha:1.0)
        self.emailText.selectedLineColor = UIColor(red:0.82, green:0.59, blue:0.77, alpha:1.0)
        self.businessName.lineColor = UIColor(red:0.96, green:0.87, blue:0.94, alpha:1.0)
        self.businessName.selectedLineColor = UIColor(red:0.82, green:0.59, blue:0.77, alpha:1.0)
        self.mobileText.lineColor = UIColor(red:0.96, green:0.87, blue:0.94, alpha:1.0)
        self.mobileText.selectedLineColor = UIColor(red:0.82, green:0.59, blue:0.77, alpha:1.0)
        self.nameText.lineColor = UIColor(red:0.96, green:0.87, blue:0.94, alpha:1.0)
        self.nameText.selectedLineColor  = UIColor(red:0.82, green:0.59, blue:0.77, alpha:1.0)
       // self.addTargetForErrorUpdating(self.mobileText)
    }
    
    
    @IBAction func businessAction(_ sender: UIButton){
        businessBtn.isSelected = true
        individualBtn.isSelected = false
        nameTopConstraint.constant = 80
        self.businessName.isHidden = false
    }
    
    @IBAction func indiualAction(_ sender: UIButton) {
        businessBtn.isSelected = false
        individualBtn.isSelected = true
        nameTopConstraint.constant = 30
        self.businessName.isHidden = true
    }
        
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        guard activeField != nil else {
            return
        }
        
        activeField?.resignFirstResponder()
        activeField = nil
    }
    
    @IBAction func maleOrFemaleAction(_ sender: UIButton) {
        if(sender.tag == 0){
            femaleBtn.isSelected = false
            otherBtn.isSelected = false
            maleBtn.isSelected = true
            genterText = "M"
        }
        else if(sender.tag == 1) {
            femaleBtn.isSelected = true
            maleBtn.isSelected = false
            otherBtn.isSelected = false
            genterText = "F"
        }
        else {
            femaleBtn.isSelected = false
            maleBtn.isSelected = false
            otherBtn.isSelected = true
            genterText = "O"
        }
        
    }
    
    func updateProfileDetails() {
        
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            print(myPeopleList.type)
            print(myPeopleList.businessName)
            if myPeopleList.type == "individual"{
            self.nameText.text = myPeopleList.name
                        
            self.emailText.text = myPeopleList.email
            self.mobileText.text = myPeopleList.mobileNUmber
            }
            if myPeopleList.type == "business"{
                self.nameText.text = myPeopleList.name
                self.businessName.text = myPeopleList.businessName
                self.emailText.text = myPeopleList.email
                self.mobileText.text = myPeopleList.mobileNUmber
            }
            if myPeopleList.type == "" || myPeopleList.type == "individual"{
                self.registeredType = "individual"
                self.individualBtn.isSelected = true
                self.businessBtn.isSelected = false
            }
            if myPeopleList.type == "" || myPeopleList.type == "business" {
                self.registeredType = "Business"
                nameTopConstraint.constant = 80
                self.businessName.isHidden = false
                self.businessBtn.isSelected = true
                self.individualBtn.isSelected = false
            }
            
            if(updateType != "update"){
                if myPeopleList.type == "individual"{
                self.skipBtn.isHidden = false
                self.businessBtn.isHidden = false
                self.individualBtn.setTitle(self.registeredType, for: .normal)
            }
            }
            if(updateType != "update"){
                if myPeopleList.type == "business"{
                self.skipBtn.isHidden = false
                self.individualBtn.isHidden = false
                self.businessBtn.setTitle(self.registeredType, for: .normal)
            }
            }
            
            if registerAsLabel.text == "Registered as" {
                if myPeopleList.type == "individual"{
                self.businessBtn.isHidden = true
                    businessBtnLeadingSpace.constant = 110
                self.individualBtn.setTitle(self.registeredType, for: .normal)
                }
            }
            if registerAsLabel.text == "Registered as" {
                if myPeopleList.type == "business"{
                self.individualBtn.isHidden = true
                    businessBtnLeadingSpace.constant = 0
                    nameTopConstraint.constant = 80
                    self.businessName.isHidden = false
                self.businessBtn.setTitle(self.registeredType, for: .normal)
            }
            }
            
            if myPeopleList.country != "" {
                let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: myPeopleList.country])
                if let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) {
                    UserDefaults.standard.setValue(name, forKey: "selectedname")
                    UserDefaults.standard.setValue(myPeopleList.country, forKey: "selectedcountry")
                    self.countryBtn.setTitle(name, for: .normal)
                }
            } else {
                UserDefaults.standard.setValue("US", forKey: "selectedcountry")
                UserDefaults.standard.setValue("United States", forKey: "selectedname")
                self.countryBtn.setTitle(UserDefaults.standard.value(forKey: "selectedname") as? String ?? "US" , for: .normal)
            }
            
            if(myPeopleList.profileUrl == "") {
                self.profileImage.image = UIImage(named: "profile")
            } else {
                _ = myPeopleList.profileUrl.replacingOccurrences(of: " ", with: "")
                let profileImage = URL(string: myPeopleList.profileUrl)!
                self.profileImage.af.setImage(withURL: profileImage, placeholderImage: #imageLiteral(resourceName: "defaultImageCharity"))
            }
            
            if myPeopleList.terms == "" || myPeopleList.terms == "No" {
                self.termsView.isHidden = false
                self.skipBtn.isHidden = true
                termcondition = false
            } else{
                termcondition = true
                self.termsView.isHidden = true
            }
            
            switch myPeopleList.gender {
            case "F":
                femaleBtn.isSelected = true
                genterText = "F"
                break
            case "M":
                maleBtn.isSelected = true
                genterText = "M"
                break
            case "O":
                otherBtn.isSelected = true
                genterText = "O"
                break
            default:
                break
            }
            
            // Joe 10
        } else {
            print("There is an issue")
        }
        
        
        self.nameText.isUserInteractionEnabled = true
        self.emailText.isUserInteractionEnabled = true
    }
    
    @IBAction func updateAction(_ sender: UIButton) {
        
        guard let name = nameText.text, name != "" else {
         
         
         
        let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
         
        let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
         
        let messageAttrString = NSMutableAttributedString(string:"Please enter the name", attributes: messageFont)
         
        alertController.setValue(messageAttrString, forKey: "attributedMessage")
         
        let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
         
        }
         
        alertController.addAction(contact)
         
        self.present(alertController, animated: true, completion: nil)
         
        return
         
        }
         
         
         
        guard let email = emailText.text, email != "" else {
         
        return
         
        }
         
         
         
        guard termcondition != false else {
         
         
         
        let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
         
        let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
         
        let messageAttrString = NSMutableAttributedString(string:"Please check the terms and conditions", attributes: messageFont)
         
        alertController.setValue(messageAttrString, forKey: "attributedMessage")
         
        let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
         
        }
         
        alertController.addAction(contact)
         
        self.present(alertController, animated: true, completion: nil)
         
         
         
        return
         
        }
         
         
         
        let updateProfileUrl = String(format: URLHelper.iDonateUpdateProfile)
         
        let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
         
        loadingNotification.mode = MBProgressHUDMode.indeterminate
         
        loadingNotification.label.text = "Loading"
         
         
         
        let imageData = profileImage.image?.jpegData(compressionQuality: 0.25)
         
        let photoString = imageData!.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
         
        if let data = UserDefaults.standard.data(forKey: "people"),
         
        let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
         
         
         
        let postDict = ["name": name, //myPeopleList.name,
         
        "email": email,
         
        "user_id": myPeopleList.userID,
         
        "token": myPeopleList.token,
         
        "type": myPeopleList.type,
         
        "phone":mobileText.text ?? "",
         
        "country":UserDefaults.standard.value(forKey: "selectedcountry") as? String ?? "US",
         
        "gender":genterText,
         
        "photo":photoString,
         
        "business_name":businessName.text ?? "",
         
        "terms":termcondition == false ? "No" : "Yes"] as [String : Any]
         
         
         
        print(postDict)
         
         
         
        WebserviceClass.sharedAPI.performRequest(type: UpdateModel.self, urlString: updateProfileUrl, methodType: HTTPMethod.post, parameters: postDict as Parameters, success: { (response) in
         
        self.UpdateModelResponse = response
         
        self.updateArray = self.UpdateModelResponse?.data
         
        self.responsemMethod()
         
        print("Result: \(String(describing: response))") // response serialization result
         
        MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
         
         
         
        }) { (response) in
         
        MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
         
        }
         
        }
        
    }
    
    
    func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.pngData()!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    func responsemMethod()  {
        if(self.UpdateModelResponse?.status == 1) {
            
            let newPerson = UserDetails(name: self.updateArray!.name ?? "", email: self.updateArray!.email!, mobileNUmber: self.updateArray?.phone_number ?? "", gender: self.updateArray?.gender ?? "", profileUrl:(self.updateArray?.photo)!, country: self.updateArray?.country ?? "",token: self.updateArray!.token!,userID:self.updateArray?.user_id ?? "", type: self.updateArray?.type ?? "", businessName: self.updateArray?.business_name ?? "",terms: self.updateArray?.terms ?? "No")
            
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: newPerson)
            UserDefaults.standard.set(encodedData, forKey: "people")
            UserDefaults.standard.synchronize()
            
            if self.loginType == "Social" {
                if comingFromTypes == false{
                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
                else {
                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AdvancedVC") as? AdvancedVC
                    self.navigationController?.popToViewController(vc!, animated: true)
                }
            }
            else{
                guard let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController else { return }
                self.navigationController?.pushViewController(vc, animated: true)
//                self.present(vc, animated: true, completion: nil)
            }
            
        }
        else
        {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string:(self.UpdateModelResponse?.message)!, attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func skipAction(_ sender: UIButton) {
        
    }
    
    @objc func backAction(_sender:UIButton)  {
        self.view .endEditing(true)
        if self.loginType == "Social" {
            self.navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //        self.updateBtn.isHidden = false
        activeField = textField
        lastOffset = self.scrollView.contentOffset
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //        self.updateBtn.isHidden = false
        activeField = textField
        lastOffset = self.scrollView.contentOffset
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK:UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        profileImage.image = selectedImage
        
        picker.dismiss(animated: true, completion: nil)
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
}

private func imagePickerControllerDidCancel(picker: UIImagePickerController){
    print("picker cancel.")
}


