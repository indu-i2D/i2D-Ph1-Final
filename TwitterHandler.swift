//
//  TwitterHandler.swift
//  ClientSDK
//
//  Created by Narendh S on 18/03/20.
//  Copyright © 2020 Photon. All rights reserved.
//

import CommonCrypto
import UIKit
import WebKit



struct UserInfo {
    let userfName: String
    let userlName: String
    let userEmail: String
}

struct RequestOAuthTokenInput {
    let consumerKey: String
    let consumerSecret: String
    let callbackScheme: String
}

struct RequestOAuthTokenResponse {
    let oauthToken: String
    let oauthTokenSecret: String
    let oauthCallbackConfirmed: String
}

struct RequestAccessTokenInput {
    let consumerKey: String
    let consumerSecret: String
    let requestToken: String // = RequestOAuthTokenResponse.oauthToken
    let requestTokenSecret: String // = RequestOAuthTokenResponse.oauthTokenSecret
    let oauthVerifier: String
}

struct RequestAccessTokenResponse {
    let accessToken: String
    let accessTokenSecret: String
    let userId: String
    let screenName: String
}

enum Action {
    case isLogin
    case postUpdate(String)
}

struct EmailIdVerification {
    let requestToken: String // = RequestOAuthTokenResponse.oauthToken
    let requestTokenSecret: String // = RequestOAuthTokenResponse.oauthTokenSecret
    let email: String
    let userfName: String
    let userlName: String
    let userProfileUrl:String
}

public typealias Credentials = (key: String, secret: String)

class TwitterHandler: NSObject {
    static let shared = TwitterHandler()
    
//    let TWITTER_CONSUMER_KEY:String = "pBjkBJoBpsMl1QHWsE1UjbAo2"
//    let TWITTER_CONSUMER_SECRET:String = "RqkDXS2E84loXIursJlHeI8kh9fnVufaWLo4a8fN3XkrZiGl2D"
//    let TWITTER_URL_SCHEME:String =  "twittersdk://"
    
//    let TWITTER_CONSUMER_KEY:String = "sXfgjfy9RL4DRzOO2Ddjv7wpi"
//    let TWITTER_CONSUMER_SECRET:String = "06XQnd7BZpBoGIYGpYar4320hhwFTqAbXxpT4r1cTLON0rGkjE"
//    let TWITTER_URL_SCHEME:String =  "twittersdk://"
    
//    let TWITTER_CONSUMER_KEY:String = "gTCp2m4y7bTtHXDDX9b08BD6m"
//    let TWITTER_CONSUMER_SECRET:String = "te8JVdZf5dm9tAcdFBt3qEnc42Xz9qq9UBQ5Jl7LNFAkTfH2Tw"
//    let TWITTER_URL_SCHEME:String =  "twittersdk://"
//
    let TWITTER_CONSUMER_KEY:String = "pBjkBJoBpsMl1QHWsE1UjbAo2"
    let TWITTER_CONSUMER_SECRET:String = "RqkDXS2E84loXIursJlHeI8kh9fnVufaWLo4a8fN3XkrZiGl2D"
    let TWITTER_URL_SCHEME:String =  "twittersdk://"
//
    var TwitterOAuthToken = ""
    var twitterOAuthTokenSecretKey = ""
    
    var authToken: String!
    var authTokenSecret: String!
    
    typealias UserInfoCallBack = (EmailIdVerification) -> Void
    typealias failureCallback = () -> Void
    
    var userinfoCallback: UserInfoCallBack!
    var failuer: failureCallback!
    var VC: UIViewController!
    
    var callbackObserver: Any? {
        willSet {
            // we will add and remove this observer on an as-needed basis
            guard let token = callbackObserver else { return }
            NotificationCenter.default.removeObserver(token)
        }
    }
    
//    // Initialize Twitter API client
//    let client = TWTRAPIClient()
//
//    // Request access to user's email address
//    func client.requestEmail { email, error in
//        if let error = error {
//            print("Error requesting email: \(error.localizedDescription)")
//        } else if let email = email {
//            print("User's email address: \(email)")
//        } else {
//            print("No email address provided by user")
//        }
//    }
//
    
}

extension TwitterHandler {
    public func loginWithTwitter(_ VCc: UIViewController, _ complete: @escaping UserInfoCallBack, _ failureback: @escaping failureCallback) {
        VC = VCc
        authorize(VCc, .isLogin) { url in
            print("Twitter URL : \(String(describing: url))")
            self.userinfoCallback = complete
            self.failuer = failureback
        }
    }
    
    private func openWebviewWithAction(authorizationURL: URL) {
                
        let webViewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TwitterWebViewController") as? TwitterWebViewController
        
        //storyboard.instantiateViewController(withIdentifier: "webViewController") as! PLWebViewController
        webViewController?.webViewMode = WebViewMode.urlRequestMode
        webViewController?.twitterDelegate = self
//        webViewController?.loginType = .Twitter
        webViewController?.loadUrl = authorizationURL
        webViewController?.title = "Twitter_signIn"
        VC.view.isUserInteractionEnabled = true
        VC.present(webViewController!, animated: true, completion: nil)
//        VC.navigationController?.pushViewController(webViewController!, animated: true)
    }
    
    func authorize(_ vc: UIViewController, _ action: Action, _ complete: @escaping (Any?) -> Void) {
        VC = vc
        
        // Start Step 1: Requesting an access token
        let oAuthTokenInput = RequestOAuthTokenInput(consumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET, callbackScheme: TWITTER_URL_SCHEME)
        
        getRequestToken(args: oAuthTokenInput) { oAuthTokenResponse in
            // Start Step 2: User Twitter Login
            self.authToken = oAuthTokenResponse.oauthToken
            self.authTokenSecret = oAuthTokenResponse.oauthTokenSecret
            
            switch action {
            case .isLogin:
                let urlString = "https://api.twitter.com/oauth/authenticate?oauth_token=\(oAuthTokenResponse.oauthToken)"
                print("Twitter urlstring : \(urlString)")
                
                guard let oauthUrl = URL(string: urlString) else { return }
                DispatchQueue.main.async {
                    self.openWebviewWithAction(authorizationURL: oauthUrl)
                    
                    complete(oauthUrl)
                }
            case .postUpdate(let messagePost):
                let accessTokenInput = RequestAccessTokenInput(consumerKey: self.TWITTER_CONSUMER_KEY, consumerSecret: self.TWITTER_CONSUMER_SECRET, requestToken: self.authToken, requestTokenSecret: self.authTokenSecret, oauthVerifier: "")
                
                self.composeTweet(args: accessTokenInput, messagePost: messagePost) {
                    DispatchQueue.main.async {
                        complete("success")
                    }
                }
            }
        }
    }
    
   private func showErrorAlert(title: String, message: String) {
        let alertController = PLAlertViewController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            self.VC.dismiss(animated: true, completion: nil)
            self.VC.navigationController?.popViewController(animated: true)
        })
        alertController.addAction(ok)
        alertController.show()
    }
}

extension TwitterHandler {
   private func getRequestToken(args: RequestOAuthTokenInput, _ complete: @escaping (RequestOAuthTokenResponse) -> Void) {
        let cc = (key: TWITTER_CONSUMER_KEY, secret: TWITTER_CONSUMER_SECRET)
        let request = (url: "https://api.twitter.com/oauth/request_token", httpMethod: "POST")
//       let callback = "twitterkit-pBjkBJoBpsMl1QHWsE1UjbAo2"
       let callback = args.callbackScheme // + "://success"
       
        // Build the OAuth Signature
        let params: [String: String] = [
            "oauth_callback": callback
        ]
        guard let url = URL(string: request.url) else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.signOAuth1(method: "POST", urlFormParameters: params, consumerCredentials: cc)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
            guard let data = data else { return }
            guard let dataString = String(data: data, encoding: .utf8) else { return }
            
            let attributes = dataString.urlQueryStringParameters
            print("TWTR-request_token: \(attributes)")
            let result = RequestOAuthTokenResponse(oauthToken: attributes["oauth_token"] ?? "",
                                                   oauthTokenSecret: attributes["oauth_token_secret"] ?? "",
                                                   oauthCallbackConfirmed: attributes["oauth_callback_confirmed"] ?? "")
            
            complete(result)
        }
        
        task.resume()
    }
    
   private func getAccessToken(args: RequestAccessTokenInput, _ complete: @escaping (RequestAccessTokenResponse) -> Void) {
        let cc = (key: TWITTER_CONSUMER_KEY, secret: TWITTER_CONSUMER_SECRET)
        let uc = (key: args.requestToken, secret: args.requestTokenSecret)
        let request = (url: "https://api.twitter.com/oauth/access_token", httpMethod: "POST")
        
        // Build the OAuth Signature
        let params: [String: String] = [
            "oauth_verifier": args.oauthVerifier
        ]
        
        guard let url = URL(string: request.url) else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.signOAuth1(method: "POST", urlFormParameters: params, consumerCredentials: cc, userCredentials: uc)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
            guard let data = data else { return }
            guard let dataString = String(data: data, encoding: .utf8) else { return }
            
            print("Twitter access_token dataString : \(dataString)")
            
            let attributes = dataString.urlQueryStringParameters
            print(attributes)
            print("Auth Token 4 \(attributes["oauth_token"] ?? "")")
            
            let result = RequestAccessTokenResponse(accessToken: attributes["oauth_token"] ?? "",
                                                    accessTokenSecret: attributes["oauth_token_secret"] ?? "",
                                                    userId: attributes["user_id"] ?? "",
                                                    screenName: attributes["screen_name"] ?? "")
            
            complete(result)
        }
        
        task.resume()
    }
    
   private func getTwitterEmail(url: URL, _ complete: @escaping (EmailIdVerification) -> Void) {
        guard let parameters = url.query?.urlQueryStringParameters else { return }
        
        /*
         url => twittersdk://success?oauth_token=XXXX&oauth_verifier=ZZZZ
         url.query => oauth_token=XXXX&oauth_verifier=ZZZZ
         url.query?.urlQueryStringParameters => ["oauth_token": "XXXX", "oauth_verifier": "YYYY"]
         */
        guard let verifier = parameters["oauth_verifier"] else { return }
        guard let oauthToken = authToken else { return }
        guard let oauthTokenkey = authTokenSecret else { return }
        
        let accessTokenInput = RequestAccessTokenInput(consumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET, requestToken: oauthToken, requestTokenSecret: oauthTokenkey, oauthVerifier: verifier)
      
        getAccessToken(args: accessTokenInput) { resp in
            print("Twitter email resp : \(resp)")
            
            self.getEmailAddress(args: resp) { userinfo in
                complete(userinfo)
            }
        }
    }
    
   private func getEmailAddress(args: RequestAccessTokenResponse, _ complete: @escaping (EmailIdVerification) -> Void) {
        let cc = (key: TWITTER_CONSUMER_KEY, secret: TWITTER_CONSUMER_SECRET)
        let uc = (key: args.accessToken, secret: args.accessTokenSecret)
        let urls = "https://api.twitter.com/1.1/account/verify_credentials.json?include_name=true"
        let request = (url: urls, httpMethod: "GET")
        
        
        TwitterOAuthToken = args.accessToken
        twitterOAuthTokenSecretKey = args.accessTokenSecret

        
        guard let url = URL(string: request.url) else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.signOAuth1(method: "GET", urlFormParameters: [:], consumerCredentials: cc, userCredentials: uc)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let data = data else { return }
            guard let dataString = String(data: data, encoding: .utf8) else { return }
            
            //            let attributes = dataString.urlQueryStringParameters
            print(data)
            print("Twitter verify_credentials dataString : \(dataString)")
            
            DispatchQueue.main.async {
                if let response = response as? HTTPURLResponse, response.isResponseOK() {
                    if let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] {
                        print(json)
                        print(json["profile_image_url"])
                        if let Name: String = json["screen_name"] as? String  {
                            let userinfoEmail = EmailIdVerification(requestToken: args.accessToken, requestTokenSecret: args.accessTokenSecret, email: json["email"] as? String ?? "", userfName: json["name"] as? String ?? "", userlName: Name,userProfileUrl: json["profile_image_url"] as? String ?? "" )
                            complete(userinfoEmail)
                            print(Name)
                        } else {
                            self.showErrorAlert(title: "", message: "No Email Found")
                        }
                    } else {
                        self.showErrorAlert(title: "", message: dataString.getMessage())
                    }
                } else {
                    if let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] {
                        self.showErrorAlert(title: "", message: json["message"] as? String ?? dataString.getMessage())
                    } else {
                        self.showErrorAlert(title: "", message: dataString.getMessage())
                    }
                }
            }
        }
        
        task.resume()
    }
    
    // Mark This is for post the status in twitter and it working fine
  private  func composeTweet(args: RequestAccessTokenInput, messagePost: String, _ complete: @escaping () -> Void) {
        let cc = (key: TWITTER_CONSUMER_KEY, secret: TWITTER_CONSUMER_SECRET)
        let uc:Credentials = (key: TwitterOAuthToken, secret:  twitterOAuthTokenSecretKey)
        let messgaeEncrpt = messagePost.urlEncoded
        let body = "status=\(messgaeEncrpt)"
        let urls = "https://api.twitter.com/1.1/statuses/update.json?" + body
        let request = (url: urls, httpMethod: "POST")
        guard let url = URL(string: request.url) else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.signOAuth1(method: "POST", body: body.data(using: .utf8), contentType: "application/json", consumerCredentials: cc, userCredentials: uc)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let data = data else { return }
            guard let dataString = String(data: data, encoding: .utf8) else { return }
            
            print(dataString, data, response!,args)
            
            DispatchQueue.main.async {
                if let response = response as? HTTPURLResponse, response.isResponseOK() {
                    complete()
                } else {
                    self.showErrorAlert(title: "", message: dataString)
                }
            }
        }
        
        task.resume()
    }
}

extension TwitterHandler: TwitterTokenHandler {
    func receivedNoToken() {
        self.failuer()
    }
    
    func receivedOAuthToken(url: URL) {
        TwitterHandler.shared.getTwitterEmail(url: url) { userinfo in
//            PLUtility.saveSSOEmail(userinfo.email)
//            PLUtility.saveSSOFirstName(userinfo.userfName)
//            PLUtility.saveSSOLastName(userinfo.userlName)
//            PLUtility.saveSSOType("Twitter")
            
            print("userinfo", userinfo)
            
            self.userinfoCallback(userinfo)
        }
    }
}
