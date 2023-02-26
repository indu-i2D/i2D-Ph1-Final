//
//  iDonateClass.swift
//  iDonate
//
//  Created by sureshkumar on 05/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

class iDonateClass: NSObject {
    static let sharedClass : iDonateClass = iDonateClass()
    static var hasSafeArea: Bool {
        guard #available(iOS 11.0, *), let topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top, topPadding > 24 else {
            return false
        }
        return true
    }
    
    func customSearchBar(searchBar:UISearchBar)
    {
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = ivoryColor
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = ivoryColor
        let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as! UIButton
        //clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
        clearButton.setImage(UIImage(named: "clearbtn"), for: .normal)
        clearButton.tintColor = ivoryColor
        
    }
    
}


