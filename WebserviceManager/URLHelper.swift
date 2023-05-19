//
//  URLHelper.swift
//  ECommerceSDK
//
//  Created by sureshkumar on 02/03/18.
//  Copyright © 2017 sureshkumar. All rights reserved.
//

import Foundation
import UIKit

enum URLName : String {
    
    case kAppShare = "AppShare"
    case kAuthToken = "AuthToken"
//    case MDServerURL = "Base-url"//test
    case MDServerURL = "Base-url" //Prod
    case iDonateRegister = "Register"
    case iDonateLogin = "Login"
    case iDonateCOuntryLIst = "CountryList"
    case iDonateSocialLogin = "SocialLogin"
    case iDonateUpdateProfile = "UpdateProfile"
    case iDonateCategories = "Categories"
    case iDonateCharityList = "charityList"
    case iDonateCharityLike = "charityLike"
    case iDonateCharityFollow = "CharityFollow"
    case iDonatePayment = "Tranasaction"
    case iDonateCharityFollowLikeCount = "CharityLikeFollowCount"
    case iDonateChangePassword = "ChangePassword"
    case iDonateForgotPassword = "ForgotPassword"
    case iDonateVerifyOtp = "VerifyOtp"
    case iDonateUpdatePassword = "UpdatePassword"
    case iDonateNotification = "Notification"
    case iDonateTransactionList = "TransactionList"
    case iDonateTermsUrl = "TermsUrl"
    case iDonatePrivacyUrl = "PrivacyUrl"
    case iDonateHelpUrl = "HelpUrl"
    case iDonateAboutUrl = "AboutUrl"

}

final fileprivate class URLFetcher : NSObject {
    
    static let sharedFetcher : URLFetcher = {
        let helper = URLFetcher()
        helper.collectAllAvailableURLs()
        return helper
    }()
    
    fileprivate let baseURLFile = "ApiParams"
    fileprivate let fileType = "plist"
    
    private(set) var urlDictionary = [String : String]()

    func collectAllAvailableURLs() -> Void {
                
        if let serverURLFilePath = Bundle.main.path(forResource: self.baseURLFile, ofType: self.fileType) {
            if let content = NSDictionary(contentsOfFile: serverURLFilePath) as? [String : String] {
                self.urlDictionary = content
            }
        }
    }
    
}

final class URLHelper : NSObject {
    
    static var baseURL : String = {
        return URLFetcher.sharedFetcher.urlDictionary[URLName.MDServerURL.rawValue]!
    }()
    
    static var iDonateLogin : String = {
        return URLFetcher.sharedFetcher.urlDictionary[URLName.MDServerURL.rawValue]! +  URLFetcher.sharedFetcher.urlDictionary[URLName.iDonateLogin.rawValue]!
    }()
    static var iDonateRegister : String = {
        return URLFetcher.sharedFetcher.urlDictionary[URLName.MDServerURL.rawValue]! +  URLFetcher.sharedFetcher.urlDictionary[URLName.iDonateRegister.rawValue]!
    }()
    static var iDonateCountryList : String = {
        return URLFetcher.sharedFetcher.urlDictionary[URLName.MDServerURL.rawValue]! +  URLFetcher.sharedFetcher.urlDictionary[URLName.iDonateCOuntryLIst.rawValue]!
    }()
    static var iDonateSocialLogin : String = {
        return URLFetcher.sharedFetcher.urlDictionary[URLName.MDServerURL.rawValue]! +  URLFetcher.sharedFetcher.urlDictionary[URLName.iDonateSocialLogin.rawValue]!
    }()
    static var iDonateUpdateProfile : String = {
        return URLFetcher.sharedFetcher.urlDictionary[URLName.MDServerURL.rawValue]! +  URLFetcher.sharedFetcher.urlDictionary[URLName.iDonateUpdateProfile.rawValue]!
    }()
    static var iDonateCategories : String = {
        return URLFetcher.sharedFetcher.urlDictionary[URLName.MDServerURL.rawValue]! +  URLFetcher.sharedFetcher.urlDictionary[URLName.iDonateCategories.rawValue]!
    }()
    static var iDonateCharityList : String = {
        return URLFetcher.sharedFetcher.urlDictionary[URLName.MDServerURL.rawValue]! +  URLFetcher.sharedFetcher.urlDictionary[URLName.iDonateCharityList.rawValue]!
    }()
    static var iDonateCharityLike : String = {
        return URLFetcher.sharedFetcher.urlDictionary[URLName.MDServerURL.rawValue]! +  URLFetcher.sharedFetcher.urlDictionary[URLName.iDonateCharityLike.rawValue]!
    }()
    
    static var iDonateCharityFollow : String = {
        return URLFetcher.sharedFetcher.urlDictionary[URLName.MDServerURL.rawValue]! +  URLFetcher.sharedFetcher.urlDictionary[URLName.iDonateCharityFollow.rawValue]!
    }()
    
    static var iDonatePayment : String = {
        return URLFetcher.sharedFetcher.urlDictionary[URLName.MDServerURL.rawValue]! +  URLFetcher.sharedFetcher.urlDictionary[URLName.iDonatePayment.rawValue]!
    }()
    
    static var iDonateCharityFollowLikeCount : String = {
        return URLFetcher.sharedFetcher.urlDictionary[URLName.MDServerURL.rawValue]! +  URLFetcher.sharedFetcher.urlDictionary[URLName.iDonateCharityFollowLikeCount.rawValue]!
    }()
    static var iDonateChangePassword : String = {
        return URLFetcher.sharedFetcher.urlDictionary[URLName.MDServerURL.rawValue]! +  URLFetcher.sharedFetcher.urlDictionary[URLName.iDonateChangePassword.rawValue]!
    }()
    static var iDonateForgotPassword : String = {
        return URLFetcher.sharedFetcher.urlDictionary[URLName.MDServerURL.rawValue]! +  URLFetcher.sharedFetcher.urlDictionary[URLName.iDonateForgotPassword.rawValue]!
    }()
    static var iDonateVerifyOtp : String = {
        return URLFetcher.sharedFetcher.urlDictionary[URLName.MDServerURL.rawValue]! +  URLFetcher.sharedFetcher.urlDictionary[URLName.iDonateVerifyOtp.rawValue]!
    }()
    static var iDonateUpdatePassword : String = {
        return URLFetcher.sharedFetcher.urlDictionary[URLName.MDServerURL.rawValue]! +  URLFetcher.sharedFetcher.urlDictionary[URLName.iDonateUpdatePassword.rawValue]!
    }()
    static var iDonateNotification : String = {
        return URLFetcher.sharedFetcher.urlDictionary[URLName.MDServerURL.rawValue]! +  URLFetcher.sharedFetcher.urlDictionary[URLName.iDonateNotification.rawValue]!
    }()
    static var iDonateTransactionList : String = {
        return URLFetcher.sharedFetcher.urlDictionary[URLName.MDServerURL.rawValue]! +  URLFetcher.sharedFetcher.urlDictionary[URLName.iDonateTransactionList.rawValue]!
    }()
    static var getDocsBaseurl : String = {
        let baseUrl = URL(string: URLFetcher.sharedFetcher.urlDictionary[URLName.MDServerURL.rawValue]!)
        let url = String(format: "https://%@/", (baseUrl?.host!)!)
        return url
    }()
    static var getTermsAndConditionUrl : String = {
        let terms = String(format: "%@%@", getDocsBaseurl,URLFetcher.sharedFetcher.urlDictionary[URLName.iDonateTermsUrl.rawValue]!)
        return terms
    }()
    static var getPrivacyUrl : String = {
        let terms = String(format: "%@%@", getDocsBaseurl,URLFetcher.sharedFetcher.urlDictionary[URLName.iDonatePrivacyUrl.rawValue]!)
        return terms
    }()
    static var getAboutUrl : String = {
        let terms = String(format: "%@%@", getDocsBaseurl,URLFetcher.sharedFetcher.urlDictionary[URLName.iDonateAboutUrl.rawValue]!)
        return terms
    }()
    static var getHelpUrl : String = {
        let terms = String(format: "%@%@", getDocsBaseurl,URLFetcher.sharedFetcher.urlDictionary[URLName.iDonateHelpUrl.rawValue]!)
        return terms
    }()
}

