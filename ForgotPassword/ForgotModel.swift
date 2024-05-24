//
//  ForgotModel.swift
//  i2-Donate
//
import UIKit

/// A structure representing the response model for the Forgot Password API.
struct ForgotModel: Codable {
    var status: Int? // The status code of the response.
    var message: String? // A message accompanying the response status.
    var data: Forgotdata? // Additional data related to the response.
}

/// A structure representing the data contained within the ForgotModel.
struct Forgotdata: Codable {
    var user_id: String? // The user ID associated with the forgot password request.
}
