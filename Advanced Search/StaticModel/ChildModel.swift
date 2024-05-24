//
//  ChildModel.swift
//  YBMultiLevelTableView
//

import Foundation

/// Represents a model for a child node in a multi-level table view.
class ChildModel: NSObject {
    
    /// The name of the child.
    var childName = ""
    
    /// The name of the toy associated with the child.
    var toyName = ""
    
    /// The depth level of the child in the multi-level hierarchy.
    var depthLevel = 2
    
    /// A Boolean value indicating whether the child is expanded or collapsed in the table view.
    var isExpanded = false
    
    /// A Boolean value indicating whether the child is selected.
    var isSelected = false
    
    /// Initializes a ChildModel instance with data from a dictionary.
    ///
    /// - Parameter dataDict: A dictionary containing child data, including the child's name.
    init(dataDict : Dictionary<String, Any>) {
        super.init()
        childName = dataDict["childName"] as! String
    }
}
