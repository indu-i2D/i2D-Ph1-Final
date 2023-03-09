//
//  ChangePasswordVC.swift
//  iDonate
//
//  Created by Im043 on 29/07/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import TKFormTextField
import Alamofire
import MBProgressHUD

class ChangePasswordVC: BaseViewController,UITextFieldDelegate {
    @IBOutlet var oldPassword: TKFormTextField!
    @IBOutlet var newPassword: TKFormTextField!
    @IBOutlet var oldPasswordBTN: UIButton!
    @IBOutlet var newPasswordBTN: UIButton!
    var forgotModel :  ForgotModel?
    var forgotData :  Forgotdata?
    var changeOrForgot:String?
    var changeModel:ChangeModel?
    var email: String?
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        }else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        
        self.oldPassword.placeholder = "Old password"
        self.oldPassword.enablesReturnKeyAutomatically = true
        self.oldPassword.returnKeyType = .done
        self.oldPassword.delegate = self
        self.oldPassword.accessibilityIdentifier = "oldPassword-textfield"
        
        self.oldPassword.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.oldPassword.font = UIFont.systemFont(ofSize: 18)
        self.oldPassword.selectedTitleColor = UIColor.darkGray
        self.oldPassword.titleColor = UIColor.darkGray
        self.oldPassword.placeholderColor = UIColor.darkGray
        
        self.oldPassword.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.oldPassword.selectedLineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.oldPassword.selectedLineHeight = 2
        self.addTargetForErrorUpdating(self.oldPassword)
        
        
        self.newPassword.placeholder = "New password"
        self.newPassword.enablesReturnKeyAutomatically = true
        self.newPassword.returnKeyType = .done
        self.newPassword.delegate = self
        self.newPassword.accessibilityIdentifier = "newPassword-textfield"
        
        self.newPassword.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.newPassword.font = UIFont.systemFont(ofSize: 18)
        self.newPassword.selectedTitleColor = UIColor.darkGray
        self.newPassword.titleColor = UIColor.darkGray
        self.newPassword.placeholderColor = UIColor.darkGray
        
        self.newPassword.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.newPassword.selectedLineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.newPassword.selectedLineHeight = 2
        self.addTargetForErrorUpdating(self.newPassword)
        
        if(changeOrForgot == "Forgot")
        {
            self.oldPassword.placeholder = "New password"
            self.newPassword.placeholder = "Confirm password"
        }
        else
        {
            self.oldPassword.placeholder = "Old password"
             self.newPassword.placeholder = "New password"
        }
        
        // Do any additional setup after loading the view.
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        self.view .endEditing(true)
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
       
        if textField == oldPassword {
            return TKDataValidator.password(text: textField.text)
        }
        if textField == newPassword {
            return TKDataValidator.password(text: textField.text)
        }
        return nil
    }
    
    @IBAction func oldPassword(_ sender: UIButton)
    {
        if(sender.isSelected == true)
        {
            sender.isSelected = false
            oldPassword.isSecureTextEntry = true
        }
        else
        {
            sender.isSelected = true
            oldPassword.isSecureTextEntry = false
        }
    }
    @IBAction func newPassword(_ sender: UIButton)
    {
        if(sender.isSelected == true)
        {
            sender.isSelected = false
            newPassword.isSecureTextEntry = true
        }
        else
        {
            sender.isSelected = true
            newPassword.isSecureTextEntry = false
        }
    }
    @objc func backAction(_sender:UIButton)  {
        
        if constantFile.changepasswordBack == true {
            let alert = UIAlertController(title: "", message: "Returning To settings Without Making Changes?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.view .endEditing(true)
                self.navigationController?.popViewController(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }else {
            let alert = UIAlertController(title: "", message: "Returning To login Without Making Changes?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.view .endEditing(true)
                self.navigationController?.popViewController(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
     @IBAction func changePassword(_ sender: UIButton)
     {
        self.view .endEditing(true)
         if(changeOrForgot == "Forgot")
         {
            upadtePassword()
        }else
         {
            changePassword()
        }
    }
    
    
    func upadtePassword() {
        
        if(oldPassword.text == "") || (newPassword.text == "") {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "Please enter all fields", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
        }
        else if (oldPassword.text != newPassword.text) {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "Please enter correct password", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
        }else if self.oldPassword.text?.tk_isValidPassword() == false && self.newPassword.text?.tk_isValidPassword() == false {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "Please enter valid password", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
            return
        }else{
            let postDict = ["user_id": userId!,"password":newPassword.text as Any] as [String : Any]
            let updatePasswordString = String(format: URLHelper.iDonateUpdatePassword)
            let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Loading"
            
            WebserviceClass.sharedAPI.performRequest(type: ForgotModel.self ,urlString: updatePasswordString, methodType: .post, parameters: postDict, success: { (response) in
                
                self.forgotModel = response
                self.result(status: (self.forgotModel?.status)!, message: (self.forgotModel?.message)!)
                print("Result: \(String(describing: response))")                     // response serialization result
                MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            }) { (response) in
                MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            }
            
        }
    }
    
    
    func updatePasswordResponse() {
        
    }
    
    func changePassword() {
    
        if(oldPassword.text == "") || (newPassword.text == "") {
            showAlert(msg: "Please enter all fields")
        } else if oldPassword.text == newPassword.text {
            showAlert(msg: "Old and New password have to be different")
        }else if self.newPassword.text?.tk_isValidPassword() == false{
            showAlert(msg: "Please enter valid new password")
        }else {
            if let data = UserDefaults.standard.data(forKey: "people"),
                let user = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
                let postDict = ["user_id": user.userID,"token":user.token,"old_password":oldPassword.text as Any,"new_password":newPassword.text as Any] as [String : Any]
                let changePasswordUrl = String(format: URLHelper.iDonateChangePassword)
                let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
                loadingNotification.mode = MBProgressHUDMode.indeterminate
                loadingNotification.label.text = "Loading"
                
                WebserviceClass.sharedAPI.performRequest(type: ChangeModel.self ,urlString: changePasswordUrl, methodType: .post, parameters: postDict, success: { (response) in
                    self.changeModel = response
                    self.result(status: (self.changeModel?.status)!, message: (self.changeModel?.message)!)
                    print("Result: \(String(describing: response))")                     // response serialization result
                    MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                }) { (response) in
                    MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                }
            }
        }
    }
    
    func result(status:Int,message:String) {
        if(status == 1){
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: message, attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                
                self.navigationController?.pushViewController(vc!, animated: true)
            }
//            let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
//
//            }
            alertController.addAction(ok)
//            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: message, attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showAlert(msg: String) {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
        let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
        let messageAttrString = NSMutableAttributedString(string: msg, attributes: messageFont)
        alertController.setValue(messageAttrString, forKey: "attributedMessage")
        let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
        }
        alertController.addAction(contact)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
