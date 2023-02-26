//
//  CountryList.swift
//  iDonate
//
//  Created by Im043 on 31/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

class CountryList: Codable {
    
    var countryListArray: [countryListArray]?
    var status: Int?
    var message: String?
    
    enum CodingKeys: String,CodingKey {
        case countryListArray = "data"
        case status = "status"
        case message = "message"
    }
    
}

struct countryListArray: Codable {
    var sortname: String
    var name: String
    var flag: String?
}
