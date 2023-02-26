//
//  RegisterModel.swift
//  iDonate
//
//  Created by Im043 on 31/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

struct RegisterModel: Codable{
    
    var registerArray: RegisterModelArray?
    var status: Int?
    var message: String?
   
    enum CodingKeys: String,CodingKey {
        case registerArray = "data"
        case status = "status"
        case message = "message"
    }
   
}

struct RegisterModelArray: Codable {
    
    var user_id: String?
    var email: String?
    var name : String?
    var phonenumber : String?
    var genter : String?
    var country : String?
    var token : String?
    
    

    enum RegisterModelArray: String,CodingKey {
       case user_id = "user_id"
       case email = "email"
       case name = "name"
       case phonenumber = "phone_number"
       case genter = "gender"
       case country = "country"
       case token = "token"
    }
    
}
