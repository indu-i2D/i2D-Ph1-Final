//
//  TermsAndConditionsViewController.swift
//  i2-Donate
//

//

import MBProgressHUD
import UIKit
import WebKit

/// A view controller responsible for displaying the terms and conditions within a web view.
class TermsAndConditionsViewController: BaseViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var header: UILabel!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the back button
        if iDonateClass.hasSafeArea {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        menuBtn.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        self.view.addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        // Load terms and conditions URL
        let urlString = URLHelper.getTermsAndConditionUrl
        let requestObj = URLRequest(url: URL(string: urlString)!)
        self.webView.load(requestObj)
        
        // Set header text
        header.text = "Terms and Conditions"
        
        // Configure web view appearance
        self.webView.isOpaque = false
        self.webView.backgroundColor = UIColor.clear
        self.webView.scrollView.backgroundColor = UIColor.clear
    }
    
    // MARK: - Actions
    
    /// Handles back button tap action.
    ///
    /// - Parameter sender: The button that triggers the action.
    @objc func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
