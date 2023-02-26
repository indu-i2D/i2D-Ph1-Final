//
//  ForgotVC.swift
//  iDonate
//
//  Created by Im043 on 26/07/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import TKFormTextField
import Alamofire
import MBProgressHUD

class ForgotVC: BaseViewController,UITextFieldDelegate {
    
    @IBOutlet var emailText: TKFormTextField!
    @IBOutlet var headingTag: UILabel!
    @IBOutlet var sendBtn: UIButton!

    var forgotModel :  ForgotModel?
    var forgotData :  Forgotdata?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navIMage.isHidden = true
        
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        }
        else{
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        
        self.view .addSubview(menuBtn)
        
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        self.emailText.placeholder = "Email"
        self.emailText.enablesReturnKeyAutomatically = true
        self.emailText.returnKeyType = .done
        self.emailText.delegate = self
        self.emailText.accessibilityIdentifier = "email-textfield"
        
        self.emailText.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.emailText.font = UIFont.systemFont(ofSize: 18)
        self.emailText.selectedTitleColor = UIColor.darkGray
        self.emailText.titleColor = UIColor.darkGray
        self.emailText.placeholderColor = UIColor.darkGray
        
        self.emailText.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.emailText.selectedLineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.emailText.selectedLineHeight = 2
        self.addTargetForErrorUpdating(self.emailText)
        
        sendBtn.titleLabel?.minimumScaleFactor = 0.6
        sendBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        //        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if constantFile.changemail == true {
            headingTag.text = "CHANGE EMAIL"
        }else {
            headingTag.text = "FORGOT PASSWORD"
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.view .endEditing(true)
        headingTag.text = "FORGOT PASSWORD"
        constantFile.changemail = false
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
        if textField == emailText {
            return TKDataValidator.email(text: textField.text)
        }
        
        return nil
    }
    
    @objc func backAction(_sender:UIButton)  {
        
        let alert = UIAlertController(title: "Alert", message: "Returning To Login Without Making Changes?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { action in
                   self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
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
    
    func forgotResponse() {
        if(self.forgotModel?.status == 1) {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "VerifyOTP") as? VerifyOTP
            vc?.email = self.emailText.text?.trimmingCharacters(in: .whitespaces)
            vc?.user_id = self.forgotData?.user_id
            self.navigationController?.pushViewController(vc!, animated: false)
        }
        else {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string:(self.forgotModel?.message!)!, attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
