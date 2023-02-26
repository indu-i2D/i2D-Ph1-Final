//
//  UserDetails.swift
//  iDonate
//
//  Created by Im043 on 06/06/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

class UserDetails: NSObject,NSCoding {
    
    let name: String
    let email: String
    let mobileNUmber : String
    let gender : String
    let profileUrl : String
    let country : String
    let token : String
    let userID : String
    let type: String
    let businessName: String
    let terms: String
    
    init(name: String, email: String,mobileNUmber : String, gender : String,profileUrl : String, country : String,token:String, userID:String, type:String, businessName: String, terms: String) {
        self.name = name
        self.email = email
        self.mobileNUmber = mobileNUmber
        self.gender = gender
        self.profileUrl = profileUrl
        self.country = country
        self.token = token
        self.userID = userID
        self.type = type
        self.businessName = businessName
        self.terms = terms
    }
    
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: "name") as? String ?? ""
        self.email = decoder.decodeObject(forKey: "email")  as? String ?? ""
        self.mobileNUmber = decoder.decodeObject(forKey: "mobileNUmber")  as? String ?? ""
        self.gender = decoder.decodeObject(forKey: "gender")  as? String ?? ""
        self.profileUrl = decoder.decodeObject(forKey: "profileUrl")  as? String ?? ""
        self.country = decoder.decodeObject(forKey: "country")  as? String ?? ""
        self.token = decoder.decodeObject(forKey: "token")  as? String ?? ""
        self.userID = decoder.decodeObject(forKey: "userID")  as? String ?? ""
        self.type = decoder.decodeObject(forKey: "type")  as? String ?? ""
        self.businessName = decoder.decodeObject(forKey: "businessName")  as? String ?? ""
        self.terms = decoder.decodeObject(forKey: "terms")  as? String ?? ""


    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(email, forKey: "email")
        coder.encode(mobileNUmber, forKey: "mobileNUmber")
        coder.encode(gender, forKey: "gender")
        coder.encode(profileUrl, forKey: "profileUrl")
        coder.encode(country, forKey: "country")
        coder.encode(token, forKey: "token")
        coder.encode(userID, forKey: "userID")
        coder.encode(type, forKey: "type")
        coder.encode(businessName, forKey: "businessName")
        coder.encode(terms, forKey: "terms")
    }
}
