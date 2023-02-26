//
//  CharityModel.swift
//  iDonate
//
//  Created by Im043 on 28/06/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

struct CharityModel: Codable {
    var data: [charityListArray] = [charityListArray]()
    var status: Int?
    var message: String?
}

struct charityListArray: Codable {
    var id: String? = ""
    var name: String? = ""
    var street : String? = ""
    var city : String? = ""
    var state : String? = ""
    var zip_code : String? = ""
    var country : String? = ""
    var like_count : String? = ""
    var liked : String? = ""
    var followed: String? = ""
    var logo : String? = ""
    var taxdeductible: String? = ""
    var amt : String? = ""
}

struct paymentModel: Codable {
    var token_status: Int?
    var message: String?
    var token_message: String?
    var status: Int?
    var data: paymentData?
}

struct paymentData: Codable {
    var i2D_D_USER_ID: String?
    var i2D_D_ID: String?
    var i2D_D_CHARITY_ID : String?
    var i2D_D_CHARITY_NAME : String?
    var i2D_D_TRANSACTION_ID : String?
    var i2D_D_AMOUNT : String?
    var i2D_D_STATUS : String?
    var i2D_D_CREATED_AT : String?
}
