
//
//  CountryList.swift
//  i2-Donate
//

import UIKit

/// Model class representing the response from the API containing a list of countries
class CountryList: Codable {
    
    /// Array of country list items
    var countryListArray: [countryListArray]?
    
    /// Status code of the response
    var status: Int?
    
    /// Message accompanying the response
    var message: String?
    
    /// Coding keys to map the JSON keys to the properties
    enum CodingKeys: String, CodingKey {
        case countryListArray = "data"
        case status = "status"
        case message = "message"
    }
}

/// Struct representing an individual country item in the list
struct countryListArray: Codable {
    /// Country code (e.g., "US" for the United States)
    var sortname: String
    
    /// Name of the country
    var name: String
    
    /// Emoji flag representing the country
    var flag: String?
}
