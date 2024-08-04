import UIKit

/// Model for storing charity data.
struct CharityModel: Codable {
    var data: [CharityListArray] = []
    var status: Int?
    var message: String?
}

/// Model representing a charity item.
struct CharityListArray: Codable {
    var id: String? = ""
    var name: String? = ""
    var street: String? = ""
    var city: String? = ""
    var state: String? = ""
    var zipCode: String? = ""
    var country: String? = ""
    var likeCount: String? = ""
    var liked: String? = ""
    var followed: String? = ""
    var followedCount: String? = "0"
    var logo: String? = ""
    var taxDeductible: String? = ""
    var amount: String? = ""
}

/// Model for payment response.
struct PaymentModel: Codable {
    var tokenStatus: Int?
    var message: String?
    var tokenMessage: String?
    var status: Int?
    var data: PaymentData?
}

/// Model representing payment data.
struct PaymentData: Codable {
    var i2DUserId: String?
    var i2DId: String?
    var i2DCharityId: String?
    var i2DCharityName: String?
    var i2DTransactionId: String?
    var i2DAmount: String?
    var i2DStatus: String?
    var i2DCreatedAt: String?
}
