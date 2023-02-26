//
//  ChangeModel.swift
//  iDonate
//
//  Created by Im043 on 12/08/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

struct ChangeModel: Codable {
    var status: Int?
    var tokenStatus: Int?
    var message: String?
    var tokenMessage: String?
    
    enum CodingKeys: String, CodingKey {
       case tokenStatus = "token_status"
       case status = "status"
       case message = "message"
       case tokenMessage = "token_message"
    }
    
}
