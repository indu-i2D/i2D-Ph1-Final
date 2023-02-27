
//
//  Extensions.swift
//  TwitterApi
//
//  Created by Nagendran Nagarajan on 3/27/20.
//  Copyright © 2020 narendh. All rights reserved.
//

import Foundation

extension String {
    var urlQueryStringParameters: [String: String] {
        // breaks apart query string into a dictionary of values
        var params = [String: String]()
        let items = self.split(separator: "&")

        for item in items {
            let combo = item.split(separator: "=")

            if combo.count == 2 {
                let key = "\(combo[0])"
                let val = "\(combo[1])"

                params[key] = val
            }
        }

        return params
    }

    var urlEncoded: String {
        var charset: CharacterSet = .urlQueryAllowed
        charset.remove(charactersIn: "\n:#/?@!$&'()*+,;=")

        return self.addingPercentEncoding(withAllowedCharacters: charset)!
    }
    

    func getMessage() -> String {
        let charSet = ["{\"errors\":[{\"code\":", ",\"message\":\"", "\"}]}"]
        var returnVal: String = self

        for set in charSet {
            returnVal = returnVal.replacingOccurrences(of: set, with: "")
        }

        return returnVal.components(separatedBy: CharacterSet.decimalDigits).joined()
    }
}

extension Notification.Name {
    static let twitterCallback = Notification.Name(rawValue: "Twitter.CallbackNotification.Name")
}

extension URL {
    func appending(_ queryItem: String, value: String?) -> URL {
        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }

        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []

        // Create query item
        let queryItem = URLQueryItem(name: queryItem, value: value)

        // Append the new query item in the existing query items array
        queryItems.append(queryItem)

        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems

        // Returns the url from new url components
        return urlComponents.url!
    }
}

extension HTTPURLResponse {
    func isResponseOK() -> Bool {
        return (200...299).contains(self.statusCode)
    }
}
