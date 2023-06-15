//
//  TwitterWebViewController.swift
//  iDonate
//
//  Created by Satheesh k on 20/06/20.
//  Copyright © 2020 Im043. All rights reserved.
//


import MBProgressHUD
import UIKit
import WebKit

enum WebViewMode {
    case urlRequestMode
    case pdfViewerMode
}

protocol LinkedInTokenHandler {
    func receivedToken(code:String)
    func receivedNoToken(message:String)
}
protocol TwitterTokenHandler {
    func receivedOAuthToken(url:URL)
    func receivedNoToken()
}
protocol FacebookTokenHandler {
    func receivedOAuthToken(code:String)
    func receivedNoToken()
}

enum social {
    case Twitter
    case Facebook
    case LinkedIn
}

/**
 # Web View Controller
 
 - Provides the infrastructure for managing the views of your UIKit app.
 
 - This view controller display Privacy Policy, Terms & Conditions, Fueling Receipt in PDF format.
 */

class TwitterWebViewController: UIViewController,UIScrollViewDelegate,WKNavigationDelegate {
    
    @IBOutlet weak var webView : WKWebView!
    
    /// Main Frame
    let mainFrame:CGRect = UIScreen.main.bounds
    
    var twitterDelegate:TwitterTokenHandler?

    var loginType:social = .Twitter
    
    var header:String = "Twitter Sign in"
    
    /// Load URL
    var loadUrl:URL!
        
    /// Web View Mode
    var webViewMode:WebViewMode = .urlRequestMode
   
    
    // MARK: - UIViewController Life Cycle
    /**
     Main Method
     
     - Called after the view controller’s view has been loaded into memory.
     
     - Parameters: nil
     
     - Returns: nil
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadWebView()
        webView?.navigationDelegate = self
        webView?.uiDelegate = self
//        webView.loadHTMLString(, baseURL: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.scrollView.delegate = self
        
    }
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isTranslucent = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.webView != nil {
            self.webView?.stopLoading()
            self.webView?.navigationDelegate = nil
            self.webView?.scrollView.delegate = nil
//            webView.loadHTMLString(header, baseURL: nil)
        }
        twitterDelegate = nil
    }
   
    @IBAction  func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
   
    
    func loadWebView() {
        if let loadUrl = loadUrl {
            MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
            let requestObj = URLRequest(url: loadUrl)
            self.webView?.load(requestObj)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
     
   
               if scrollView.contentOffset.y < 0 {
                               scrollView.contentOffset.y = -40
                           }
                       if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
                           scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentSize.height - scrollView.frame.size.height), animated: false)
                       }
//        let scrollPoint = CGPoint(x: 0, y: webView.frame.height - webView.scrollView.contentSize.height )
//           webView.scrollView.setContentOffset(scrollPoint, animated: true)//Set false if you doesn't want animation
        }
    
    // MARK: - Receive Memory Warning
    /**
     - Sent to the view controller when the app receives a memory warning.
     - Your app never calls this method directly. Instead, this method is called when the system determines that the amount of available memory is low.
     - You can override this method to release any additional memory used by your view controller. If you do, your implementation of this method must call the super implementation at some point.
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Back Button Tapped Action
    @objc func backTapped(){
        // exitTermConditionID
        self.webView?.navigationDelegate = nil
        self.webView?.scrollView.delegate = nil
        
        //  PLProgressHUD.sharedInstance.hideProgressHUD()
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func closeButton() {
        // PLUtility.navigateToDashboardFrom(self)
    }
    
}

extension TwitterWebViewController:WKUIDelegate {
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
        showErrorAlert(title:"network_error_title", message: "network_error_prompt1")
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    
    /// Show AlertView
    func showErrorAlert(title: String, message: String){
        let alertController = PLAlertViewController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            // Save Allow
            self.backTapped()
        })
        alertController.addAction(ok)
        alertController.show()
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
        
        MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        
        if url.absoluteString.contains("twittersdk://") || url.absoluteString.contains("twitterkit"){
            action = .cancel
            twitterDelegate?.receivedOAuthToken(url: url)
            self.dismiss(animated: true, completion: nil)
        }
        else if url.absoluteString.contains("denial") {
            action = .cancel
            self.dismiss(animated: true, completion: nil)
        }
        
    }
}



extension WKWebView {
    class func clean() {
        guard #available(iOS 9.0, *) else {return}
        
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {
                    // intenionally unimplemented
                })
                #if DEBUG
                print("WKWebsiteDataStore record deleted:", record)
                #endif
            }
        }
    }
}
