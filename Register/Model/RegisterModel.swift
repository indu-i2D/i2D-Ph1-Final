//
//  RegisterModel.swift
//  i2-Donate


import UIKit

/// Define the RegisterModel struct conforming to Codable
struct RegisterModel: Codable {
    // Define properties
    var registerArray: RegisterModelArray? // Optional property to hold user registration data
    var status: Int? // Optional property to hold the status of the registration process
    var message: String? // Optional property to hold a message related to the registration process
    
    // Define enum to map JSON keys to properties
    enum CodingKeys: String, CodingKey {
        case registerArray = "data" // Map "data" key in JSON to registerArray property
        case status // Map "status" key in JSON to status property
        case message // Map "message" key in JSON to message property
    }
}

// Define the RegisterModelArray struct conforming to Codable
struct RegisterModelArray: Codable {
    // Define properties
    var user_id: String? //  property to hold the unique identifier of the registered user
    var email: String? //  property to hold the email address of the registered user
    var name: String? //  property to hold the name of the registered user
    var phonenumber: String? //  property to hold the phone number of the registered user
    var gender: String? //  property to hold the gender of the registered user
    var country: String? //  property to hold the country of the registered user
    var token: String? //  property to hold a token associated with the registered user
    
    // Define enum to map JSON keys to properties
    enum CodingKeys: String, CodingKey {
        case user_id // Map "user_id" key in JSON to user_id property
        case email // Map "email" key in JSON to email property
        case name // Map "name" key in JSON to name property
        case phonenumber = "phone_number" // Map "phone_number" key in JSON to phonenumber property
        case gender // Map "gender" key in JSON to gender property
        case country // Map "country" key in JSON to country property
        case token // Map "token" key in JSON to token property
    }
}
