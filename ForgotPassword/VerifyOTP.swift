//
//  VerifyOTP.swift
//  iDonate
//
//  Created by Im043 on 26/07/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import TKFormTextField
import Alamofire
import MBProgressHUD

class VerifyOTP: BaseViewController,UITextFieldDelegate {
    
    @IBOutlet var firstText: TKFormTextField!
    @IBOutlet var secondText: TKFormTextField!
    @IBOutlet var thirdText: TKFormTextField!
    @IBOutlet var fourthText: TKFormTextField!
    var forgotModel :  ForgotModel?
    var forgotData :  Forgotdata?
    @IBOutlet var emaillbl: UILabel!
    
    var email: String?
    var user_id: String?

    @IBOutlet var resendButton: UIButton!
    @IBOutlet var backButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTexifiled()
        self.navIMage.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        
        self.firstText.textAlignment = .center
        self.secondText.textAlignment = .center
        self.thirdText.textAlignment = .center
        self.fourthText.textAlignment = .center
        
        emaillbl.text = email
        
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
    
        resendButton.addTarget(self, action: #selector(resendCode), for: .touchUpInside)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.view .endEditing(true)
    }
    
    func textFieldShouldReturnSingle(_ textField: UITextField , newString : String) {
        let nextTag: Int = textField.tag + 1
        let nextResponder: UIResponder? = textField.superview?.superview?.viewWithTag(nextTag)
        textField.text = newString
        if let nextR = nextResponder{
            // Found next responder, so set it.
            nextR.becomeFirstResponder()
        }
        else {
            self.view .endEditing(true)
            textField.resignFirstResponder()
            verifyOtp()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 1
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if(newString.length == 1) {
            textFieldShouldReturnSingle(textField , newString : newString as String)
            return newString.length <= maxLength
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        self.view .endEditing(true)
    }
    
    @IBAction func changeMail(_ sender: UIButton) {
        constantFile.changemail = true
        self.navigationController?.popViewController(animated: true)
    }
    
    func verifyOtp() {
        let otp = self.firstText.text! + self.secondText.text! + self.thirdText!.text! + self.fourthText!.text!
                
        let postDict: Parameters = ["user_id":user_id,"otp":otp]
        let verifyOtpUrl = String(format: URLHelper.iDonateVerifyOtp)
        let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        
        WebserviceClass.sharedAPI.performRequest(type: ForgotModel.self, urlString: verifyOtpUrl, methodType: HTTPMethod.post, parameters: postDict as Parameters,  success: { (response) in
            self.forgotModel = response
            self.forgotData = self.forgotModel?.data
            self.forgotResponse()
            print("Result: \(String(describing: response))")    // response serialization result
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            
        }) { (response) in
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }
    }
    
    
    @objc func resendCode() {
        
        self.firstText.text = ""
        self.secondText.text = ""
        self.thirdText.text = ""
        self.fourthText.text = ""

        let postDict = ["email":self.emaillbl.text]
        let forgotPasswordUrl = String(format: URLHelper.iDonateForgotPassword)
        let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        WebserviceClass.sharedAPI.performRequest(type: ForgotModel.self, urlString: forgotPasswordUrl, methodType: HTTPMethod.post, parameters: postDict as Parameters,  success: { (response) in
            self.forgotModel = response
            self.forgotData = self.forgotModel?.data
            self.resendResponse()
            print("Result: \(String(describing: response))")                     // response serialization result
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }) { (response) in
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }
    }
    
    func resendResponse() {
        if(self.forgotModel?.status == 1) {
            
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string:("OTP re-send successfully"), attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
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
    
    func forgotResponse() {
        if(self.forgotModel?.status == 1) {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChangePasswordVC") as? ChangePasswordVC
            vc?.userId = user_id
            vc!.changeOrForgot = "Forgot"
            self.navigationController?.pushViewController(vc!, animated: true)
            
            //            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            //            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            //            let messageAttrString = NSMutableAttributedString(string:(self.forgotModel?.message)!, attributes: messageFont)
            //            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            //            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            //
            //
            //            }
            //            alertController.addAction(contact)
            //            self.present(alertController, animated: true, completion: nil)
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
    
    func setupTexifiled(){
        
        self.firstText.enablesReturnKeyAutomatically = true
        self.firstText.returnKeyType = .done
        self.firstText.delegate = self
        self.firstText.accessibilityIdentifier = "firstText-textfield"
        
        self.secondText.enablesReturnKeyAutomatically = true
        self.secondText.returnKeyType = .done
        self.secondText.delegate = self
        self.secondText.accessibilityIdentifier = "secondText-textfield"
        
        self.thirdText.enablesReturnKeyAutomatically = true
        self.thirdText.returnKeyType = .done
        self.thirdText.delegate = self
        self.thirdText.accessibilityIdentifier = "thirdText-textfield"
        
        self.fourthText.enablesReturnKeyAutomatically = true
        self.fourthText.returnKeyType = .done
        self.fourthText.delegate = self
        self.fourthText.accessibilityIdentifier = "fourthText-textfield"
        
        self.firstText.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.firstText.font = UIFont.systemFont(ofSize: 18)
        self.firstText.selectedTitleColor = UIColor.darkGray
        self.firstText.titleColor = UIColor.darkGray
        self.firstText.placeholderColor = UIColor.darkGray
        
        self.secondText.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.secondText.font = UIFont.systemFont(ofSize: 18)
        self.secondText.selectedTitleColor = UIColor.darkGray
        self.secondText.titleColor = UIColor.darkGray
        self.secondText.placeholderColor = UIColor.darkGray
        
        self.thirdText.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.thirdText.font = UIFont.systemFont(ofSize: 18)
        self.thirdText.selectedTitleColor = UIColor.darkGray
        self.thirdText.titleColor = UIColor.darkGray
        self.thirdText.placeholderColor = UIColor.darkGray
        
        self.fourthText.titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.fourthText.font = UIFont.systemFont(ofSize: 18)
        self.fourthText.selectedTitleColor = UIColor.darkGray
        self.fourthText.titleColor = UIColor.darkGray
        self.fourthText.placeholderColor = UIColor.darkGray
        
        self.firstText.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.firstText.selectedLineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.firstText.selectedLineHeight = 2
        
        self.secondText.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.secondText.selectedLineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.secondText.selectedLineHeight = 2
        
        self.thirdText.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.thirdText.selectedLineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.thirdText.selectedLineHeight = 2
        
        self.fourthText.lineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.fourthText.selectedLineColor = UIColor(red:0.61, green:0.44, blue:0.57, alpha:1.0)
        self.fourthText.selectedLineHeight = 2
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
