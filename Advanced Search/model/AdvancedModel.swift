//
//  AdvancedModel.swift
//  iDonate
//
//  Created by Im043 on 13/06/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

struct AdvancedModel: Codable {
    
    var status: Int?
    var message: String?
    var token_status: Int?
    var token_message: String?
    var data:[Types]?

    enum AdvancedModel: String,CodingKey  {
        case data = "data"
        case status = "status"
        case message = "message"
        case token_status = "token_status"
        case token_message = "token_message"
    }
    
}

struct Types: Codable{
    var category_code: String?
    var category_id: String?
    var category_name: String?
    var subcategory : [SubTypes]?
}

struct SubTypes: Codable{
    var sub_category_id: String?
    var sub_category_name: String?
    var sub_category_code: String?
    var child_category : [ChildTypes]?
}

struct ChildTypes: Codable {
    var child_category_id: String?
    var child_category_name: String?
    var child_category_code: String?
}


