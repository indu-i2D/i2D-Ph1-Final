//
//  CharityCount.swift
//  iDonate
//
//  Created by Im043 on 04/07/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

class CharityCount: Codable {
    
    var CharityLikeFollowCount: CharityLikeFollowCount?
    var status: Int?
    var message: String?
    var token_status: Int?
    var token_message: String?
    
    enum CodingKeys: String, CodingKey {
        case CharityLikeFollowCount = "data"
        case status = "status"
        case message = "message"
        case token_status = "token_status"
        case token_message = "token_message"
    }
    
}

class CharityLikeFollowCount: Codable {
    
    var like_count: Int?
    var following_count: Int?
    var likeArray: [LikeArrayModel]?
    var followArray: [FollowArrayModel]?
    var paymentCount: Int?
    var paymentArray: [DonationArrayModel]?
    
    enum CodingKeys: String, CodingKey {
        case like_count = "like_count"
        case following_count = "following_count"
        case likeArray = "like_charity_list"
        case followArray = "following_charity_list"
        case paymentCount = "payment_count"
        case paymentArray = "payment_history_list"
    }
    
}

class CharityLikeFollowStatus: Codable {
    
    var token_status: Int?
    var status: Int?
    var message: String?
    var token_message: String?
    
}


class LikeArrayModel: Codable {
    
    var id: String?
    var name: String?
    var description: String?
    var street: String?
    var city: String?
    var state: String?
    var zip_code: String?
    var country: String?
    var logo: String?
    var banner: String?
    var latitude: String?
    var longitude: String?
    var like_count: String?
    var liked: String?
    var followed: String?
    
}

class FollowArrayModel: Codable {
    
    var id: String?
    var name: String?
    var description: String?
    var street: String?
    var city: String?
    var state: String?
    var zip_code: String?
    var country: String?
    var logo: String?
    var banner: String?
    var latitude: String?
    var longitude: String?
    var like_count: String?
    var liked: String?
    var followed: String?
    
}

struct DonationArrayModel: Codable {
    
    var id: String?
    var name: String?
    var description: String?
    var street: String?
    var city: String?
    var state: String?
    var zip_code: String?
    var country: String?
    var logo: String?
    var banner: String?
    var latitude: String?
    var longitude: String?
    var like_count: String?
    var liked: String?
    var followed: String?
    var payment_data_id: String?
    var history_count: Int?
    var history: [History]?
}

struct History: Codable {
    var amount: String?
    var donate_date: String?
}



struct DonationListModel: Codable {
    var status: Int?
    var message: String?
    var data: [DonationModel]?
}

/*
 "user_id": "49",
            "charity_name": "6TH JUDICIAL DISTRICT CASA PROGRAM INC",
            "payment_type": "Visa",
            "amount": "$10.69",
            "date": "October 19, 2020, 5:06 pm"
 */

struct DonationModel: Codable {
    
    var user_id: String?
    var charity_name: String?
    var payment_type: String?
    var amount: String?
    var date: String?

}
