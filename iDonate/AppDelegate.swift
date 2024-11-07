//
//  AppDelegate.swift
//  i2-Donate


import UIKit
import GoogleSignIn
import FBSDKCoreKit
import GooglePlaces
import IQKeyboardManagerSwift
import Alamofire
import MBProgressHUD
import SwiftyJSON

/// The main application delegate class for the iDonate app.
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var paymentBTURLScheme = ""
    
    /// Called when the application has finished launching.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Enable IQKeyboardManager to manage keyboard behavior.
        IQKeyboardManager.shared.enable = true

        // Set default tab and reset UserDefaults.
        UserDefaults.standard.set(0, forKey: "tab")
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
        
        // Set default values for latitude and longitude.
        UserDefaults.standard.set("", forKey: "latitude")
        UserDefaults.standard.set("", forKey: "longitude")
        
        // Configure Google Sign-In with the client ID.
        GIDSignIn.sharedInstance().clientID = "720548689360-bff3jv2pbrrks74tear733584kcraf93.apps.googleusercontent.com"
        
        // Set the payment URL scheme.
        paymentBTURLScheme = (Bundle.main.bundleIdentifier ?? "") + ".payments"
        
        // Provide Google Places API key.
        GMSPlacesClient.provideAPIKey("AIzaSyALvk4X-MXl0E7fOg2dELuOQfXfVwEmxhM")
        
        // Set default country and country code.
        UserDefaults.standard.set("United States", forKey: "selectedname")
        UserDefaults.standard.set("US", forKey: "selectedcountry")
       
        // Fetch server configuration.
        self.fetchServerDto()
        
        return true
    }
    
    /// Handles URL opening for various purposes including deep linking.
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "https", url.host == " .i2-donate.com" {
            if let path = url.pathComponents.last,
               path == "/i2D_DPS_Procs/payment/donation_payment_show_successfull_msg",
               let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
                for item in queryItems {
                    if item.name == "msg", let message = item.value {
                        handleDeepLink(withMessage: message)
                        return true
                    }
                }
            }
        } else {
            ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )
            
            // Uncomment if using Braintree for payment processing.
            // if url.scheme?.localizedCaseInsensitiveCompare(paymentBTURLScheme) == ComparisonResult.orderedSame {
            //     return BTAppSwitch.handleOpen(url, options: options)
            // }
            
            return GIDSignIn.sharedInstance().handle(url)
        }
        return false
    }
    
    /// Handles deep linking to show a message.
    func handleDeepLink(withMessage message: String) {
        let alertController = UIAlertController(title: "Deep Linking", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }

    /// Called when the application is about to become inactive.
    func applicationWillResignActive(_ application: UIApplication) {
        UserDefaults.standard.set("", forKey: "latitude")
        UserDefaults.standard.set("", forKey: "longitude")
    }

    /// Called when the application enters the background.
    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    /// Called when the application will enter the foreground.
    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    /// Called when the application becomes active.
    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    /// Called when the application is about to terminate.
    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.standard.set("", forKey: "latitude")
        UserDefaults.standard.set("", forKey: "longitude")
    }

    /// Redirects the user to the appropriate home screen based on their onboarding status.
    func redirectHome() {
        if (UserDefaults.standard.value(forKey:"Intro") == nil) || (UserDefaults.standard.value(forKey: "Intro") as! Bool ==  false) {
            let rootViewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "IntroVC") as? IntroVC
            constantFile.changepasswordBack = true
            let navigationController = UINavigationController(rootViewController: rootViewController!)
            navigationController.isNavigationBarHidden = true
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
        } else {
            let rootViewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
            constantFile.changepasswordBack = true
            let navigationController = UINavigationController(rootViewController: rootViewController!)
            navigationController.isNavigationBarHidden = true
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
        }
    }

    /// Fetches server configuration from Google Sheets.
    func fetchServerDto() {
        // MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        let sheetApiKey = "AIzaSyDQzTsnTRgYvCDfEUm1ac0rQgHZbiiB_ew"
        let sheetID = "1O-8LD2wcWDqBiKw9I3QDI0JuwWCVrenyN_IzVHVMd4E"
        let sheetTabName = "i2D-Dev"
        let url = "https://sheets.googleapis.com/v4/spreadsheets/" + sheetID + "/values/" + sheetTabName + "?key=" + sheetApiKey
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        AF.request(request).responseString { response in
            // MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            switch response.result {
            case .success(_):
                if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                        print(JSON(json))
                        let utf8Data = String(decoding: data, as: UTF8.self).data(using: .utf8)
                        let responseDecoded = try JSONDecoder().decode(JSON.self, from: utf8Data!)
                        debugPrint("responseDecoded", responseDecoded)
                        let jsonObj = responseDecoded
                        let jsonArray = jsonObj["values"].arrayValue
                        for item in jsonArray {
                            debugPrint("item ?? ", item)
                            let array = item.arrayValue
                            if array.count == 0 {
                                continue
                            }
                            debugPrint("array", array)
                            if array[0] == "Server_URL" {
                                SERVER_URL = array[1].stringValue + "/"
                                let imgUrl = SERVER_URL.replacingOccurrences(of: "i2d_mob/webservice", with: "")
                                UPLOAD_URL = imgUrl
                            }
                            if array[0] == "About_URL" {
                                ABOUT_URL = array[1].stringValue
                            }
                            if array[0] == "Help_URL" {
                                HELP_URL = array[1].stringValue
                            }
                            if array[0] == "Privacy_URL" {
                                PRIVACY_URL = array[1].stringValue
                            }
                            if array[0] == "TC_URL" {
                                TERM_COND_URL = array[1].stringValue
                            }
                        }
                        self.redirectHome()
                    } catch let error as NSError {
                        print(error)
                    }
                }
            case .failure(let error):
                print("Error:", error)
            }
        }
    }
}

/// An extension to add a bottom border to a UITextField.
extension UITextField {
    /// Adds a bottom border to the text field.
    func addBottomBorder() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
        bottomLine.backgroundColor = UIColor.darkGray.cgColor
        borderStyle = .none
        layer.addSublayer(bottomLine)
    }
}
