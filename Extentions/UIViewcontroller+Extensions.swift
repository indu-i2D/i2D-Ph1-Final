//
//  UIViewcontroller+Extensions.swift
//  i2~Donate
//
//  Created by Satheesh k on 31/05/20.
//  Copyright © 2020 ImaginetVenture. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
//    func setBackGroundImage() {
//        self.view.addSubview(BaseBackGroundView(frame: screenFrame))
//    }
//
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func presentDetail(_ viewControllerToPresent: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)

        present(viewControllerToPresent, animated: false)
    }

    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)

        dismiss(animated: false)
    }
    
    //Calucate percentage based on given values
    public func calculatePercentage(value:Double,percentageVal:Double)->Double{
        let val = value * percentageVal
        return val / 100.0
    }
    
}


class PLAlertViewController: UIAlertController {
    
  // Clear Alert Window
  fileprivate lazy var alertWindow: UIWindow = {
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = PLAlertBackgroundViewController()
    window.backgroundColor = UIColor.clear
    return window
  }()
  
  /**   
   - parameter flag:       Pass true to animate the presentation; otherwise, pass false. The presentation is animated by default.
   - parameter completion: The closure to execute after the presentation finishes.
   */
  func show(animated flag: Bool = true, completion: (() -> Void)? = nil) {
    let alertVisisble = isalertViewVisible()
    
    if !alertVisisble, let rootViewController = alertWindow.rootViewController {
        
            alertWindow.makeKeyAndVisible()
            rootViewController.present(self, animated: flag, completion: completion)
    }
  }
  
  // Fix for bug in iOS 9 Beta 5 that prevents the original window from becoming keyWindow again
  deinit {
    alertWindow.isHidden = true
  }
  
  func anyAlertWindowIsActive() -> Bool {
    var isKeyActive = false
    for (_,element) in UIApplication.shared.windows.enumerated() {
      if element.rootViewController is PLAlertBackgroundViewController, element.isKeyWindow {
          isKeyActive = true
      }
    }
    return isKeyActive
  }

  func isalertViewVisible() -> Bool {
    if anyAlertWindowIsActive() {
    for (_,element) in UIApplication.shared.windows.enumerated() {
      if element.rootViewController is PLAlertBackgroundViewController {
        return true
        }
      }
    }
    else {
      return false
    }
    
    return false
  }

}

// In the case of view controller-based status bar style, make sure we use the same style for our view controller
private class PLAlertBackgroundViewController: UIViewController {
  
  fileprivate override var preferredStatusBarStyle : UIStatusBarStyle {
    return UIApplication.shared.statusBarStyle
  }
  
  fileprivate override var prefersStatusBarHidden : Bool {
    return UIApplication.shared.isStatusBarHidden
  }
  
}



import Foundation
import Security

// Constant Identifiers
let userAccount = "AuthenticatedUser"
let accessGroup = "SecuritySerivice"


/**
 *  User defined keys for new entry
 *  Note: add new keys for new secure item and use them in load and save methods
 */

let passwordKey = "KeyForPassword"

// Arguments for the keychain queries
let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

public class KeychainService: NSObject {

    /**
     * Exposed methods to perform save and load queries.
     */

    public class func savePassword(token: NSString) {
        self.save(service: passwordKey as NSString, data: token)
    }

    public class func loadPassword() -> NSString? {
        return self.load(service: passwordKey as NSString)
    }

    /**
     * Internal methods for querying the keychain.
     */

    private class func save(service: NSString, data: NSString) {
        let dataFromString: NSData = data.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)! as NSData

        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, dataFromString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])

        // Delete any existing items
        SecItemDelete(keychainQuery as CFDictionary)

        // Add the new keychain item
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }

    private class func load(service: NSString) -> NSString? {
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, kCFBooleanTrue, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])

        var dataTypeRef :AnyObject?

        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: NSString? = nil

        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? NSData {
                contentsOfKeychain = NSString(data: retrievedData as Data, encoding: String.Encoding.utf8.rawValue)
            }
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }

        return contentsOfKeychain
    }
}
