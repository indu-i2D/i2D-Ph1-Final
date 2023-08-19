//
//  AppDelegate.swift
//  iDonate
//  Created by Im043 on 24/04/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKCoreKit
import Braintree
import GooglePlaces
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var paymentBTURLScheme = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        UserDefaults.standard.set(0, forKey: "tab")
        if let appDomain = Bundle.main.bundleIdentifier {
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
        UserDefaults.standard .set("", forKey: "latitude")
        UserDefaults.standard .set("", forKey: "longitude")
        
        if((UserDefaults.standard.value(forKey:"Intro")) == nil) || (UserDefaults.standard.value(forKey: "Intro") as! Bool ==  false) {
            let rootViewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "IntroVC") as? IntroVC
            constantFile.changepasswordBack = true
            let navigationController = UINavigationController(rootViewController: rootViewController!)
            navigationController.isNavigationBarHidden = true
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
        }
        else {
            let rootViewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
            constantFile.changepasswordBack = true
            let navigationController = UINavigationController(rootViewController: rootViewController!)
            navigationController.isNavigationBarHidden = true
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
        }
        
        GIDSignIn.sharedInstance().clientID = "720548689360-bff3jv2pbrrks74tear733584kcraf93.apps.googleusercontent.com"
    
//        PayPalMobile.initializeWithClientIds(forEnvironments:
//            [PayPalEnvironmentProduction: "AWs4124obWk3JoyH35_e5LUId1GB3gHpecIO__mppzT8-MkFmZeNt-9DcFDLHzN6dxfLpYYLGnKu0Vgw",
//            PayPalEnvironmentSandbox: "Ae7-40mniICmqZQEPOxH_ThAXlxE9CzqVapa6pdGWp9HbrELuSeYStvZZJYg3Y95qlxR3DLAtoy-Zbop"])
        
        //        TwitterLoginHelper.sharedInstance.twitterStartwith(consumerKey: "EnzTp5DQICdn3DzJ3rBNAioXL", consumerSecret: "ICASrwkV7PaBNmXHkgLXFBtVH4uGYfbOkFlv9JKGTvw0lyD3Bl")
        //
        paymentBTURLScheme = (Bundle.main.bundleIdentifier ?? "") + ".payments"
        
        BTAppSwitch.setReturnURLScheme(paymentBTURLScheme)
        print(paymentBTURLScheme)
            FBSDKCoreKit.ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
//        TWTRTwitter.sharedInstance().start(withConsumerKey:"xxxxxxxxxxxxxxxxxxxxx", consumerSecret:"ssabdavhjdafvdhjavdhjavdahjdvahdvahdvahjd")
        
        GMSPlacesClient.provideAPIKey("AIzaSyALvk4X-MXl0E7fOg2dELuOQfXfVwEmxhM")
        
        UserDefaults.standard.set("United States", forKey: "selectedname")
        UserDefaults.standard.set("US", forKey: "selectedcountry")
       
        
        
        return true
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        if url.scheme?.localizedCaseInsensitiveCompare(paymentBTURLScheme) == ComparisonResult.orderedSame {
            return BTAppSwitch.handleOpen(url, options: options)
        }
                
        return GIDSignIn.sharedInstance().handle(url)
        
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        UserDefaults.standard .set("", forKey: "latitude")
        UserDefaults.standard .set("", forKey: "longitude")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UserDefaults.standard .set("", forKey: "latitude")
        UserDefaults.standard .set("", forKey: "longitude")
    }


}

