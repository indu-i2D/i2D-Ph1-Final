//
//  AdvancedModel.swift
//  iDonate
//

import UIKit

/// Represents the model structure for advanced data fetched from the server.
struct AdvancedModel: Codable {
    
    /// The status code of the response.
    var status: Int?
    
    /// The message associated with the response status.
    var message: String?
    
    /// The token status code.
    var token_status: Int?
    
    /// The message associated with the token status.
    var token_message: String?
    
    /// An array containing instances of `Types`.
    var data: [Types]?

    /// Coding keys for decoding the JSON response.
    enum CodingKeys: String, CodingKey  {
        case data = "data"
        case status = "status"
        case message = "message"
        case token_status = "token_status"
        case token_message = "token_message"
    }
    
}

/// Represents the types fetched from the server.
struct Types: Codable{
    
    /// The category code.
    var category_code: String?
    
    /// The category ID.
    var category_id: String?
    
    /// The category name.
    var category_name: String?
    
    /// An array containing instances of `SubTypes`.
    var subcategory: [SubTypes]?
}

/// Represents the subtypes fetched from the server.
struct SubTypes: Codable{
    
    /// The subcategory ID.
    var sub_category_id: String?
    
    /// The subcategory name.
    var sub_category_name: String?
    
    /// The subcategory code.
    var sub_category_code: String?
    
    /// An array containing instances of `ChildTypes`.
    var child_category: [ChildTypes]?
}

/// Represents the child types fetched from the server.
struct ChildTypes: Codable {
    
    /// The child category ID.
    var child_category_id: String?
    
    /// The child category name.
    var child_category_name: String?
    
    /// The child category code.
    var child_category_code: String?
}

