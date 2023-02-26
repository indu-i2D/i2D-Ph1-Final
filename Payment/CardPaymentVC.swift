//
//  CardPaymentVC.swift
//  iDonate
//
//  Created by Im043 on 26/07/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

class CardPaymentVC: BaseViewController,UITextFieldDelegate {
    
    @IBOutlet weak var cvvText: UITextField!
     @IBOutlet weak var amountText: UILabel!
    var amountString:String = ""
    override func viewDidLoad() {
        let amountString = UserDefaults.standard.value(forKey: "Amount") as! String
        amountText.text = amountString
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        
        if(iDonateClass.hasSafeArea) {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        }else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
    
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.view .endEditing(true)
    }

    @objc func backAction(_sender:UIButton)  {
        self.navigationController?.popViewController(animated: true)
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
    
    
    @IBAction func payNowAction(_ sender: UIButton) {
        if(cvvText.text?.count == 0) {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string:"Please enter CVV", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ResultVC") as? ResultVC
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if isBackSpace == -92 {
            print("Backspace was pressed")
            return true
        }
        
        if((textField.text?.count)! > 2){
            return false
        }else {
            return true
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
