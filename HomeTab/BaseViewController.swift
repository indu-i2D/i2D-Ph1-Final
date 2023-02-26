//
//  ViewController.swift
//  iDonate
//
//  Created by Im043 on 24/04/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    static let sharedAPI : BaseViewController = BaseViewController()
    let menuBtn = UIButton()
    var bgImage = UIImageView()
    var navIMage = UIImageView()
    
//    var environment:String = PayPalEnvironmentNoNetwork {
//           willSet(newEnvironment) {
//               if (newEnvironment != environment) {
//                   PayPalMobile.preconnect(withEnvironment: newEnvironment)
//               }
//           }
//       }
//
//       var payPalConfig = PayPalConfiguration()
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        bgImage = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        bgImage.image = UIImage(named: "backgrounimage")
        self.view.addSubview(bgImage)
        self.view.sendSubviewToBack(bgImage)
        addNavBarImage()
        print(iDonateClass.hasSafeArea)
        
        hideKeyboardWhenTappedAround()
        
//        payPalConfig.acceptCreditCards = false
//        payPalConfig.merchantName = "i2~Donate"//Give your company name here.
//        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
//        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
//        //This is the language in which your paypal sdk will be shown to users.
//        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
//        //Here you can set the shipping address. You can choose either the address associated with PayPal account or different address. We’ll use .both here.
//        payPalConfig.payPalShippingAddressOption = .both;
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    func addNavBarImage() {
        let navController = self.navigationController ?? UINavigationController()
        let image = UIImage(named: "navigationimage") //Your logo url here
        navIMage = UIImageView(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 60))
        navIMage.translatesAutoresizingMaskIntoConstraints = false
        navIMage.image = image
        
        let bannerHeight = navController.navigationBar.frame.size.height
        let bannerY = bannerHeight / 2 - (image?.size.height)! / 2
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 10, y: bannerY+60, width: 24, height: 24)
        }
        else {
            menuBtn.frame = CGRect(x: 10, y: bannerY+15, width: 24, height: 24)
        }
        navIMage.contentMode = .center
        
        self.view.addSubview(navIMage)

        NSLayoutConstraint.activate([navIMage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor), navIMage.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor), navIMage.widthAnchor.constraint(equalToConstant: 100), navIMage.heightAnchor.constraint(equalToConstant: 40)])
        
        menuBtn.setImage(UIImage(named: "menu"), for: .normal)
     
    }
   
}

