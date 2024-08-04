//
//  AboutVC.swift
//  i2-Donate
//


import UIKit
import WebKit
import SideMenu
import Alamofire

/**
 The `AboutVC` class displays information about the iDonate application. It loads content into a `WKWebView` and handles navigation within the web view. This class also manages the display of a side menu and handles tab bar interactions.

 - Note:
 This class is a subclass of `BaseViewController` and conforms to the `WKNavigationDelegate`, `UITabBarDelegate`, and `WKUIDelegate` protocols.
 */
class AboutVC: BaseViewController, WKNavigationDelegate, UITabBarDelegate {
    
    // MARK: - Outlets
    
    /// The tab bar for notifications.
    @IBOutlet var notificationTabBar: UITabBar!
    
    /// The web view displaying the about information.
    @IBOutlet weak var aboutText: WKWebView!
    
    /// The label displaying the header text.
    @IBOutlet weak var header: UILabel!
    
    // MARK: - Properties
    
    /// The string to be displayed in the header.
    var headerString: String?
    
    // MARK: - Lifecycle Methods
    
    /**
     Called after the controller's view is loaded into memory.
     Sets
     
     up the web view, the menu button, and loads the appropriate content based on `headerString`.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aboutText.navigationDelegate = self
        
        if iDonateClass.hasSafeArea {
            menuBtn.frame = CGRect(x: 10, y: 50, width: 24, height: 24)
        } else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(menuAction(_:)), for: .touchUpInside)
        menuBtn.setImage(UIImage(named: "menu"), for: .normal)
        self.view.addSubview(menuBtn)
        
        let urlString: String
        if headerString == "About i2~Donate" {
            urlString = URLHelper.getAboutUrl
        } else {
            urlString = URLHelper.getHelpUrl
        }
        
        if let url = URL(string: urlString) {
            let requestObj = URLRequest(url: url)
            self.aboutText.load(requestObj)
            header.text = headerString
        }
        
        self.aboutText.isOpaque = false
        self.aboutText.backgroundColor = UIColor.clear
        self.aboutText.scrollView.backgroundColor = UIColor.clear
    }
    
    // MARK: - Menu Action
    
    /**
     Handles the action when the menu button is tapped.
     Presents the side menu.
     
     - Parameter sender: The button that triggered this action.
     */
    @objc func menuAction(_ sender: UIButton) {
        if let menuLeftNavigationController = storyboard?.instantiateViewController(withIdentifier: "MenuVC") as? MenuVC {
            let menu = SideMenuNavigationController(rootViewController: menuLeftNavigationController)
            menu.setNavigationBarHidden(true, animated: false)
            menu.leftSide = true
            menu.statusBarEndAlpha = 0
            menu.menuWidth = UIScreen.main.bounds.width
            present(menu, animated: true, completion: nil)
        }
    }
    
    // MARK: - Tab Bar Delegate
    
    /**
     Called when a tab bar item is selected.
     Pushes the appropriate view controller based on the selected tab.
     
     - Parameter tabBar: The tab bar that is the source of the event.
     - Parameter item: The tab bar item that was selected.
     */
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController {
            UserDefaults.standard.set(item.tag, forKey: "tab")
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    // MARK: - Back Button Action
    
    /**
     Handles the action when the back button is tapped in the web view.
     Navigates back if possible, otherwise resets the menu button to its original action.
     */
    @objc func backTapped() {
        if aboutText.canGoBack {
            aboutText.goBack()
        } else {
            menuBtn.removeTarget(self, action: #selector(backTapped), for: .touchUpInside)
            menuBtn.addTarget(self, action: #selector(menuAction(_:)), for: .touchUpInside)
            menuBtn.setImage(UIImage(named: "menu"), for: .normal)
        }
    }
}
// MARK: - WKUIDelegate

extension AboutVC: WKUIDelegate {
    
    
    /**
     Called if a web view failed to load a frame.
     
     - Parameter webView: The web view that failed to load a frame.
     - Parameter error: The error that occurred during loading.
     */
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // Handle the error, e.g., show an alert to the user
    }
    
    /**
     Called if a web view failed to load a provisional navigation.
     
     - Parameter webView: The web view that failed to load.
     - Parameter error: The error that occurred during loading.
     */
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
        // Handle the error, e.g., show an alert to the user
    }
    
    /**
     Creates a new web view.
     
     - Parameters:
     - webView: The web view requesting the new view.
     - configuration: The configuration to use when creating the new view.
     - navigationAction: The navigation action causing the new view to be created.
     - windowFeatures: The window features requested by the new view.
     - Returns: The new web view, or nil to cancel the navigation.
     */
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    /**
     Called after a web view starts loading a frame.
     
     - Parameter webView: The web view that has begun loading a new frame.
     */
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Handle the start of the navigation
    }
    
    /**
     Called after a web view finishes loading a frame.
     
     - Parameter webView: The web view that has finished loading.
     */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.style.webkitUserSelect='none'", completionHandler: nil)
        webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none'", completionHandler: nil)
    }
    
    /**
     Decides whether to allow or cancel a navigation action.
     
     - Parameters:
     - webView: The web view making the request.
     - navigationAction: The navigation action requesting permission.
     - decisionHandler: The decision handler to call with the decision.
     */
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var action: WKNavigationActionPolicy = .allow
        
        defer {
            decisionHandler(action)
        }
        
        guard let url = navigationAction.request.url else { return }
        
        print(url)
        
        if url.absoluteString.contains("i2-Donate%20Terms%20and%20Conditions.html") || url.absoluteString.contains("i2-Donate%20Privacy%20Policy.html") {
            menuBtn.setImage(#imageLiteral(resourceName: "back"), for: .normal)
            menuBtn.removeTarget(self, action: #selector(menuAction(_:)), for: .touchUpInside)
            menuBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        } else if url.absoluteString.contains("i2D-App-About.html") {
            menuBtn.removeTarget(self, action: #selector(backTapped), for: .touchUpInside)
            menuBtn.setImage(#imageLiteral(resourceName: "menu"), for: .normal)
            menuBtn.addTarget(self, action: #selector(menuAction(_:)), for: .touchUpInside)
        }
    }
}
