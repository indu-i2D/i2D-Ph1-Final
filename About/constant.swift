//
//  constant.swift
//  iDonate
//
//  Created by Im043 on 04/09/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import Foundation
import UIKit

struct constantFile {
    static var changemail:Bool = false
    static var changepasswordBack: Bool = false
    static var narrowdownKeyinsubtyper: Bool = false
}

let screenHeight = UIScreen.main.bounds.size.height
let screenWidth = UIScreen.main.bounds.size.width

let Iphone4orLess:Bool              = (UIScreen.main.bounds.size.height == 480)
let Iphone5orSE:Bool                = (UIScreen.main.bounds.size.height == 568)
let Iphone678:Bool                  = (UIScreen.main.bounds.size.height == 667)
let Iphone678p:Bool                 = (UIScreen.main.bounds.size.height == 736)
let IphoneX:Bool                    = (UIScreen.main.bounds.size.height == 812)
let IphoneXR:Bool                   = (UIScreen.main.bounds.size.height == 896)

let screenFrame = CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight)
let systemFont20 = UIFont.systemFont(ofSize: 20)
let systemFont18 = UIFont.systemFont(ofSize: 18)
let systemFont14 = UIFont.systemFont(ofSize: 14)
let systemFont16 = UIFont.systemFont(ofSize: 16)
let systemFont12 = UIFont.systemFont(ofSize: 12)
let boldSystem17 = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)
let boldSystem14 = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
let boldSystem12 = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.bold)

//let systemFont14 = UIFont(name: "SF-Pro-Display-Regular", size: 50)
//let systemFont12 = UIFont(name: "SF-Pro-Display-Regular", size: 12)
//let boldSystem17 = UIFont(name: "SF-Compact-Display-Black", size: 17)

//MARK: - Color
let buttonBgColor = hexStringToUIColor(hex: "#9C7192")
let searchBtnTextColor = hexStringToUIColor(hex: "#9C7192")
let Login_registerBtnColor = hexStringToUIColor(hex: "#532B05")
let backgroundBoxColor = hexStringToUIColor(hex: "#F4DEEF")
let bottomNavigationBgColorStart = hexStringToUIColor(hex: "#D097C4")
let bottomNavigationBgColorEnd = hexStringToUIColor(hex: "#E3BFDB")
let titleTextColor = hexStringToUIColor(hex: "#532B05")
let fontBlackColor = hexStringToUIColor(hex: "#4A4A4A")
let termsFontColor = hexStringToUIColor(hex: "#424ef5")
let ivoryColor = hexStringToUIColor(hex: "#FCFCEF")
