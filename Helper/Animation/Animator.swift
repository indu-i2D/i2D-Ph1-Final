//
//  Animator.swift
//  UITableViewCellAnimation-Article
//



import UIKit

/// A final class to handle the animation of table view cells

final class Animator {
    // MARK: - Properties
    
    // A boolean flag to check if all cells have been animated
    private var hasAnimatedAllCells = false
    // The animation closure that will be executed for each cell
    private let animation: Animation

    // MARK: - Initializer
    
    // Initializes the Animator with a given animation closure
    init(animation: @escaping Animation) {
        self.animation = animation
    }

    /**
         Animate the given cell at the specified index path in the provided table view.
         
         - Parameters:
            - cell: The UITableViewCell to animate.
            - indexPath: The IndexPath of the cell in the table view.
            - tableView: The UITableView containing the cell.
         */
        func animate(cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
            // If all cells have already been animated, return early
            guard !hasAnimatedAllCells else {
                return
            }

            // Execute the animation closure
            animation(cell, indexPath, tableView)
            // Check if the current cell is the last visible cell in the table view
            hasAnimatedAllCells = tableView.isLastVisibleCell(at: indexPath)
        }
    }
