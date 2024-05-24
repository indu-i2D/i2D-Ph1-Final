//
//  CharityCount.swift
//  iDonate
//
//  Created by Im043 on 04/07/19.
//  © 2019 Im043. All rights reserved.
//

import UIKit

/// `CharityCount`: Model representing the charity count data received from the server.
class CharityCount: Codable {
    
    /// Contains the like, follow, and donation counts.
    var CharityLikeFollowCount: CharityLikeFollowCount?
    
    /// Status code of the response.
    var status: Int?
    
    /// Message associated with the response.
    var message: String?
    
    /// Status code related to token validation.
    var token_status: Int?
    
    /// Message related to token validation.
    var token_message: String?
    
    enum CodingKeys: String, CodingKey {
        case CharityLikeFollowCount = "data"
        case status
        case message
        case token_status
        case token_message
    }
}

/// `CharityLikeFollowCount`: Model containing detailed counts and lists related to likes, follows, and donations.
class CharityLikeFollowCount: Codable {
    
    /// Total number of likes.
    var like_count: Int?
    
    /// Total number of followings.
    var following_count: Int?
    
    /// List of liked charities.
    var likeArray: [LikeArrayModel]?
    
    /// List of followed charities.
    var followArray: [FollowArrayModel]?
    
    /// Total number of payments/donations.
    var paymentCount: Int?
    
    /// List of payment history.
    var paymentArray: [DonationArrayModel]?
    
    enum CodingKeys: String, CodingKey {
        case like_count
        case following_count
        case likeArray = "like_charity_list"
        case followArray = "following_charity_list"
        case paymentCount = "payment_count"
        case paymentArray = "payment_history_list"
    }
}

/// `CharityLikeFollowStatus`: Model representing the status response for charity like and follow actions.
class CharityLikeFollowStatus: Codable {
    
    /// Status code related to token validation.
    var token_status: Int?
    
    /// Status code of the response.
    var status: Int?
    
    /// Message associated with the response.
    var message: String?
    
    /// Message related to token validation.
    var token_message: String?
}

/// `LikeArrayModel`: Model representing a charity that the user has liked.
class LikeArrayModel: Codable {
    
    /// Unique identifier of the charity.
    var id: String?
    
    /// Name of the charity.
    var name: String?
    
    /// Description of the charity.
    var description: String?
    
    /// Street address of the charity.
    var street: String?
    
    /// City where the charity is located.
    var city: String?
    
    /// State where the charity is located.
    var state: String?
    
    /// Zip code of the charity.
    var zip_code: String?
    
    /// Country where the charity is located.
    var country: String?
    
    /// Logo URL of the charity.
    var logo: String?
    
    /// Banner image URL of the charity.
    var banner: String?
    
    /// Latitude of the charity's location.
    var latitude: String?
    
    /// Longitude of the charity's location.
    var longitude: String?
    
    /// Total like count of the charity.
    var like_count: String?
    
    /// Indicates if the user has liked the charity.
    var liked: String?
    
    /// Indicates if the user is following the charity.
    var followed: String?
}

/// `FollowArrayModel`: Model representing a charity that the user is following.
class FollowArrayModel: Codable {
    
    /// Unique identifier of the charity.
    var id: String?
    
    /// Name of the charity.
    var name: String?
    
    /// Description of the charity.
    var description: String?
    
    /// Street address of the charity.
    var street: String?
    
    /// City where the charity is located.
    var city: String?
    
    /// State where the charity is located.
    var state: String?
    
    /// Zip code of the charity.
    var zip_code: String?
    
    /// Country where the charity is located.
    var country: String?
    
    /// Logo URL of the charity.
    var logo: String?
    
    /// Banner image URL of the charity.
    var banner: String?
    
    /// Latitude of the charity's location.
    var latitude: String?
    
    /// Longitude of the charity's location.
    var longitude: String?
    
    /// Total like count of the charity.
    var like_count: String?
    
    /// Indicates if the user has liked the charity.
    var liked: String?
    
    /// Indicates if the user is following the charity.
    var followed: String?
}

/// `DonationArrayModel`: Model representing a donation made by the user.
struct DonationArrayModel: Codable {
    
    /// Unique identifier of the charity.
    var id: String?
    
    /// Name of the charity.
    var name: String?
    
    /// Description of the charity.
    var description: String?
    
    /// Street address of the charity.
    var street: String?
    
    /// City where the charity is located.
    var city: String?
    
    /// State where the charity is located.
    var state: String?
    
    /// Zip code of the charity.
    var zip_code: String?
    
    /// Country where the charity is located.
    var country: String?
    
    /// Logo URL of the charity.
    var logo: String?
    
    /// Banner image URL of the charity.
    var banner: String?
    
    /// Latitude of the charity's location.
    var latitude: String?
    
    /// Longitude of the charity's location.
    var longitude: String?
    
    /// Total like count of the charity.
    var like_count: String?
    
    /// Indicates if the user has liked the charity.
    var liked: String?
    
    /// Indicates if the user is following the charity.
    var followed: String?
    
    /// Unique identifier for the payment data.
    var payment_data_id: String?
    
    /// Total number of payment history records.
    var history_count: Int?
    
    /// List of payment history records.
    var history: [History]?
}

/// `History`: Model representing the history of a donation.
struct History: Codable {
    
    /// Amount donated.
    var amount: String?
    
    /// Date of the donation.
    var donate_date: String?
}

/// `DonationListModel`: Model representing a list of donations.
struct DonationListModel: Codable {
    
    /// Status code of the response.
    var status: Int?
    
    /// Message associated with the response.
    var message: String?
    
    /// List of donations.
    var data: [DonationModel]?
}

/// `DonationModel`: Model representing a single donation record.
struct DonationModel: Codable {
    
    /// User ID associated with the donation.
    var user_id: String?
    
    /// Name of the charity.
    var charity_name: String?
    
    /// Type of payment used.
    var payment_type: String?
    
    /// Amount donated.
    var amount: String?
    
    /// Date of the donation.
    var date: String?
}

