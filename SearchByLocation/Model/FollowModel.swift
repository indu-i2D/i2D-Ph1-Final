
//
//  FollowModel.swift
//  iDonate
//
//  Created by Im043 on 03/07/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

struct FollowModel: Codable{
    
    var status: Int?
    var message: String?
    var token_status: Int?
    var token_message: String?
   
    enum CodingKeys: String,CodingKey{
        case status = "status"
        case message = "message"
        case token_status = "token_status"
        case token_message = "token_message"
    }
    
}
