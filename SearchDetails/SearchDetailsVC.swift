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
//import Braintree
import MBProgressHUD
import WebKit
import SafariServices
//import BraintreeDropIn

class SearchDetailsVC: BaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITabBarDelegate,UITextFieldDelegate,WKNavigationDelegate,WKScriptMessageHandler, WKUIDelegate, SFSafariViewControllerDelegate{
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
    weak var payDelegate: PaymentDelegate?
    var webView: WKWebView!
    var webViewContainer: UIView!
    var backButton: UIButton!
    @IBOutlet var continuePaymentBTn : UIButton!

    var selectedCharity:charityListArray? = nil

    var processingCharges = ProcessingChargesView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))

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
        
     
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
     
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "dismissWebView")
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.preferences.javaScriptEnabled = true
        self.webView = WKWebView(frame: self.view.frame, configuration: configuration)
       
        self.webView.navigationDelegate = self
        self.webView?.uiDelegate = self
       
        // Create a UIBarButtonItem with the title "Back"



       
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
    @objc func backButtonTapped() {
        if webView.canGoBack {
            webView.goBack()
        }
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
    
    func donateToCharity() {
        // Display the message on the screen
       

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Perform your asynchronous task

            if let data = UserDefaults.standard.data(forKey: "people"),
               let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
                let userID = myPeopleList.userID
                let charityID = self.charityList?.id ?? ""

                let postDict = ["user_id": userID, "charity_id": charityID]

                let iDonateTransString = String(format: URLHelper.iDonateTrans)
                WebserviceClass.sharedAPI.performRequest(type: [String: String].self, urlString: iDonateTransString, methodType: .post, parameters: postDict, success: { (response) in
                    // Hide loading indicator
               
                    MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
                    print("RESPONSE",response)

                    if let url = response["url"], let paymentURL = URL(string: url) {
                        // Initialize the WKWebView if not already done
                       

                        let safariViewController = SFSafariViewController(url: paymentURL)
                        safariViewController.delegate = self
                        self.present(safariViewController, animated: true, completion: nil)
                    } else {
                        print("Error: Invalid payment URL")
                    }
                    
                }) { (error) in
                    // Hide loading indicator
                    MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)

                    // Handle error if API call fails
                    print("Error: \(error)")
                    // You may display an error message to the user if needed
                }
            }
        }
    }


    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Extract the current URL of the web view
        if let currentURL = webView.url {
            // Analyze the URL to determine the payment status
            let payButtonScript = "document.getElementById('payButton').onclick = function() { window.webkit.messageHandlers.dismissWebView.postMessage('dismissWebView'); }"
            webView.evaluateJavaScript(payButtonScript, completionHandler: nil)
            print(webView.url)
            
            // Check if the URL contains the success message
            if currentURL.absoluteString.contains("donation_payment_show_successfull_msg") {
                // Dismiss the web view
                dismissWebView()

            }
            if currentURL.absoluteString.contains("donation_payment_cancel_payment"){
                dismissWebView()
                let alertController = UIAlertController(title: "Payment Cancelled", message: "Your donation payment has been cancelled.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
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
    // MARK: - Dismissal

      @objc func dismissWebView() {
          webView.isHidden = true
          blurView.removeFromSuperview()
          webView.navigationDelegate = nil
          // Perform additional actions if needed after dismissing the web view
      }
    // MARK: - WKScriptMessageHandler

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody = message.body as? String, messageBody == "dismissWebView" {
            dismissWebView()
        }
    }

    
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



class searchDetailsCell:UICollectionViewCell
{
    @IBOutlet var lbl_title: UILabel!
    @IBOutlet var img_view: UIImageView!
    
}
