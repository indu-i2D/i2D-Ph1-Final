//
//  ForgotModel.swift
//  iDonate
//
//  Created by Im043 on 21/08/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

struct ForgotModel: Codable {
    var status: Int?
    var message: String?
    var data: Forgotdata?
}

struct Forgotdata: Codable {
    var user_id: String?
}
