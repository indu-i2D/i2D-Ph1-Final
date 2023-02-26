//
//  CharityLikeModel.swift
//  iDonate
//
//  Created by Im043 on 02/07/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

struct CharityLikeModel: Codable {
    
    var status: Int?
    var message: String?
    var token_status: Int?
    var token_message: String?
    var likecount:CharityLikeCount?
    
    enum CodingKeys: String, CodingKey {
        case likecount = "data"
        case status = "status"
        case message = "message"
        case token_status = "token_status"
        case token_message = "token_message"
    }
    
}

class CharityLikeCount: Codable {
    
    var likeCount: String?

    enum CodingKeys: String,CodingKey {
        case likeCount = "like_count"
    }
    
}
