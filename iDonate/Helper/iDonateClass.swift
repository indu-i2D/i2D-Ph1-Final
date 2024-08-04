//
//  iDonateClass.swift
//  i2-Donate


import UIKit

/// Class providing utility functions related to iDonate.
class iDonateClass: NSObject {
    
    /// Singleton instance of `iDonateClass`.
    static let sharedClass : iDonateClass = iDonateClass()
    
    /// Checks if the device has safe area.
    static var hasSafeArea: Bool {
        guard #available(iOS 11.0, *), let topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top, topPadding > 24 else {
            return false
        }
        return true
    }
    
    /// Configures a custom appearance for the search bar.
    ///
    /// - Parameter searchBar: The search bar to be customized.
    func customSearchBar(searchBar: UISearchBar) {
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar?.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = ivoryColor
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = ivoryColor
        let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(UIImage(named: "clearbtn"), for: .normal)
        clearButton.tintColor = ivoryColor
    }
    
}
