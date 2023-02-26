//
//  loginModel.swift
//  iDonate
//
//  Created by Im043 on 31/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

/*
 data =     {
     "business_name" = "";
     country = "";
     email = "javish.fri@gmail.com";
     gender = M;
     name = "Satheesh Kumar";
     "phone_number" = "";
     photo = "https://admin.i2-donate.com/uploads/profile/1591683137.png";
     status = A;
     token = be466d15bb237f38a93a04e501b61f88;
     type = individual;
     "user_id" = 49;
 };
 message = "Login Successfully";
 status = 1;
 */

struct loginModel: Codable {
    var status: Int?
    var message: String?
    var data: loginModelArray?
}

struct loginModelArray: Codable {
    var business_name: String?
    var user_id: String?
    var email: String?
    var name : String?
    var phone_number : String?
    var gender : String?
    var country : String?
    var token : String?
    var photo : String?
    var status : String?
    var type: String?
    var terms: String?
}
