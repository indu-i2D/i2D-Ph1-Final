import Foundation

/// Represents the response model for charity like information.
struct CharityLikeModel: Codable {
    
    /// The status code of the response.
    var status: Int?
    
    /// The message associated with the response status.
    var message: String?
    
    /// The token status code of the response.
    var token_status: Int?
    
    /// The message associated with the token status.
    var token_message: String?
    
    /// The like count information.
    var likecount: CharityLikeCount?
    
    enum CodingKeys: String, CodingKey {
        case likecount = "data"
        case status = "status"
        case message = "message"
        case token_status = "token_status"
        case token_message = "token_message"
    }
    
}

/// Represents the like count for a charity.
class CharityLikeCount: Codable {
    
    /// The number of likes for the charity.
    var likeCount: String?

    enum CodingKeys: String, CodingKey {
        case likeCount = "like_count"
    }
    
}

