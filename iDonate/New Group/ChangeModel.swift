//
//  ChangeModel.swift
//  i2-Donate


import UIKit

/// A struct representing the response model for a change request.
struct ChangeModel: Codable {
    /// The status code indicating the result of the change request.
    var status: Int?
    
    /// The status code related to the token in the change request.
    var tokenStatus: Int?
    
    /// A message associated with the result of the change request.
    var message: String?
    
    /// A message related to the token in the change request.
    var tokenMessage: String?
    
    /// Coding keys to map JSON keys to struct properties.
    enum CodingKeys: String, CodingKey {
        case tokenStatus = "token_status" // Map "token_status" key in JSON to tokenStatus property
        case status // Map "status" key in JSON to status property
        case message // Map "message" key in JSON to message property
        case tokenMessage = "token_message" // Map "token_message" key in JSON to tokenMessage property
    }
}
