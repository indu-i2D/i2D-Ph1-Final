import CommonCrypto
import UIKit
import WebKit

/// Struct to hold basic user information
struct UserInfo {
    let userfName: String
    let userlName: String
    let userEmail: String
}

/// Struct to represent input parameters for requesting OAuth tokens
struct RequestOAuthTokenInput {
    let consumerKey: String
    let consumerSecret: String
    let callbackScheme: String
}

/// Struct to represent the response received after requesting OAuth tokens
struct RequestOAuthTokenResponse {
    let oauthToken: String
    let oauthTokenSecret: String
    let oauthCallbackConfirmed: String
}

/// Struct to represent input parameters for requesting access tokens
struct RequestAccessTokenInput {
    let consumerKey: String
    let consumerSecret: String
    let requestToken: String
    let requestTokenSecret: String
    let oauthVerifier: String
}

/// Struct to represent the response received after requesting access tokens
struct RequestAccessTokenResponse {
    let accessToken: String
    let accessTokenSecret: String
    let userId: String
    let screenName: String
}

/// Enum to enumerate different actions such as login or posting updates to Twitter
enum Action {
    case isLogin
    case postUpdate(String)
}

/// Struct containing parameters required for email verification
struct EmailIdVerification {
    let requestToken: String
    let requestTokenSecret: String
    let email: String
    let userfName: String
    let userlName: String
    let userProfileUrl:String
}

// typealias for Credentials
public typealias Credentials = (key: String, secret: String)

/// Class to handle Twitter authentication and interaction
class TwitterHandler: NSObject {
   
    
    static let shared = TwitterHandler()
    
    // Properties to store Twitter consumer key, consumer secret, and URL scheme
    let TWITTER_CONSUMER_KEY:String = "pBjkBJoBpsMl1QHWsE1UjbAo2"
    let TWITTER_CONSUMER_SECRET:String = "RqkDXS2E84loXIursJlHeI8kh9fnVufaWLo4a8fN3XkrZiGl2D"
    let TWITTER_URL_SCHEME:String =  "twittersdk://"
    
    var TwitterOAuthToken = ""
    var twitterOAuthTokenSecretKey = ""
    
    var authToken: String!
    var authTokenSecret: String!
    
    // Callbacks for user information and failure scenarios
    typealias UserInfoCallBack = (EmailIdVerification) -> Void
    typealias failureCallback = () -> Void
    
    var userinfoCallback: UserInfoCallBack!
    var failuer: failureCallback!
    var VC: UIViewController!
    
    // Observer for handling URL responses
    var callbackObserver: Any? {
        willSet {
            // we will add and remove this observer on an as-needed basis
            guard let token = callbackObserver else { return }
            NotificationCenter.default.removeObserver(token)
        }
    }
}

// Extension to handle Twitter authentication
extension TwitterHandler {
    
    // Method to initiate Twitter login process
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
    // Mark This is for post the status in twitter
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
    
    // Method to authorize different actions such as login or posting updates
    private func authorize(_ vc: UIViewController, _ action: Action, _ complete: @escaping (Any?) -> Void) {
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
}

// Extension to handle network requests
extension TwitterHandler {
    // Method to request OAuth tokens
    private func getRequestToken(args: RequestOAuthTokenInput, _ complete: @escaping (RequestOAuthTokenResponse) -> Void) {
        // Implementation omitted for brevity
    }
    
    // Method to request access tokens
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
            debugPrint("Twitter:Data",data)
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
    // Method to get user email address
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
