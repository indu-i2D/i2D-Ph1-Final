//
//  ParentModel.swift
//  YBMultiLevelTableView
//

import Foundation

/// Represents a model for a parent in a family hierarchy.
class ParentModel: NSObject {
    
    /// The name of the parent.
    var parentName = ""
    
    /// An array containing instances of `ChildModel`.
    var childMArr = [ChildModel]()
    
    /// The depth level of the parent in the hierarchy.
    var depthLevel = 1
    
    /// Indicates whether the parent is expanded.
    var isExpanded = false
    
    /// Indicates whether the parent has child elements.
    var hasChild = false
    
    /// Indicates whether the parent is selected.
    var isSelected = false
    
    /// Indicates whether the parent's header is selected.
    var isHeaderSelected = false
    
    /// Initializes a `ParentModel` instance with data from a dictionary.
    ///
    /// - Parameter dataDict: A dictionary containing parent data, including an array of child data.
    init(dataDict: Dictionary<String, Any>) {
        super.init()
        parentName = dataDict["parentName"] as! String
        let childArr = dataDict["child"] as! Array<Any>
        for item in childArr {
            let topicM = ChildModel(dataDict: item as! Dictionary<String, Any>)
            childMArr.append(topicM)
        }
    }
}
