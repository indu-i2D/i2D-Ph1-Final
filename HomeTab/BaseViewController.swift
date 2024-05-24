//
//  ViewController.swift
//  iDonate
//
//  Created by Im043 on 24/04/19.
//  © 2019 Im043. All rights reserved.
//

import UIKit

/// `BaseViewController`: A base class for view controllers in the iDonate application.
/// This class handles common setup and functionalities required across different view controllers.
class BaseViewController: UIViewController {
    
    /// A shared instance of `BaseViewController`.
    static let sharedAPI: BaseViewController = BaseViewController()
    
    /// Button for opening the side menu.
    let menuBtn = UIButton()
    
    /// Background image view for the view controller.
    var bgImage = UIImageView()
    
    /// Image view for the navigation bar logo.
    var navIMage = UIImageView()
    
    // Uncomment the following lines if using PayPal SDK integration:
    // var environment: String = PayPalEnvironmentNoNetwork {
    //     willSet(newEnvironment) {
    //         if newEnvironment != environment {
    //             PayPalMobile.preconnect(withEnvironment: newEnvironment)
    //         }
    //     }
    // }
    //
    // var payPalConfig = PayPalConfiguration()

    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the background image
        bgImage = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        bgImage.image = UIImage(named: "backgrounimage")
        self.view.addSubview(bgImage)
        self.view.sendSubviewToBack(bgImage)
        
        // Add the navigation bar image/logo
        addNavBarImage()
        
        // Print whether the device has a safe area or not
        print(iDonateClass.hasSafeArea)
        
        // Hide the keyboard when tapping around the view
        hideKeyboardWhenTappedAround()
        
    }
    
    /// Adds the navigation bar image/logo to the view.
    func addNavBarImage() {
        let navController = self.navigationController ?? UINavigationController()
        let image = UIImage(named: "navigationimage") // Your logo URL here
        navIMage = UIImageView(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 60))
        navIMage.translatesAutoresizingMaskIntoConstraints = false
        navIMage.image = image
        
        let bannerHeight = navController.navigationBar.frame.size.height
        let bannerY = bannerHeight / 2 - (image?.size.height ?? 0) / 2
        
        if iDonateClass.hasSafeArea {
            menuBtn.frame = CGRect(x: 10, y: bannerY + 60, width: 24, height: 24)
        } else {
            menuBtn.frame = CGRect(x: 10, y: bannerY + 15, width: 24, height: 24)
        }
        
        navIMage.contentMode = .center
        self.view.addSubview(navIMage)
        
        NSLayoutConstraint.activate([
            navIMage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            navIMage.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            navIMage.widthAnchor.constraint(equalToConstant: 100),
            navIMage.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        menuBtn.setImage(UIImage(named: "menu"), for: .normal)
    }
}
