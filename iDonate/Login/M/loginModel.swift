//
//  loginModel.swift
//  i2-Donate
//
//  This file contains the data models for the login response.

import UIKit

/// Represents the response for a login request.
struct loginModel: Codable {
    /// The status code of the response.
    var status: Int?
    /// The message accompanying the response.
    var message: String?
    /// The detailed data of the logged-in user.
    var data: loginModelArray?
}

/// Represents the detailed data of the logged-in user.
struct loginModelArray: Codable {
    /// The business name associated with the user.
    var business_name: String?
    /// The unique identifier of the user.
    var user_id: String?
    /// The email address of the user.
    var email: String?
    /// The name of the user.
    var name: String?
    /// The phone number of the user.
    var phone_number: String?
    /// The gender of the user.
    var gender: String?
    /// The country of the user.
    var country: String?
    /// The authentication token for the user session.
    var token: String?
    /// The URL or path to the user's photo.
    var photo: String?
    /// The status of the user account.
    var status: String?
    /// The type of user (e.g., admin, regular user).
    var type: String?
    /// Terms and conditions associated with the user account.
    var terms: String?
}
