//
//  UIALertController + DAlert.swift
//  swiftExamples
//
//  Created by sureshkumar on 3/3/18.
//  Copyright © 2018 sureshkumar. All rights reserved.
//

import UIKit

typealias okMethod = () -> Void
typealias otherMethod = () -> Void

typealias clickMethod = (_ indexOfButton : NSInteger) -> Void

extension UIAlertController
{
    /* Alert with OK Action Block -- Two Static Buttons*/
    
    func showDefaultAlert ( _ title : String , message : String , view : UIViewController, okAction : @escaping okMethod) -> UIAlertController
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: SwiftHelper.LocalizedSwiftString(key: "CANCEL", Comment: ""), style: .cancel, handler: nil ))
        
        
        alert.addAction(UIAlertAction(title: SwiftHelper.LocalizedSwiftString(key: "OK", Comment: ""), style: .default, handler: { (action:UIAlertAction) -> Void in
            okAction()
        }))
        view.present(alert, animated: true , completion: nil)
        return alert
    }
    
    func showDefaultAlertWithBlocks ( _ title : String , message : String , view : UIViewController, okAction : @escaping okMethod, otherAction : @escaping otherMethod) -> UIAlertController{
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: SwiftHelper.LocalizedSwiftString(key: "CANCEL", Comment: ""), style: .default, handler: { (action:UIAlertAction) -> Void in
            otherAction()
        }))
        
        alert.addAction(UIAlertAction(title: SwiftHelper.LocalizedSwiftString(key: "OK", Comment: ""), style: .default, handler: { (action:UIAlertAction) -> Void in
            okAction()
        }))
        
        view.present(alert, animated: true , completion: nil)
        return alert
    }
    
    /* Dynamic ActionSheet */
    
    func showActionSheet ( _ title : String , message : String , view : UIViewController , buttonNames : NSArray , clickAction : @escaping clickMethod ) -> UIAlertController
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for opt in buttonNames
        {
            alert.addAction(UIAlertAction(title: opt as? String, style: .default, handler: { (actionIndex : UIAlertAction) -> Void in
                let index : NSInteger = alert.actions.index(of: actionIndex)! as NSInteger
                clickAction(index)
            }))
        }
        alert.addAction(UIAlertAction(title: SwiftHelper.LocalizedSwiftString(key: "CANCEL", Comment: ""), style: .cancel, handler: nil ))
        view.present(alert, animated: true , completion: nil)
        return alert
    }
    
    /* Alert with only OK Button */
    
    func showSimpleAlertWithOKBlock ( _ title : String , message : String , view : UIViewController, okAction : @escaping okMethod) -> UIAlertController{
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: SwiftHelper.LocalizedSwiftString(key: "OK", Comment: ""), style: .default, handler: { (action:UIAlertAction) -> Void in
            okAction()
        }))
        
        view.present(alert, animated: true , completion: nil)
        return alert
        
    }
    
    func showSimpleAlertWithMessage ( _ title : String , message : String , view : UIViewController) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: SwiftHelper.LocalizedSwiftString(key: "OK", Comment: ""), style: .default, handler: { (action:UIAlertAction) -> Void in
        }))

        view.present(alert, animated: true , completion: nil)
        return alert
        
    }

    
    /* Custom Alerts with Blocks */
    
    func showCustomAlertsWithBlocks ( _ title : String , message : String, buttonOneTitle : String, buttonTwoTitle : String , view : UIViewController, okAction : @escaping okMethod, otherAction : @escaping otherMethod) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: buttonOneTitle, style: .default, handler: { (action:UIAlertAction) -> Void in
            okAction()
        }))
        if buttonTwoTitle.count > 0 {
            alert.addAction(UIAlertAction(title: buttonTwoTitle, style: .default, handler: { (action:UIAlertAction) -> Void in
                otherAction()
            }))
        }
        view.present(alert, animated: true , completion: nil)
        return alert
    }
}
