//
//  AboutVC.swift
//  iDonate
//
//  Created by Im043 on 04/07/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import WebKit
import SideMenu
import Alamofire

class AboutVC: BaseViewController,WKNavigationDelegate,UITabBarDelegate {
    @IBOutlet var notificationTabBar: UITabBar!
    @IBOutlet weak var aboutText: WKWebView!
    @IBOutlet weak var header: UILabel!
    var headerString:String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        aboutText.navigationDelegate = self
        
        if(iDonateClass.hasSafeArea) {
            menuBtn.frame = CGRect(x: 10, y: 50, width: 24, height: 24)
        }
        else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(menuAction(_sender:)), for: .touchUpInside)
        menuBtn.setImage(UIImage(named: "menu"), for: .normal)

        self.view .addSubview(menuBtn)
        
        if(headerString == "About i2~Donate") {
            let urlString = URLHelper.getAboutUrl
            let requestObj = URLRequest(url:URL(string: urlString)!)
            self.aboutText.load(requestObj)
            header.text = headerString
        } else {
            let urlString = URLHelper.getHelpUrl
            let requestObj = URLRequest(url:URL(string: urlString)!)
            self.aboutText.load(requestObj)
            header.text = headerString
        }
        
        self.aboutText.isOpaque = false
        self.aboutText.backgroundColor = UIColor.clear
        self.aboutText.scrollView.backgroundColor = UIColor.clear
        
        // Do any additional setup after loading the view.
    }
    
    @objc func menuAction(_sender:UIButton) {
        // let menuLeftNavigationController = uis(rootViewController:MenuVC )
        // UISideMenuNavigationController is a subclass of UINavigationController, so do any additional configuration
        // of it here like setting its viewControllers. If you're using storyboards, you'll want to do something like:
        let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        let menu = SideMenuNavigationController(rootViewController: menuLeftNavigationController)
        menu.setNavigationBarHidden(true, animated: false)
        menu.leftSide = true
        menu.statusBarEndAlpha = 0
        menu.menuWidth = screenWidth
        
        present(menu, animated: true, completion: nil)
        
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
        if(item.tag == 0){
            UserDefaults.standard.set(0, forKey: "tab")
            self.navigationController?.pushViewController(vc!, animated: false)
        }
        else{
            UserDefaults.standard.set(1, forKey: "tab")
            self.navigationController?.pushViewController(vc!, animated: false)
        }
    }
    
    @objc func backTapped() {
        if aboutText.canGoBack{
            self.aboutText.goBack()
        } else {
            menuBtn.removeTarget(self, action: #selector(backTapped), for: .touchUpInside)
            menuBtn.addTarget(self, action: #selector(menuAction(_sender:)), for: .touchUpInside)
            menuBtn.setImage(UIImage(named: "menu"), for: .normal)
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

extension AboutVC:WKUIDelegate {
    /**
     - Sent if a web view failed to load a frame.
     - Parameters:
     - webView: The web view that failed to load a frame.
     - error: The error that occurred during loading.
     */
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        //    PLProgressHUD.sharedInstance.hideProgressHUD()
        let nserror = error as NSError
//        if !isViewDisappear {
//            // AWS Analytics: Error case
//            //      PLAnalytics.sharedInstance.logErrorEvent("WebView Failed to load")
//            showErrorAlert(title: "Error", message: "Cannot load \(self.title!)")
//        }
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error){
        print(error.localizedDescription)
//        showErrorAlert(title:"network_error_title", message: "network_error_prompt1")
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    /**
     - Sent after a web view starts loading a frame.
     - Parameter webView: The web view that has begun loading a new frame.
     */
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // webViewDidStartLoad
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //         PLProgressHUD.sharedInstance.hideProgressHUD()
        webView.evaluateJavaScript("document.documentElement.style.webkitUserSelect='none'") { (_, _) in
            //webkitUserSelect Event
        }
        webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none'") { (_, _) in
            //webkitTouchCallout Event
        }
    }
    
    /**
     - Sent before a web view begins loading a frame.
     - Parameters:
     - webView: The web view that is about to load a new frame.
     - request: The content location.
     - navigationType: The type of user action that started the load request.
     - Returns: true if the web view should begin loading content; otherwise, false .
     */
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        var action: WKNavigationActionPolicy?
        
        defer {
            decisionHandler(action ?? .allow)
        }
        
        guard let url = navigationAction.request.url else { return }
        
        print(url)
                
        if url.absoluteString.contains("i2-Donate%20Terms%20and%20Conditions.html") {
            self.menuBtn.setImage(#imageLiteral(resourceName: "back"), for: .normal)
            menuBtn.removeTarget(self, action: #selector(menuAction(_sender:)), for: .touchUpInside)
            self.menuBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        } else if  url.absoluteString.contains("i2-Donate%20Privacy%20Policy.html") {
            menuBtn.removeTarget(self, action: #selector(backTapped), for: .touchUpInside)
            self.menuBtn.setImage(#imageLiteral(resourceName: "back"), for: .normal)
            self.menuBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        } else if url.absoluteString.contains("i2D-App-About.html") {
            menuBtn.removeTarget(self, action: #selector(backTapped), for: .touchUpInside)
            self.menuBtn.setImage(#imageLiteral(resourceName: "menu"), for: .normal)
            self.menuBtn.addTarget(self, action: #selector(menuAction(_sender:)), for: .touchUpInside)
        }
        
    }
}
