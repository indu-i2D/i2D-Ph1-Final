//
//  UpdateModel.swift
//  i2-Donate


import UIKit

/// A struct representing the update model response.
struct UpdateModel: Codable {
    /// The data of the login model array.
    var data: loginModelArray?
    /// The status of the update response.
    var status: Int?
    /// The message associated with the update response.
    var message: String?
    /// The token message associated with the update response.
    var token_message: String?
    /// The token status associated with the update response.
    var token_status: Int?

    /// Enum defining the coding keys to map the JSON keys with struct properties.
    enum CodingKeys: String, CodingKey {
        /// Coding key for the data property.
        case data = "data"
        /// Coding key for the status property.
        case status = "status"
        /// Coding key for the message property.
        case message = "message"
        /// Coding key for the token status property.
        case token_status = "token_status"
        /// Coding key for the token message property.
        case token_message = "token_message"
    }
}

