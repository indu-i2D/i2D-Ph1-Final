//
//  UpdateModel.swift
//  iDonate
//
//  Created by Im043 on 14/06/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

struct UpdateModel: Codable {
    var data: loginModelArray?
    var status: Int?
    var message: String?
    var token_message: String?
    var token_status: Int?

    enum UpdateModel: String, CodingKey {
        case data = "data"
        case status = "status"
        case message = "message"
        case token_status = "token_status"
        case token_message = "token_message"
    }
    
}

