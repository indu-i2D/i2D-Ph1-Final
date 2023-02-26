//
//  PaymentView.swift
//  iDonate
//
//  Created by Im043 on 22/07/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import TKFormTextField

protocol paymentDelegate: class {
    func paymentResponse( string: String)
}

class PaymentView: UIView,UITextFieldDelegate,UIGestureRecognizerDelegate {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    typealias RatingViewDoneBlock = ( _ selectedRating: Int?,_ selectedValue: String?) -> Void
    var doneBlock:RatingViewDoneBlock?
    weak var delegate: paymentDelegate?
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var cancelBtn : UIButton!
    @IBOutlet var removeBtn : UIButton!
    @IBOutlet var doneBtn : UIButton!
    @IBOutlet var donateView : UIView!
    @IBOutlet var amountText: TKFormTextField!
    
    
    
    
    func openMenuview(controller : UIView ,_ Bool : Int, delegate: paymentDelegate, withSuccess successBlock: @escaping RatingViewDoneBlock){
        
        var nibView:PaymentView?
        nibView = Bundle.main.loadNibNamed("PaymentView", owner: self, options: nil)![0] as? PaymentView
        nibView?.frame = controller.bounds
        nibView?.doneBlock = successBlock
        controller.addSubview(nibView!)
        nibView?.delegate = delegate
        nibView!.amountText.placeholder = "Enter Amount"
        nibView!.amountText.text = "$ 10"
        nibView!.amountText.enablesReturnKeyAutomatically = true
        nibView!.amountText.returnKeyType = .done
        nibView!.amountText.delegate = nibView
        nibView!.amountText.titleLabel.font = UIFont.systemFont(ofSize: 14)
        nibView!.amountText.font = UIFont.systemFont(ofSize: 24)
        nibView!.amountText.selectedTitleColor = UIColor.darkGray
        nibView!.amountText.titleColor = UIColor.darkGray
        nibView!.amountText.placeholderColor = UIColor.darkGray
        nibView!.amountText.errorLabel.font = UIFont.systemFont(ofSize: 18)
        
        
    }
    @IBAction func doneAction(_ sender:UIButton){
        self.doneBlock!(6,"\(6)")
    }
    
    
    @IBAction func cancelAction(_ sender:UIButton){
        self.delegate?.paymentResponse(string: "1")
        self.doneBlock!(4,"\(4)")
    }
    
    @IBAction func donateAction(_ sender:UIButton) {
        UserDefaults.standard.set(amountText.text, forKey: "Amount")
        self.doneBlock!(1,"\(1)")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
        self.doneBlock!(5,"\(5)")
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.doneBlock!(6,"\(6)")
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                if(string.count == 1){
                    return false
                }
            }
        }
        return true
    }
    
    @objc func myviewTapped(_ sender: UITapGestureRecognizer) {
        
    }
}
