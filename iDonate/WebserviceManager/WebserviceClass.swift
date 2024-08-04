import UIKit
import Alamofire
import MBProgressHUD
import SwiftyJSON

/// Typealias representing a dictionary with String keys and Any values.
public typealias APIDictionary = Dictionary<String, Any>

/// Enum representing possible backend errors.
enum BackendError: Error {
    case network(error: Error) // Capture any underlying Error from the URLSession API
    case dataSerialization(error: Error)
    case jsonSerialization(error: Error)
    case xmlSerialization(error: Error)
    case objectSerialization(reason: String)
}

/// Class handling web service requests.
class WebserviceClass {
    
    /// Singleton instance of `WebserviceClass`.
    static let sharedAPI : WebserviceClass = WebserviceClass()
    
    /// Response closure type for Alamofire requests.
    typealias Response<T> = (_ result: AFDataResponse<T>) -> Void
    
    /// Manager for network reachability.
    private let manager = NetworkReachabilityManager(host: "https://prod.i2-donate.com/admin/")
    
    /// Checks if the network is reachable.
    func isNetworkReachable() -> Bool {
        return manager?.isReachable ?? false
    }
    
    /// Performs a network request.
    /// - Parameters:
    ///   - isFileAdded: A boolean indicating if a file is added to the request.
    ///   - type: The type of response object.
    ///   - urlString: The URL string for the request.
    ///   - methodType: The HTTP method type.
    ///   - parameters: The parameters for the request.
    ///   - success: The success closure to be executed upon successful response.
    ///   - failure: The failure closure to be executed upon failed response.
    func performRequest<T: Codable>(isFileAdded: Bool = false, type: T.Type, urlString: String, methodType: HTTPMethod, parameters: Parameters, success: @escaping ((T) -> Void), failure: @escaping ((T) -> Void)) -> Void {
        
        var param = parameters
        
        if let password = KeychainService.loadPassword() {
            param["device_id"] = password
        } else {
            KeychainService.savePassword(token: UUID().uuidString as NSString)
            param["device_id"] = KeychainService.loadPassword()
        }
        
        print("**************************")
        print("Request urlString", urlString)
        print("**************************")
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = methodType.rawValue
        if isFileAdded {
            request.setValue("multipart/form-data; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        } else {
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        AF.request(request).responseString { response in
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            
            switch response.result {
            case .success(_):
                if let data = response.data {
                    // Convert data to JSON
                    do {
                        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                        print(JSON(json))
                        let utf8Data = String(decoding: data, as: UTF8.self).data(using: .utf8)
                        let responseDecoded = try JSONDecoder().decode(T.self, from: utf8Data!)
                        success(responseDecoded)
                    } catch let error as NSError {
                        print(error)
                    }
                }
            case .failure(let error):
                print("Error:", error)
            }
        }
    }
}
