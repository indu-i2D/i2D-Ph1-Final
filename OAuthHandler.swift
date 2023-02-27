//
//  OAuthHandler.swift
//  TwitterApi
//
//  Created by Nagendran Nagarajan on 3/27/20.
//  Copyright © 2020 narendh. All rights reserved.
//

//
//                Apache License, Version 2.0
//
//  Copyright 2017, Markus Wanke
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

/// # OhhAuth
/// ## Pure Swift implementation of the OAuth 1.0 protocol as an easy to use extension for the URLRequest type.
/// - Author: Markus Wanke
/// - Copyright: 2017

import CommonCrypto
import Foundation

extension URL {
    /// Transforms: "www.x.com?color=red&age=29" to ["color": "red", "age": "29"]
    func queryParameters() -> [String: String] {
        var res: [String: String] = [:]
        for qi in URLComponents(url: self, resolvingAgainstBaseURL: true)?.queryItems ?? [] {
            res[qi.name] = qi.value ?? ""
        }
        return res
    }

    /// [RFC-5849 Section 3.4.1.2](https://tools.ietf.org/html/rfc5849#section-3.4.1.2)
    func baseOAuth1URL() -> String {
        let scheme = self.scheme?.lowercased() ?? ""
        let host = self.host?.lowercased() ?? ""

        var authority = ""
        if let user = self.user, let pw = self.password {
            authority = user + ":" + pw + "@"
        }
        else if let user = self.user {
            authority = user + "@"
        }

        var port = ""
        if let iport = self.port, iport != 80, scheme == "http" {
            port = ":\(iport)"
        }
        else if let iport = self.port, iport != 443, scheme == "https" {
            port = ":\(iport)"
        }

        return scheme + "://" + authority + host + port + self.path
    }
}

public extension URLRequest {
    /// Easy to use method to sign a URLRequest which includes url-form parameters with OAuth.
    /// The request needs a valid URL with all query parameters etc. included.
    /// After calling this method the HTTP header fields: "Authorization", "Content-Type"
    /// and "Content-Length" should not be overwritten.
    ///
    /// - Parameters:
    ///   - method: HTTP Method
    ///   - paras: url-form parameters
    ///   - consumerCredentials: consumer credentials
    ///   - userCredentials: user credentials (nil if this is a request without user association)
    mutating func signOAuth1(method: String, urlFormParameters paras: [String: String],
                             consumerCredentials cc: Credentials, userCredentials uc: Credentials? = nil) {
        self.httpMethod = method.uppercased()

        let body = OAuthHandler.shared.httpBody(forFormParameters: paras)

        self.httpBody = body
        self.addValue(String(body?.count ?? 0), forHTTPHeaderField: "Content-Length")
        self.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let sig = OAuthHandler.shared.calculateSignature(url: self.url!, method: self.httpMethod!,
                                                         parameter: paras, consumerCredentials: cc, userCredentials: uc)

        self.addValue(sig, forHTTPHeaderField: "Authorization")
    }

    /// Easy to use method to sign a URLRequest which includes plain body data with OAuth.
    /// The request needs a valid URL with all query parameters etc. included.
    /// After calling this method the HTTP header fields: "Authorization", "Content-Type"
    /// and "Content-Length" should not be overwritten.
    ///
    /// - Parameters:
    ///   - method: HTTP Method
    ///   - body: HTTP request body (default: nil)
    ///   - contentType: HTTP header "Content-Type" entry (default: nil)
    ///   - consumerCredentials: consumer credentials
    ///   - userCredentials: user credentials (nil if this is a request without user association)
    mutating func signOAuth1(method: String, body: Data? = nil, contentType: String? = nil,
                             consumerCredentials cc: Credentials, userCredentials uc: Credentials? = nil) {
        self.httpMethod = method.uppercased()

        if let body = body {
            self.httpBody = body
            self.addValue(String(body.count), forHTTPHeaderField: "Content-Length")
        }

        if let ct = contentType {
            self.addValue(ct, forHTTPHeaderField: "Content-Type")
        }

        let sig = OAuthHandler.shared.calculateSignature(url: self.url!, method: self.httpMethod!,
                                                         parameter: [:], consumerCredentials: cc, userCredentials: uc)

        self.addValue(sig, forHTTPHeaderField: "Authorization")
    }
}

class OAuthHandler {
    static var shared: OAuthHandler = OAuthHandler()

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)

                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }

                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func rfc3986encode(_ str: String) -> String {
        struct Static {
            static let allowed = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._~"
            static let allowedSet = CharacterSet(charactersIn: allowed)
        }

        return str.addingPercentEncoding(withAllowedCharacters: Static.allowedSet) ?? str
    }

    private func oAuthDefaultParameters(consumerKey: String, userKey: String?) -> [String: String] {
        /// [RFC-5849 Section 3.1](https://tools.ietf.org/html/rfc5849#section-3.1)
        var defaults: [String: String] = [
            "oauth_consumer_key": consumerKey,
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_version": "1.0",
            "oauth_timestamp": String(Int(Date().timeIntervalSince1970)),
            "oauth_nonce": self.randomNonceString(),
        ]

        if let userKey = userKey {
            defaults["oauth_token"] = userKey
        }

        return defaults
    }
}

extension OAuthHandler {
    func httpBody(forFormParameters paras: [String: String], encoding: String.Encoding = .utf8) -> Data? {
        let trans: (String, String) -> String = { k, v in
            self.rfc3986encode(k) + "=" + self.rfc3986encode(v)
        }

        return paras.map(trans).joined(separator: "&").data(using: encoding)
    }
}

extension OAuthHandler {
    func calculateSignature(url: URL, method: String, parameter: [String: String], consumerCredentials cc: Credentials, userCredentials uc: Credentials?) -> String {
        typealias Tup = (key: String, value: String)

        let tuplify: (String, String) -> Tup = {
            (key: self.rfc3986encode($0), value: self.rfc3986encode($1))
        }
        let cmp: (Tup, Tup) -> Bool = {
            $0.key < $1.key
        }
        let toPairString: (Tup) -> String = {
            $0.key + "=" + $0.value
        }
        let toBrackyPairString: (Tup) -> String = {
            $0.key + "=\"" + $0.value + "\""
        }

        /// [RFC-5849 Section 3.1](https://tools.ietf.org/html/rfc5849#section-3.1)
        var oAuthParameters = self.oAuthDefaultParameters(consumerKey: cc.key, userKey: uc?.key)

        /// [RFC-5849 Section 3.4.1.3.1](https://tools.ietf.org/html/rfc5849#section-3.4.1.3.1)
        let signString: String = [oAuthParameters, parameter, url.queryParameters()]
            .flatMap { $0.map(tuplify) }
            .sorted(by: cmp)
            .map(toPairString)
            .joined(separator: "&")

        /// [RFC-5849 Section 3.4.1](https://tools.ietf.org/html/rfc5849#section-3.4.1)
        let signatureBase: String = [method, url.baseOAuth1URL(), signString]
            .map(self.rfc3986encode)
            .joined(separator: "&")

        /// [RFC-5849 Section 3.4.2](https://tools.ietf.org/html/rfc5849#section-3.4.2)
        let signingKey: String = [cc.secret, uc?.secret ?? ""]
            .map(self.rfc3986encode)
            .joined(separator: "&")

        /// [RFC-5849 Section 3.4.2](https://tools.ietf.org/html/rfc5849#section-3.4.2)
        let binarySignature = self.hashUsingHMACSHA1(signingKey: signingKey, signatureBase: signatureBase)
        oAuthParameters["oauth_signature"] = binarySignature

        /// [RFC-5849 Section 3.5.1](https://tools.ietf.org/html/rfc5849#section-3.5.1)
        return "OAuth " + oAuthParameters
            .map(tuplify)
            .sorted(by: cmp)
            .map(toBrackyPairString)
            .joined(separator: ",")
    }

    func hashUsingHMACSHA1(signingKey: String, signatureBase: String) -> String {
        // HMAC-SHA1 hashing algorithm returned as a base64 encoded string
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), signingKey, signingKey.count, signatureBase, signatureBase.count, &digest)
        let data = Data(digest)
        return data.base64EncodedString()
    }
}
