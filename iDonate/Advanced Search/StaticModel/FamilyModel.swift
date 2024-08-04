//
//  FamilyModel.swift
//  YBMultiLevelTableView
//

import Foundation

/// Represents a model for a family hierarchy.
class FamilyModel: NSObject {
    
    /// An array containing instances of `GrandParentModel`.
    var grandParentMArr = [GrandParentModel]()
    
    /// Initializes a `FamilyModel` instance with data from a dictionary.
    ///
    /// - Parameter dataDict: A dictionary containing family data, including an array of grandparent data.
    init(dataDict: Dictionary<String, Any>) {
        super.init()
        let grandParentList = dataDict["grandParent"] as! Array<Any>
        for item in grandParentList {
            let grandparentM = GrandParentModel(dataDict: item as! Dictionary<String, Any>)
            grandParentMArr.append(grandparentM)
        }
    }
}
