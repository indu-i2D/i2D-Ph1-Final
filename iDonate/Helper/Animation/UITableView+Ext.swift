import UIKit

extension UITableView {
    /// Checks if the cell at the given indexPath is the last visible cell in the table view.
    ///
    /// - Parameter indexPath: The indexPath of the cell to check.
    /// - Returns: `true` if the cell at the specified indexPath is the last visible cell, `false` otherwise.
    func isLastVisibleCell(at indexPath: IndexPath) -> Bool {
        // Retrieve the last indexPath from the array of currently visible rows.
        guard let lastIndexPath = indexPathsForVisibleRows?.last else {
            // If there are no visible rows, return false.
            return false
        }

        // Compare the provided indexPath with the last visible indexPath.
        return lastIndexPath == indexPath
    }
}
