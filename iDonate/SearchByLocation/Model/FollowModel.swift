
//
//  FollowModel.swift
//  i2-Donate

import Foundation
/**The FollowModel is like a blueprint for representing information about a follow action in an app**/
struct FollowModel: Codable {
    var status: Int?
    var message: String?
    var token_status: Int?
    var token_message: String?
   
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
        case token_status = "token_status"
        case token_message = "token_message"
    }
}


