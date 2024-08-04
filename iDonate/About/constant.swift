//
//  constant.swift
//  i2-Donate
//

//

import Foundation
import UIKit

/**
 A struct containing various boolean constants used throughout the application.
 */
struct constantFile {
    /// A boolean flag indicating if the email has been changed.
    static var changemail: Bool = false
    
    /// A boolean flag indicating if the password has been changed.
    static var changepasswordBack: Bool = false
    
    /// A boolean flag indicating if the key has been narrowed down in subtype.
    static var narrowdownKeyinsubtyper: Bool = false
}

/// The height of the screen.
let screenHeight = UIScreen.main.bounds.size.height

/// The width of the screen.
let screenWidth = UIScreen.main.bounds.size.width

/// A boolean flag indicating if the device is iPhone 4 or smaller.
let Iphone4orLess: Bool = (UIScreen.main.bounds.size.height == 480)

/// A boolean flag indicating if the device is iPhone 5 or SE.
let Iphone5orSE: Bool = (UIScreen.main.bounds.size.height == 568)

/// A boolean flag indicating if the device is iPhone 6, 7, or 8.
let Iphone678: Bool = (UIScreen.main.bounds.size.height == 667)

/// A boolean flag indicating if the device is iPhone 6+, 7+, or 8+.
let Iphone678p: Bool = (UIScreen.main.bounds.size.height == 736)

/// A boolean flag indicating if the device is iPhone X.
let IphoneX: Bool = (UIScreen.main.bounds.size.height == 812)

/// A boolean flag indicating if the device is iPhone XR.
let IphoneXR: Bool = (UIScreen.main.bounds.size.height == 896)

/// The frame of the screen.
let screenFrame = CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight)

/// System font size 20.
let systemFont20 = UIFont.systemFont(ofSize: 20)

/// System font size 18.
let systemFont18 = UIFont.systemFont(ofSize: 18)

/// System font size 14.
let systemFont14 = UIFont.systemFont(ofSize: 14)

/// System font size 16.
let systemFont16 = UIFont.systemFont(ofSize: 16)

/// System font size 12.
let systemFont12 = UIFont.systemFont(ofSize: 12)

/// Bold system font size 17.
let boldSystem17 = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)

/// Bold system font size 14.
let boldSystem14 = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)

/// Bold system font size 12.
let boldSystem12 = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.bold)

// Color constants
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

/// The URL of the server.
var SERVER_URL = ""

/// The URL of the terms and conditions page.
var TERM_COND_URL = ""

/// The URL of the privacy policy page.
var PRIVACY_URL = ""

/// The URL of the help page.
var HELP_URL = ""

/// The URL of the about page.
var ABOUT_URL = ""

/// The URL for uploading files.
var UPLOAD_URL = ""
