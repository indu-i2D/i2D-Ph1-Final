//
//  SearchDetailsVC.swift
//  iDonate
//
//  Created by Im043 on 16/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import SideMenu
import AlamofireImage
import Alamofire
import TKFormTextField
import Braintree
import MBProgressHUD
import BraintreeDropIn

class SearchDetailsVC: BaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITabBarDelegate,UITextFieldDelegate {
    var charityList:charityListArray?
    let browseList = ["Leadership & Team","Values","Impact","Contact"]
    @IBOutlet var browseCollectionList: UICollectionView!
    @IBOutlet var notificationTabBar: UITabBar!
    @IBOutlet var headerLBL: UILabel!
    @IBOutlet var adderssLbl: UILabel!
    @IBOutlet var likeBTN: UIButton!
    @IBOutlet var followBTn: UIButton!
    @IBOutlet var donateBTn: UIButton!
    @IBOutlet var logoIMage: UIImageView!
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var cancelBtn : UIButton!
    @IBOutlet var amountText: TKFormTextField!
    var charityLikeResponse :  CharityLikeModel?
    var followResponse :  FollowModel?
    var userID:String = ""
    var donateFlag:Bool = false
    weak var payDelegate: paymentDelegate?
    
    @IBOutlet var continuePaymentBTn : UIButton!

    var selectedCharity:charityListArray? = nil

    var processingCharges = ProcessingChargesView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
    
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
        
        if(iDonateClass.hasSafeArea) {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        }else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        updateDetails()
        
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
    
    func updateDetails() {
        
        headerLBL.text = charityList!.name
        adderssLbl.text = charityList!.street!+","+charityList!.city!
        let likeString = charityList!.like_count! + " Likes"
        likeBTN.setTitle(likeString, for: .normal)
        let placeholderImage = UIImage(named: "defaultImageCharity")!
        
        if charityList?.logo != nil {
            let url = URL(string: charityList!.logo!)!
            logoIMage.af.setImage(withURL: url, placeholderImage: placeholderImage)
        } else {
            logoIMage.image = placeholderImage
        }
        
        if(charityList!.followed == "0"){
            followBTn.isSelected = false
            followBTn.setTitle("Follow", for: .normal)
        } else {
            followBTn.isSelected = true
            followBTn.setTitle("Following", for: .normal)
        }
        
        if(charityList!.liked == "0") {
            likeBTN.isSelected = false
        } else {
            likeBTN.isSelected = true
        }
    }
    
    @objc func backAction(_sender:UIButton)  {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func likeAction(_ sender:UIButton) {
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            var likeCount:String = ""
            userID = myPeopleList.userID
            
            if(sender.isSelected){
                sender.isSelected = false
                likeCount = "0"
            } else {
                likeCount = "1"
                sender.isSelected = true
            }
            
            charityLikeAction(like: likeCount, charityId: charityList!.id!)
        }
        else{
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
    
    @objc func cancelView(recognizer: UITapGestureRecognizer) {
        self.view .endEditing(true)
    }
    
    @IBAction func cancelAction(_ sender:UIButton){
        blurView .removeFromSuperview()
    }
    
    @IBAction func followAction(_ sender:UIButton) {
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            // Joe 10
            var follow:String = ""
            if(sender.isSelected)
            {
                sender.isSelected = false
                follow = "0"
            }
            else
            {
                follow = "1"
                sender.isSelected = true
            }
            let postDict = ["user_id":myPeopleList.userID,"token":myPeopleList.token,"charity_id":charityList?.id,"status":follow]
            let charityFollowUrl = String(format: URLHelper.iDonateCharityFollow)
            
            WebserviceClass.sharedAPI.performRequest(type: FollowModel.self, urlString: charityFollowUrl, methodType:  HTTPMethod.post, parameters: postDict as Parameters, success: { (response) in
                self.followResponse = response
                self.fellowResponse(follow: follow)
                print("Result: \(String(describing: response))")                     // response serialization result
                
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
    
    @IBAction func donateAction(_ sender:UIButton)  {
        
        self.amountText.text = "$10"
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
    
    fileprivate func donateToCharity() {
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
            
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            let urlString = "\(URLHelper.baseURL)braintree_client_token"

            let url = URL(string: urlString)!
            
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")

            AF.request(request).responseJSON {
                (response) in
                
                switch response.result {
                case .success(let value) :
                    let drop =  BTDropInRequest()
                    drop.vaultManager = true
                    drop.paypalDisabled = false
                    drop.cardDisabled = false
                    drop.payPalRequest?.currencyCode = "$"
                    print(drop)
                    let amount = self.amountText.text?.replacingOccurrences(of: "$", with: "")
                    
                    let amountWithoutDollar = amount!.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    guard Double(amountWithoutDollar) != 0 else {
                        return
                    }
                    
                    let processingValue = self.calculatePercentage(value: Double(amountWithoutDollar) ?? 0,percentageVal: 1)
                    
                    let amountWithProcessingValue = (Double(amountWithoutDollar) ?? 0) + processingValue
                    
                    let merchantChargesValue = self.calculatePercentage(value: amountWithProcessingValue ,percentageVal: 2.9) + 0.30
                    
                    let totalAmount = amountWithProcessingValue + merchantChargesValue
                                
                    let dropIn = BTDropInController(authorization: "\(value)", request: drop)
                    { (controller, result, error) in
                        if (error != nil) {
                            print("ERROR")
                            MBProgressHUD.hide(for: self.view, animated: true)

                        } else if (result?.isCancelled == true) {
                            print("CANCELLED")
                            MBProgressHUD.hide(for: self.view, animated: true)
                        } else if let result = result {
                            
                            if let data = UserDefaults.standard.data(forKey: "people"),
                                let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
                                print(myPeopleList.name)
                                
                                MBProgressHUD.showAdded(to: self.view, animated: true)

                                let postDict: Parameters = ["user_id":myPeopleList.userID,
                                                            "token":myPeopleList.token,
                                                            "charity_id":self.charityList?.id ?? "",
                                                            "charity_name": self.charityList?.name ?? "",
                                                            "transaction_id":result.paymentMethod?.nonce ?? "",
                                                            "amount":amount,
                                                            "payment_type": result.paymentMethod?.type ?? "",
                                                            "status":"approved",
                                                            "merchant_charges":merchantChargesValue,
                                                            "processing_fee":processingValue]
                                
                                let paymentUrl = String(format: URLHelper.iDonatePayment)
                                
                                self.blurView.removeFromSuperview()

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
                                    
                                }
                            }
                            
                            // Use the BTDropInResult properties to update your UI
                            // result.paymentOptionType
                            // result.paymentMethod
                            // result.paymentIcon
                            // result.paymentDescription
                        }
                        controller.dismiss(animated: true, completion: nil)
                    }
                    
                    self.present(dropIn!, animated: true, completion: nil)

                case .failure(let error):
                    print(error)
                }
            }
                        
        }
    }
    
    @IBAction func paymentAction(_ sender:UIButton){
        
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            donateToCharity()
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        donateFlag = true
        textField.becomeFirstResponder()
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    
    func charityLikeAction(like:String,charityId:String) {
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            // Joe 10
            let postDict = ["user_id":myPeopleList.userID,"token":myPeopleList.token,"charity_id":charityId,"status":like]
            let charityLikeUrl = String(format: URLHelper.iDonateCharityLike)
            
            WebserviceClass.sharedAPI.performRequest(type: CharityLikeModel.self, urlString: charityLikeUrl, methodType:  HTTPMethod.post, parameters: postDict as Parameters, success: { (response) in
                self.charityLikeResponse = response
                print("Result: \(String(describing: response))")                     // response serialization result
                self.charityResponse(like: like)
                
            }) { (response) in
                
            }
        }
        else {
            
        }
    }
    
    func charityResponse(like:String) {
        if(self.charityLikeResponse?.status == 1){
            let charityCOunt = self.charityLikeResponse?.likecount
            let likeString = charityCOunt!.likeCount! + " Likes"
            likeBTN.setTitle(likeString, for: .normal)
        }
    }
    
    func fellowResponse(follow:String) {
        if(self.followResponse?.status == 1){
            if(follow == "1"){
                self.followBTn.setTitle("Following", for: .normal)
            }
            else{
                self.followBTn.setTitle("Follow", for: .normal)
            }
        }
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
        if(item.tag == 0)
        {
            UserDefaults.standard.set(0, forKey: "tab")
            self.navigationController?.pushViewController(vc!, animated: false)
        }
            
            
            
            
        else
        {
            UserDefaults.standard.set(1, forKey: "tab")
            self.navigationController?.pushViewController(vc!, animated: false)
            
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

extension SearchDetailsVC {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return browseList.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchDetailsCell", for: indexPath)as! searchDetailsCell
        cell.lbl_title.text = browseList[indexPath.row]
        cell.img_view.image = UIImage(named: browseList[indexPath.row])
        return cell
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  20
        let collectionViewSize = collectionView.frame.size.width-padding
        return CGSize(width: collectionViewSize/2.0, height:collectionViewSize/2.0)
    }
}

extension SearchDetailsVC {
    
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

//extension SearchDetailsVC: PayPalPaymentDelegate {
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
extension SearchDetailsVC: BTAppSwitchDelegate {
    
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
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    //    MARK: - Private Methods
    @objc func hideLoadingUI() {
        MBProgressHUD.hide(for: self.view, animated: true)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

// MARK: - BT View Controller Presenting Delegate Method
extension SearchDetailsVC: BTViewControllerPresentingDelegate {
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



class searchDetailsCell:UICollectionViewCell
{
    @IBOutlet var lbl_title: UILabel!
    @IBOutlet var img_view: UIImageView!
    
}
