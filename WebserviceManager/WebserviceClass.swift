//
//  WebserviceClass.swift
//  Muhnndi
//
//  Created by sureshkumar on 03/03/18.
//  Copyright © 2018 sureshkumar. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

public typealias APIDictionary = Dictionary<String, Any>

enum BackendError: Error {
    case network(error: Error) // Capture any underlying Error from the URLSession API
    case dataSerialization(error: Error)
    case jsonSerialization(error: Error)
    case xmlSerialization(error: Error)
    case objectSerialization(reason: String)
}

class WebserviceClass {
    
    static let sharedAPI : WebserviceClass = WebserviceClass()
    
    typealias Response<T> = (_ result: AFDataResponse<T>) -> Void
       
       private let manager = NetworkReachabilityManager(host: "https://prod.i2-donate.com/admin/")

       func isNetworkReachable() -> Bool {
           return manager?.isReachable ?? false
       }
       
    func performRequest <T:Codable>(type: T.Type, urlString:String, methodType: HTTPMethod ,parameters:Parameters, success:@escaping ((T) -> Void), failure: @escaping ((T) -> Void)) -> Void {
        
        print("parameters", parameters)
        
        var param = parameters
        
        if let password = KeychainService.loadPassword() {
            param["device_id"] = password
        } else {
            KeychainService.savePassword(token: UUID().uuidString as NSString)
            param["device_id"] = KeychainService.loadPassword()
        }
        
        print("**************************")
        
        print("Request param", param)
        print("Request urlString", urlString)

        print("**************************")

            
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = methodType.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        AF.request(request).responseString { response in

            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)

            switch response.result {
            case .success(_):
                if let data = response.data {
                    print(response.result)
                    // Convert This in JSON
                    do {
                        let utf8Data = String(decoding: data, as: UTF8.self).data(using: .utf8)
                        let responseDecoded = try JSONDecoder().decode(T.self, from: utf8Data!)
                        success(responseDecoded)
                    }catch let error as NSError{
                        print(error)
                    }

                }
            case .failure(let error):
                print("Error:", error)
            }

        }
        
    }
    
//    func performRequestWeb <T:Codable>(type: T.Type, urlString:String, methodType: HTTPMethod ,parameters:Parameters, success:@escaping (([String: Any]) -> Void), failure: @escaping (([String: Any]) -> Void)) -> Void {
//
//        print("parameters", parameters)
//
//        let url = URL(string: urlString)!
//        var request = URLRequest(url: url)
//        request.httpMethod = methodType.rawValue
//        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
//        } catch let error {
//            print(error.localizedDescription)
//        }
//
//        AF.request(request).responseJSON { response in
//
//            switch response.result {
//            case .success(let value):
//                if let json = value as? [String: Any] {
//                    print("Result venam", json)
//                    success(json)
//                }
//            case .failure(let error):
//                print("Error:", error)
//            }
//
//        }
//    }
    
//    func performRequest <T: AnyObject> (type: T.Type,urlString : String,_ methodType : HTTPMethod , success :@escaping (_ response : DataResponse<T>) -> Void , failure : @escaping (( _ response : DataResponse<T>,_ error :NSError?) -> Void))->Void where T:Mappable {
//
//
//        //        Alamofire.request(urlString, method: methodType, parameters: params, encoding:
//        //            JSONEncoding.default).responseObject { (response: DataResponse<[T]>) in
//
//        Alamofire.request(urlString, method: methodType, encoding: JSONEncoding.prettyPrinted)
//            .responseObject { (response: DataResponse<T>) in
//
//                print("Request: \(String(describing: response.request))")   // original url request
//                print("Response: \(String(describing: response.response))") // http url response
//                print("Result: \(response.result)")                     // response serialization result
//
//                if let json = response.result.value {
//                    print("JSON: \(json)") // serialized json response
//                }
//
//                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                    print("Data: \(utf8Text)") // original server data as UTF8 string
//                }
//
//                switch response.result {
//                case .success:
//                    print("Validation Successful")
//                    success(response)
//
//                case .failure(let error):
//                    print(error)
//                    if let err = error as? URLError, err.code == .notConnectedToInternet {
//                        let window: UIWindow? = (UIApplication.shared.delegate?.window)!
//                       _ = UIAlertController().showSimpleAlertWithMessage(NSLocalizedString("ALERT", comment: ""), message: NSLocalizedString("Please check your internet connection", comment: ""), view: (window?.rootViewController)!)
//                        failure(response,error as NSError)
//                    } else {
//                        failure(response,error as NSError)
//                    }
//                }
//
//        }
//    }
//
//    func performGetArrayRequest <T: AnyObject> (type: T.Type,urlString : String,_ methodType : HTTPMethod ,  success :@escaping (_ response : DataResponse<[T]>) -> Void , failure : @escaping (( _ response : DataResponse<[T]>,_ serror :BackendError) -> Void))->Void where T:Mappable {
//
//        Alamofire.request(urlString, method: methodType,  encoding: JSONEncoding.default)
//            .responseArray { (response: DataResponse<[T]>) in
//
//                if let json = response.result.value {
//                    print("JSON: \(json)") // serialized json response
//                }
//
//                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                    print("Data: \(utf8Text)") // original server data as UTF8 string
//                }
//                switch response.result {
//                case .success:
//                    print("Validation Successful")
//                    success(response)
//
//                case .failure(let error):
//                    print(error)
//                    if let err = error as? URLError, err.code == .notConnectedToInternet {
//                        let window: UIWindow? = (UIApplication.shared.delegate?.window)!
//                       _ = UIAlertController().showSimpleAlertWithMessage(NSLocalizedString("ALERT", comment: ""), message: NSLocalizedString("Please check your internet connection", comment: ""), view: (window?.rootViewController)!)
//                        failure(response,BackendError.jsonSerialization(error: error))
//                    } else {
//                        failure(response,BackendError.jsonSerialization(error: error))
//                    }
//                }
//        }
//    }
//
//    func performPostRequest <T: AnyObject> (type: T.Type,urlString : String,_ params :Parameters,_ methodType : HTTPMethod , success :@escaping (_ response : DataResponse<T>) -> Void , failure : @escaping (( _ response : DataResponse<T>,_ error :NSError?) -> Void))->Void where T:Mappable {
//
//        Alamofire.request(urlString, method: methodType,parameters: params, encoding: JSONEncoding.default)
//            .responseObject { (response: DataResponse<T>) in
//
//                print("Request: \(String(describing: response.request))")   // original url request
//                print("Response: \(String(describing: response.response))") // http url response
//                print("Result: \(response.result)")                     // response serialization result
//
//                if let json = response.result.value {
//                    print("JSON: \(json)") // serialized json response
//                }
//
//                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                    print("Data: \(utf8Text)") // original server data as UTF8 string
//                }
//
//                switch response.result {
//                case .success:
//                    print("Validation Successful")
//                    success(response)
//
//                case .failure(let error):
//                    print(error)
//                    if let err = error as? URLError, err.code == .notConnectedToInternet {
//                        let window: UIWindow? = (UIApplication.shared.delegate?.window)!
//                      _ = UIAlertController().showSimpleAlertWithMessage(NSLocalizedString("ALERT", comment: ""), message: NSLocalizedString("Please check your internet connection", comment: ""), view: (window?.rootViewController)!)
//
//                        failure(response,error as NSError)
//
//                    } else {
//                        failure(response,error as NSError)
//                    }
//                }
//
//        }
//
//
//
//
//
//    }
//
//    func performPostStringRequest <T: AnyObject> (type: T.Type,urlString :String,_body : String,_methodType :HTTPMethod,success :@escaping (_ response : DataResponse<T>) -> Void , failure : @escaping (( _ response : DataResponse<T>,_ error :NSError?) -> Void))->Void where T:Mappable {
//        let jsonData = _body.data(using: .utf8, allowLossyConversion: false)!
//        let url = URL(string: urlString)!
//        var request = URLRequest(url: url)
//        request.httpMethod = HTTPMethod.post.rawValue
//        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//        Alamofire.request(request).responseObject {
//            (response: DataResponse<T>) in
//
//            print("Request: \(String(describing: response.request))")   // original url request
//            print("Response: \(String(describing: response.response))") // http url response
//            print("Result: \(response.result)")                     // response serialization result
//
//            if let json = response.result.value {
//                print("JSON: \(json)") // serialized json response
//            }
//
//            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                print("Data: \(utf8Text)") // original server data as UTF8 string
//            }
//
//            switch response.result {
//            case .success:
//                print("Validation Successful")
//                success(response)
//
//            case .failure(let error):
//                print(error)
//                if let err = error as? URLError, err.code == .notConnectedToInternet {
//                    let window: UIWindow? = (UIApplication.shared.delegate?.window)!
//                    UIAlertController().showSimpleAlertWithMessage(NSLocalizedString("ALERT", comment: ""), message: NSLocalizedString("NO_INTERNET", comment: ""), view: (window?.rootViewController)!)
//
//                } else {
//                    failure(response,error as NSError)
//                }
//            }
//
//        }
//
//    }
//
//    func performPostArrayRequest <T: AnyObject> (type: T.Type,urlString : String,_ params :Parameters,_ methodType : HTTPMethod , success :@escaping (_ response : DataResponse<[T]>) -> Void , failure : @escaping (( _ response : DataResponse<[T]>,_ error :NSError?) -> Void))->Void where T:Mappable {
//
//
//        Alamofire.request(urlString, method: methodType, parameters: params, encoding: JSONEncoding.default).responseArray { (response: DataResponse<[T]>) in
//
//
//            print("Request: \(String(describing: response.request))")   // original url request
//            print("Response: \(String(describing: response.response))") // http url response
//            print("Result: \(response.result)")                     // response serialization result
//
//            if let json = response.result.value {
//                print("JSON: \(json)") // serialized json response
//            }
//
//            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                print("Data: \(utf8Text)") // original server data as UTF8 string
//            }
//
//            switch response.result {
//            case .success:
//                print("Validation Successful")
//                success(response)
//
//            case .failure(let error):
//                print(error)
//                if let err = error as? URLError, err.code == .notConnectedToInternet {
//                    let window: UIWindow? = (UIApplication.shared.delegate?.window)!
//                    UIAlertController().showSimpleAlertWithMessage(NSLocalizedString("ALERT", comment: ""), message: NSLocalizedString("NO_INTERNET", comment: ""), view: (window?.rootViewController)!)
//
//                } else {
//                    failure(response,error as NSError)
//                }
//            }
//
//        }
//
//
//
//
//    }
//
//
    
    
    
    
    
    
}
