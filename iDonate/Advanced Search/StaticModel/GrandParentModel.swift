//
//  GrandParentModel.swift
//  YBMultiLevelTableView
//

import Foundation

/// Represents a model for a grandparent in a family hierarchy.
class GrandParentModel: NSObject {
    
    /// The name of the grandparent.
    var grandParentName = ""
    
    /// An array containing instances of `ParentModel`.
    var parentMArr = [ParentModel]()
    
    /// The depth level of the grandparent in the hierarchy.
    var depthLevel = 0
    
    /// Indicates whether the grandparent is expanded.
    var isExpanded = false
    
    /// Indicates whether the grandparent has child elements.
    var hasChild = false
    
    /// Indicates whether the grandparent is selected.
    var isSelected = false
    
    /// Initializes a `GrandParentModel` instance with data from a dictionary.
    ///
    /// - Parameter dataDict: A dictionary containing grandparent data, including an array of parent data.
    init(dataDict: Dictionary<String, Any>) {
        super.init()
        grandParentName = dataDict["grandParentName"] as! String
        let parentArr = dataDict["parent"] as! Array<Any>
        for item in parentArr {
            let parentM = ParentModel(dataDict: item as! Dictionary<String, Any>)
            parentMArr.append(parentM)
        }
    }
}
