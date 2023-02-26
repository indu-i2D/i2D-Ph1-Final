//
//  SwiftHelper.swift
//  Muhnndi
//
//  Created by sureshkumar on 3/4/18.
//  Copyright © 2018 sureshkumar. All rights reserved.
//

import UIKit

class SwiftHelper: NSObject {
    class func LocalizedSwiftString(key : String , Comment : String) -> String {
        return Bundle.main.localizedString(forKey: key, value: "", table: nil)
    }
}
