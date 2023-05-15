//
//  TermsAndConditionsViewController.swift
//  iDonate
//
//  Created by Satheesh k on 22/06/20.
//  Copyright © 2020 Im043. All rights reserved.
//

import MBProgressHUD
import UIKit
import WebKit

class TermsAndConditionsViewController: BaseViewController {
    
    @IBOutlet weak var webView : WKWebView!
    @IBOutlet weak var header: UILabel!
    
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
        
        // Do any additional setup after loading the view.
        
       /* let url = URL(string: "https://prod.i2-donate.com/i2D-Publish-Docs/i2-Donate%20Terms%20and%20Conditions.html") //URL(string: "https://admin.i2-donate.com/about_us.html) */
        let urlString = URLHelper.getTermsAndConditionUrl
        let requestObj = URLRequest(url:URL(string: urlString)!)
        self.webView.load(requestObj)
        
        header.text = "Terms and Conditions"
        
        self.webView.isOpaque = false
        self.webView.backgroundColor = UIColor.clear
        self.webView.scrollView.backgroundColor = UIColor.clear
    }
    
    @objc func backAction(_sender:UIButton)  {
        self.navigationController?.popViewController(animated: true)
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
