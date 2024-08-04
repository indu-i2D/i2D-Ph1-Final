//
//  SwiftHelper.swift

import UIKit

/** Helper class for managing localized strings in Swift. */
class SwiftHelper: NSObject {
    // Retrieves a localized string for the specified key.
    //
    // - Parameters:
    //   - key: The key used to lookup the localized string.
    //   - Comment: A comment describing the purpose of the localized string.
    // - Returns: The localized string corresponding to the key.
    class func LocalizedSwiftString(key: String, Comment: String) -> String {
        return Bundle.main.localizedString(forKey: key, value: "", table: nil)
    }
}
