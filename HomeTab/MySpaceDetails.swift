//
//  MySpaceDetails.swift
//  iDonate
//
//  Created by Im043 on 04/07/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
import TKFormTextField
import Braintree
import BraintreeDropIn

class MySpaceDetails: BaseViewController ,UITableViewDelegate,UITableViewDataSource,UITabBarDelegate,UITextFieldDelegate{
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet var header: UILabel!
    @IBOutlet var notificationTabBar: UITabBar!
    @IBOutlet var noresultsview: UIView!
    @IBOutlet var noresultMEssage: UILabel!
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var cancelBtn : UIButton!
    @IBOutlet var amountText: TKFormTextField!
    @IBOutlet var donateBTn : UIButton!
    @IBOutlet var continuePaymentBTn : UIButton!

    var processingCharges = ProcessingChargesView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))

    var charityLikeArray : [LikeArrayModel]?
    var charityFollowArray : [FollowArrayModel]?
    var charityDonationArray : [DonationArrayModel]?

    var LikeOrFollow:String?
    var likeFOllowCOunt:String?
    var charityID:String?
    var charityCount:String?
    var followArray:String?
    var categoryCode : [String]?
    var subCategoryCode : [String]?
    var childCategory : [String]?
    
    weak var payDelegate: paymentDelegate?
    var donateFlag:Bool = false
    
    var selectedCharity:LikeArrayModel? = nil
    
//    var payPalConfig = PayPalConfiguration()
//    let items:NSMutableArray = NSMutableArray()
//    //Set environment connection.
//    var environment:String = PayPalEnvironmentNoNetwork {
//        willSet(newEnvironment) {
//            if (newEnvironment != environment) {
//                PayPalMobile.preconnect(withEnvironment: newEnvironment)
//            }
//        }
//    }

    
    let digitBeforeDecimal = 5
    let digitAfterDecimal = 2
    var decimalAdded = false
    func textField(_ textField: UITextField, shouldChangeCharactersIn   range: NSRange, replacementString string: String) -> Bool {
        
        if self.amountText.text!.isEmpty {
            decimalAdded = false
        }
        if self.amountText.text!.contains(".") {
            decimalAdded = true
        }else{
            decimalAdded = false
        }
        if decimalAdded && string == "." {
            return false
        }
        
        if textField != self.amountText {
            return true
        }
        let computationString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if computationString.contains("..") {
            return false
        }
        let arrayOfSubStrings = computationString.components(separatedBy: ".")
        if arrayOfSubStrings.count == 1 && computationString.count > digitBeforeDecimal {//
            return false
        } else if arrayOfSubStrings.count == 2 {
            let stringPostDecimal = arrayOfSubStrings[1]
            return stringPostDecimal.count <= digitAfterDecimal
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "searchcell")
        
        if(LikeOrFollow == "Like"){
            header.text = "MY LIKES"
            if(likeFOllowCOunt == "0"){
                self.noresultsview.isHidden = false
                self.noresultMEssage.text = "You haven't like any non-profits"
            }
        } else if(LikeOrFollow == "Donation"){
            header.text = "MY DONATIONS"
            if(likeFOllowCOunt == "0"){
                self.noresultsview.isHidden = false
                self.noresultMEssage.text = "You haven't like any non-profits"
            }
        }
        else {
            header.text = "MY FOLLOWINGS"
            if(likeFOllowCOunt == "0") {
                self.noresultsview.isHidden = false
                self.noresultMEssage.text = "You haven't follow any non-profits"
            }
        }
        
        
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        }else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        let mytapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(cancelView))
        mytapGestureRecognizer1.numberOfTapsRequired = 1
        mytapGestureRecognizer1.cancelsTouchesInView = false
        self.blurView.addGestureRecognizer(mytapGestureRecognizer1)
        self.amountText.placeholder = ""
        self.amountText.text = "$ 10"
        self.amountText.enablesReturnKeyAutomatically = true
        self.amountText.returnKeyType = .done
        self.amountText.delegate = self
        self.amountText.titleLabel.font = UIFont.systemFont(ofSize: 14)
        self.amountText.font = UIFont.systemFont(ofSize: 34)
        self.amountText.selectedTitleColor = UIColor.darkGray
        self.amountText.titleColor = UIColor.darkGray
        self.amountText.placeholderColor = UIColor.darkGray
        self.amountText.errorLabel.font = UIFont.systemFont(ofSize: 18)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if(donateFlag == true){
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
        if(item.tag == 0) {
            UserDefaults.standard.set(0, forKey: "tab")
            self.navigationController?.pushViewController(vc!, animated: false)
        } else {
            UserDefaults.standard.set(1, forKey: "tab")
            self.navigationController?.pushViewController(vc!, animated: false)
        }
    }
    
    @objc func backAction(_sender:UIButton)  {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(LikeOrFollow == "Like") {
            return charityLikeArray?.count ?? 0
        } else if (LikeOrFollow == "Donation") {
            return charityDonationArray?.count ?? 0
        } else{
            return charityFollowArray?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(LikeOrFollow == "Like") {
            let charity = charityLikeArray![indexPath.row]
            let cell = searchTableView.dequeueReusableCell(withIdentifier: "searchcell") as! SearchTableViewCell
            cell.title.text = charity.name
            cell.address.text = charity.street!+","+charity.city!
            let likeString = charity.like_count! + " Likes"
            cell.likeBtn.setTitle(likeString, for: .normal)
            let placeholderImage = UIImage(named: "defaultImageCharity")!
            
            if charity.logo != nil && charity.logo != "" {
                if let url = URL(string: charity.logo!) {
                    cell.logoImage.af.setImage(withURL: url, placeholderImage: placeholderImage)
                }
                
            } else {
                cell.logoImage.image = placeholderImage
            }
            
            cell.followingBtn.tag = indexPath.row
            cell.likeBtn.tag = indexPath.row
            cell.donateBtn.tag = indexPath.row
            cell.followingBtn.addTarget(self, action: #selector(followAction(_:)), for: .touchUpInside)
            cell.likeBtn.addTarget(self, action: #selector(likeAction), for: .touchUpInside)
            cell.donateBtn.addTarget(self, action: #selector(donateAction), for: .touchUpInside)
            if(charity.liked == "0") {
                cell.likeBtn.isSelected = false
            } else {
                cell.likeBtn.isSelected = true
            }
            if(charity.followed == "0") {
                cell.followingBtn.isSelected = false
                cell.followingBtn.setTitle("Follow", for: .normal)
            } else {
                cell.followingBtn.isSelected = true
                cell.followingBtn.setTitle("Following", for: .normal)
            }
            return cell
        } else if (LikeOrFollow == "Donation") {
            let charity = charityDonationArray![indexPath.row]
            let cell = searchTableView.dequeueReusableCell(withIdentifier: "searchcell") as! SearchTableViewCell
            //            let animation = AnimationFactory.makeMoveUpWithFade(rowHeight: 150, duration: 0.5, delayFactor: 0.05)
            cell.title.text = charity.name
            cell.address.text = charity.street!+","+charity.city!
            let likeString = charity.like_count! + " Likes"
            cell.likeBtn.setTitle(likeString, for: .normal)
            let placeholderImage = UIImage(named: "defaultImageCharity")!
            
            if let logo = charity.logo, logo != "" {
                let url = URL(string: logo)!
                cell.logoImage.af.setImage(withURL: url, placeholderImage: placeholderImage)
            } else{
                cell.logoImage.image = placeholderImage
            }
            
            //            let animator = Animator(animation: animation)
            //            animator.animate(cell: cell, at: indexPath, in: tableView)
            cell.followingBtn.tag = indexPath.row
            cell.likeBtn.tag = indexPath.row
            cell.donateBtn.tag = indexPath.row
            cell.followingBtn.addTarget(self, action: #selector(followAction(_:)), for: .touchUpInside)
            cell.likeBtn.addTarget(self, action: #selector(likeAction), for: .touchUpInside)
            cell.donateBtn.addTarget(self, action: #selector(donateAction), for: .touchUpInside)
            if(charity.liked == "0") {
                cell.likeBtn.isSelected = false
            }
            else {
                cell.likeBtn.isSelected = true
            }
            if(charity.followed == "0") {
                cell.followingBtn.isSelected = false
                cell.followingBtn.setTitle("Follow", for: .normal)
            }
            else {
                cell.followingBtn.isSelected = true
                cell.followingBtn.setTitle("Following", for: .normal)
            }
            return cell
        }
            
        else{
            let charity = charityFollowArray![indexPath.row]
            let cell = searchTableView.dequeueReusableCell(withIdentifier: "searchcell") as! SearchTableViewCell
            //            let animation = AnimationFactory.makeMoveUpWithFade(rowHeight: 150, duration: 0.5, delayFactor: 0.05)
            cell.title.text = charity.name
            cell.address.text = charity.street!+","+charity.city!
            let likeString = charity.like_count! + " Likes"
            cell.likeBtn.setTitle(likeString, for: .normal)
            let placeholderImage = UIImage(named: "defaultImageCharity")!
            
            if let logo = charity.logo, logo != "" {
                let url = URL(string: logo)!
                cell.logoImage.af.setImage(withURL: url, placeholderImage: placeholderImage)
            } else{
                cell.logoImage.image = placeholderImage
            }
            
            //            let animator = Animator(animation: animation)
            //            animator.animate(cell: cell, at: indexPath, in: tableView)
            cell.followingBtn.tag = indexPath.row
            cell.likeBtn.tag = indexPath.row
            cell.donateBtn.tag = indexPath.row
            cell.followingBtn.addTarget(self, action: #selector(followAction(_:)), for: .touchUpInside)
            cell.likeBtn.addTarget(self, action: #selector(likeAction), for: .touchUpInside)
            cell.donateBtn.addTarget(self, action: #selector(donateAction), for: .touchUpInside)
            if(charity.liked == "0") {
                cell.likeBtn.isSelected = false
            }
            else {
                cell.likeBtn.isSelected = true
            }
            if(charity.followed == "0") {
                cell.followingBtn.isSelected = false
                cell.followingBtn.setTitle("Follow", for: .normal)
            }
            else {
                cell.followingBtn.isSelected = true
                cell.followingBtn.setTitle("Following", for: .normal)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    
    @IBAction func likeAction(_ sender:UIButton) {
        
        if(LikeOrFollow == "Like") {
            let charity = charityLikeArray![sender.tag]
            
            if(sender.isSelected){
                sender.isSelected = false
                charityCount = "0"
            }
            else {
                charityCount = "1"
                sender.isSelected = true
            }
            charityLikeAction(like: charityCount!, charityId: charity.id!,index:sender.tag)
             
        } else if (LikeOrFollow == "Donation") {
            let charity = charityDonationArray![sender.tag]
            if(sender.isSelected) {
                sender.isSelected = false
                charityCount = "0"
            } else{
                charityCount = "1"
                sender.isSelected = true
            }
            
            charityLikeAction(like: charityCount!, charityId: charity.id!,index:sender.tag)

        }
        else{
            
            let charity = charityFollowArray![sender.tag]
            if(sender.isSelected) {
                sender.isSelected = false
                charityCount = "0"
            }else {
                charityCount = "1"
                sender.isSelected = true
            }
            charityLikeAction(like: charityCount!, charityId: charity.id!,index:sender.tag)

        }
        
        
    }
    
    @IBAction func donateAction(_ sender:UIButton)  {
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            blurView.frame =  self.view.frame
            self.continuePaymentBTn.tag = sender.tag
            self.view .addSubview(blurView)
        } else {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "For Advance Features Please Log-in/Register", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                
            }
            alertController.addAction(ok)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func paymentAction(_ sender:UIButton) {
        
        if(amountText.text == "") {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string:"please enter amount", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(contact)
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            let amount = self.amountText.text?.replacingOccurrences(of: "$", with: "")
            
            let amountWithoutDollar = amount!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let price = Double(amountWithoutDollar)
            
            if (price! < 1) {
                let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
                let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
                let messageAttrString = NSMutableAttributedString(string:"Amount should be minimum of 1$", attributes: messageFont)
                alertController.setValue(messageAttrString, forKey: "attributedMessage")
                let contact = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                }
                alertController.addAction(contact)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            let urlString = "\(URLHelper.baseURL)braintree_client_token"

            let url = URL(string: urlString)!
            
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")

            AF.request(request).responseJSON {
                (response) in
                
                MBProgressHUD.hide(for: self.view, animated: true)

                switch response.result {
                    case .success(let value) :
                        let drop =  BTDropInRequest()
                        drop.vaultManager = true
                        drop.paypalDisabled = false
                        drop.cardDisabled = false
                        print(drop)
                        let dropIn = BTDropInController(authorization: "\(value)", request: drop)
                        { (controller, result, error) in
                            if (error != nil) {
                                print("ERROR")
                            } else if (result?.isCancelled == true) {
                                print("CANCELLED")
                            } else if let result = result {
                                
                                guard let amount = self.amountText.text else {
                                    return
                                }
                                
                                let amountWithoutDollar = amount.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                guard Double(amountWithoutDollar) != 0 else {
                                    return
                                }
                                
                                let processingValue = self.calculatePercentage(value: Double(amountWithoutDollar) ?? 0,percentageVal: 1)
                                
                                let amountWithProcessingValue = (Double(amountWithoutDollar) ?? 0) + processingValue
                                
                                let merchantChargesValue = self.calculatePercentage(value: amountWithProcessingValue ,percentageVal: 2.9) + 0.30
                                
                                let totalAmount = amountWithProcessingValue + merchantChargesValue
                                
                                if let data = UserDefaults.standard.data(forKey: "people"),
                                    let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
                                    print(myPeopleList.name)
                                    // Joe 10
                                    
                                    MBProgressHUD.showAdded(to: self.view, animated: true)
                                    
                                    var charityId = ""
                                    var charityName = ""
                                                            
                                    self.blurView.removeFromSuperview()
                                    
                                    if self.LikeOrFollow == "Like" {
                                        charityId = (self.charityLikeArray![sender.tag].id)!
                                        charityName = (self.charityLikeArray![sender.tag].name)!
                                        
                                    } else if self.LikeOrFollow == "Donation" {
                                        charityId = (self.charityDonationArray![sender.tag].id)!
                                        charityName = (self.charityDonationArray![sender.tag].name)!
                                        
                                    } else {
                                        charityId = (self.charityFollowArray![sender.tag].id)!
                                        charityName = (self.charityFollowArray![sender.tag].name)!
                                    }
                                    
                                    let postDict: Parameters = ["user_id":myPeopleList.userID,
                                                                "token":myPeopleList.token,
                                                                "charity_id": charityId,
                                                                "charity_name": charityName,
                                                                "transaction_id":result.paymentMethod?.nonce ?? "",
                                                                "amount":amount,
                                                                "payment_type": result.paymentMethod?.type ?? "",
                                                                "status":"approved",
                                                                "merchant_charges":merchantChargesValue,
                                                                "processing_fee":processingValue]
                                    
                                   
                                    
                                    let paymentUrl = String(format: URLHelper.iDonatePayment)
                                    
                                    WebserviceClass.sharedAPI.performRequest(type: paymentModel.self, urlString: paymentUrl, methodType: HTTPMethod.post, parameters: postDict as Parameters, success: { (response) in
                                        
                                        MBProgressHUD.hide(for: self.view, animated: true)
                                        
                                        print("payment response", response)
                                        
                                        let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
                                        let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
                                        let messageAttrString = NSMutableAttributedString(string:"Payment Done Successfully", attributes: messageFont)
                                        alertController.setValue(messageAttrString, forKey: "attributedMessage")
                                        let contact = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                                            self.blurView.removeFromSuperview()
                                        }
                                        alertController.addAction(contact)
                                        self.present(alertController, animated: true, completion: nil)
                                        
                                        print("Result: \(String(describing: response))") // response serialization result
                                        
                                        
                                    }) { (response) in
                                        MBProgressHUD.hide(for: self.view, animated: true)
                                    }
                                }
                                
                            }
                            controller.dismiss(animated: true, completion: nil)
                        }
                        self.present(dropIn!, animated: true, completion: nil)

                    case .failure(let error) :
                        print(error)

                }
            }
                        
          
        }
            
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        donateFlag = true
        textField.becomeFirstResponder()
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    @IBAction func followAction(_ sender:UIButton) {
        
        if(LikeOrFollow == "Like") {
            let charity = charityLikeArray![sender.tag]
            if(sender.isSelected) {
                sender.isSelected = false
                charityCount = "0"
            }else {
                charityCount = "1"
                sender.isSelected = true
            }
            followAction(follow: charityCount!, charityId: charity.id!,index:sender.tag)
        } else if(LikeOrFollow == "Donation") {
            let charity = charityDonationArray![sender.tag]
            if(sender.isSelected) {
                sender.isSelected = false
                charityCount = "0"
            }else {
                charityCount = "1"
                sender.isSelected = true
            }
            followAction(follow: charityCount!, charityId: charity.id!,index:sender.tag)
        } else {
            let charity = charityFollowArray![sender.tag]
            if(sender.isSelected) {
                sender.isSelected = false
                charityCount = "0"
            } else{
                charityCount = "1"
                sender.isSelected = true
            }
            followAction(follow: charityCount!, charityId: charity.id!,index:sender.tag)
        }
        
    }
    
    @objc func cancelView(recognizer: UITapGestureRecognizer) {
        self.view .endEditing(true)
    }
    
    @IBAction func cancelAction(_ sender:UIButton) {
        blurView .removeFromSuperview()
    }
    
    func charityLikeAction(like:String,charityId:String,index:Int) {
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            let postDict: Parameters = ["user_id":myPeopleList.userID,"token":myPeopleList.token,"charity_id":charityId,"status":like]
            let logINString = String(format: URLHelper.iDonateCharityLike)
            WebserviceClass.sharedAPI.performRequest(type: CharityLikeModel.self, urlString: logINString, methodType: .post, parameters: postDict, success: { (response) in
                self.charityLIkeResponseMEthod(index: index,liked: like)
                
            }) { (response) in
                
            }
        } else{
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "For Advance Features Please Log-in/Register", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                
            }
            alertController.addAction(ok)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func followAction(follow:String,charityId:String,index:Int) {
        
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            // Joe 10
            
            let postDict: Parameters = ["user_id":myPeopleList.userID,"token":myPeopleList.token,"charity_id":charityId,"status":follow]
            
            let charityFollowUrl = String(format: URLHelper.iDonateCharityFollow)
            
            WebserviceClass.sharedAPI.performRequest(type: CharityLikeFollowStatus.self ,urlString: charityFollowUrl, methodType: .post, parameters: postDict, success: { (response) in

                self.charityfollowResponseMethod(index: index, follwed: follow)
                print("Result: \(String(describing: response))") // response serialization result
                
            }) { (response) in
                
            }
        } else{
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "For Advance Features Please Log-in/Register", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                
            }
            alertController.addAction(ok)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func charityfollowResponseMethod(index:Int,follwed:String) {
        
        if(LikeOrFollow == "Like") {
            
            let charity = self.charityLikeArray?[index]
            if(follwed == "1") {
                charity?.followed = "1"
            } else{
                charity?.followed = "0"
            }
            self.charityLikeArray?[index] = charity!
            
        } else if (LikeOrFollow == "Donation") {
            var charity = self.charityDonationArray?[index]
            if(follwed == "1") {
                charity?.followed = "1"
            } else{
                charity?.followed = "0"
            }
            self.charityDonationArray?[index] = charity!
            
        } else {
            
            let charity = self.charityFollowArray?[index]
            if(follwed == "1") {
                charity?.followed = "1"
            }else {
                charity?.followed = "0"
            }
            
            self.charityFollowArray?[index] = charity!
            
        }
        
        self.searchTableView.reloadData()
        
//        let indexPathRow:Int = index
//        let indexPosition = IndexPath(row: indexPathRow, section: 0)
//
//        UIView.performWithoutAnimation {
//            self.searchTableView .reloadRows(at: [indexPosition], with: .none)
//        }
    }
    
    func charityLIkeResponseMEthod(index:Int,liked:String) {
        
        if(LikeOrFollow == "Like")  {
            let charity = self.charityLikeArray?[index]
            if(liked == "1"){
                charity?.liked = "1"
                let likedCount = (Int(charity?.like_count ?? "0") ?? 0)+1
                charity?.like_count = String(likedCount)
            } else{
                charity?.liked = "0"
                let likedCount = (Int(charity?.like_count ?? "0") ?? 0)-1
                charity?.like_count = String(likedCount)
            }
            self.charityLikeArray?[index] = charity!
        } else if (LikeOrFollow == "Donation")  {
            var charity = self.charityDonationArray?[index]
            if(liked == "1"){
                charity?.liked = "1"
                let likedCount = (Int(charity?.like_count ?? "0") ?? 0)+1
                charity?.like_count = String(likedCount)
            } else{
                charity?.liked = "0"
                let likedCount = (Int(charity?.like_count ?? "0") ?? 0)-1
                charity?.like_count = String(likedCount)
            }
            self.charityDonationArray?[index] = charity!
        } else{
            let charity = self.charityFollowArray?[index]
            if(liked == "1"){
                charity?.liked = "1"
                let likedCount = (Int(charity?.like_count ?? "0") ?? 0)+1
                charity?.like_count = String(likedCount)
            } else{
                charity?.liked = "0"
                let likedCount = (Int(charity?.like_count ?? "0") ?? 0)-1
                charity?.like_count = String(likedCount)
            }
            
            self.charityFollowArray?[index] = charity!
        }
        
        self.searchTableView.reloadData()
        
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

extension MySpaceDetails {
    
    @IBAction func showProcessingCharges(_ sender:UIButton) {
        
        self.view.endEditing(true)
        
        processingCharges.isHidden = false
        processingCharges.layer.cornerRadius = 10
        
        
        guard let amount = amountText.text else {
            return
        }
        
        let amountWithoutDollar = amount.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard Double(amountWithoutDollar) != 0 else {
            return
        }
        
        let processingValue = self.calculatePercentage(value: Double(amountWithoutDollar) ?? 0,percentageVal: 1)
        
        let amountWithProcessingValue = (Double(amountWithoutDollar) ?? 0) + processingValue
        
        let merchantChargesValue = self.calculatePercentage(value: amountWithProcessingValue ,percentageVal: 2.9) + 0.30
        
        let totalAmount = amountWithProcessingValue + merchantChargesValue

        processingCharges.donationAmountValue.text = "$ "+amountWithoutDollar
        processingCharges.processingFeeValue.text = "$ "+String(format: "%.2f", processingValue)
        processingCharges.merchantChargesValue.text = "$ "+String(format: "%.2f", merchantChargesValue)
        processingCharges.totalAmountValue.text = "$ "+String(format: "%.2f", totalAmount)

        self.view.addSubview(processingCharges)
    
        processingCharges.closeBtn.addTarget(self, action: #selector(hideProcessingCharges), for: .touchUpInside)
    }
    
    @objc func hideProcessingCharges() {
        processingCharges.isHidden = true
        processingCharges.removeFromSuperview()
    }
    
}

//extension MySpaceDetails: PayPalPaymentDelegate {
//    
//    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
//        paymentViewController.dismiss(animated: true) { () -> Void in
//            print("and Dismissed")
//        }
//        print("Payment cancel")
//    }
//    
//    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
//        paymentViewController.dismiss(animated: true) { () -> Void in
//            print("and done")
//        }
//        print("Paymane is going on")
//    }
//    
//    
//    func acceptCreditCards() -> Bool {
//        return self.payPalConfig.acceptCreditCards
//    }
//  
//    func setAcceptCreditCards(acceptCreditCards: Bool) {
//        self.payPalConfig.acceptCreditCards = self.acceptCreditCards()
//    }
//
//    
//    func configurePaypal(strMarchantName:String) {
//        
//        // Set up payPalConfig
//        payPalConfig.acceptCreditCards = true
//        
//        payPalConfig.merchantName = strMarchantName
//        
//        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full") //NSURL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
//        
//        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
//        
//        payPalConfig.languageOrLocale = NSLocale.preferredLanguages[0]
//        
//        payPalConfig.payPalShippingAddressOption = .payPal;
//        
//        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")
//        
//        PayPalMobile.preconnect(withEnvironment: environment)
//        
//    }
//    
//    //Start Payment for selected shopping items
//
//    func goforPayNow(merchantCharge:String?, processingCharge:String?, totalAmount:String?, strShortDesc:String?, strCurrency:String?) {
//
//        var subtotal : NSDecimalNumber = 0
//
//        var merchant : NSDecimalNumber = 0
//
//        var processing : NSDecimalNumber = 0
//
//        subtotal = NSDecimalNumber(string: totalAmount)
//
//        // Optional: include payment details
//        if (merchantCharge != nil) {
//            merchant = NSDecimalNumber(string: merchantCharge)
//        }
//
//        if (processingCharge != nil) {
//            processing = NSDecimalNumber(string: processingCharge)
//        }
//
//        var description = strShortDesc
//
//        if (description == nil) {
//            description = ""
//        }
//        
//        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: merchant, withTax: processing)
//        
//        let total = subtotal.adding(merchant).adding(processing)
//
//        let payment = PayPalPayment(amount: total, currencyCode: strCurrency!, shortDescription: selectedCharity?.name ?? description!, intent: .sale)
//            
//        payment.items = [PayPalItem(name: selectedCharity?.name ?? "", withQuantity: 1, withPrice: NSDecimalNumber(string: totalAmount), withCurrency: "USD", withSku: "")]
//
//        payment.paymentDetails = paymentDetails
//        self.payPalConfig.acceptCreditCards = self.acceptCreditCards();
//
//        if self.payPalConfig.acceptCreditCards == true {
//            print("We are able to do the card payment")
//        }
//        
//        if (payment.processable) {
//            let objVC = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
//            self.present(objVC!, animated: true, completion: { () -> Void in
//                print("Paypal Presented")
//            })
//        }
//        else {
//            print("Payment not processalbe: \(payment)")
//        }
//
//    }
//    
//}
// MARK: - BTAppSwitch Delegate Method
extension MySpaceDetails: BTAppSwitchDelegate {
    
    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
        showLoadingUI()
        NotificationCenter.default.addObserver(self, selector: #selector(hideLoadingUI), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
        hideLoadingUI()
    }

    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {

    }

    // MARK: - Private methods

    func showLoadingUI() {
        // ...
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    //    MARK: - Private Methods
    @objc func hideLoadingUI() {
        MBProgressHUD.hide(for: self.view, animated: true)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        
    }
}

// MARK: - BT View Controller Presenting Delegate Method
extension MySpaceDetails: BTViewControllerPresentingDelegate {
    /*!
     @brief The payment driver requires dismissal of a view controller.
     
     @discussion Your implementation should dismiss the viewController, e.g. via
     `dismissViewControllerAnimated:completion:`
     
     @param driver         The payment driver
     @param viewController The view controller to be dismissed
     */
    @available(iOS 2.0, *)
    public func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
            viewController.dismiss(animated: true, completion: nil)
    }
    
    /*!
     @brief The payment driver requires presentation of a view controller in order to proceed.
     
     @discussion Your implementation should present the viewController modally, e.g. via
     `presentViewController:animated:completion:`
     
     @param driver         The payment driver
     @param viewController The view controller to present
     */
    @available(iOS 2.0, *)
    public func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
}

