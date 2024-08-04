//
//  MoveUpWithBounceTableCellAnimator.swift
//  UITableViewCellAnimation-Article

import UIKit


typealias Animation = (UITableViewCell, IndexPath, UITableView) -> Void

// An enum to contain factory methods for creating different types of animations
enum AnimationFactory {
/**
 Creates a fade-in animation for table view cells.
 
 - Parameters:
    - duration: The duration of the animation.
    - delayFactor: A factor to calculate the delay for each cell based on its row index.
 - Returns: An `Animation` closure that performs the fade-in animation.
 */
    static func makeFade(duration: TimeInterval, delayFactor: Double) -> Animation {
            return { cell, indexPath, _ in
                // Set the initial state of the cell to be fully transparent
                cell.alpha = 0

                // Animate the cell to full opacity
                UIView.animate(
                    withDuration: duration,
                    delay: delayFactor * Double(indexPath.row),
                    animations: {
                        cell.alpha = 1
                    })
            }
        }
    /**
        Creates a move-up with bounce animation for table view cells.
        
        - Parameters:
           - rowHeight: The height of the table view rows.
           - duration: The duration of the animation.
           - delayFactor: A factor to calculate the delay for each cell based on its row index.
        - Returns: An `Animation` closure that performs the move-up with bounce animation.
        */
       static func makeMoveUpWithBounce(rowHeight: CGFloat, duration: TimeInterval, delayFactor: Double) -> Animation {
           return { cell, indexPath, tableView in
               // Set the initial state of the cell to be below its final position
               cell.transform = CGAffineTransform(translationX: 0, y: rowHeight)

               // Animate the cell to its final position with a bounce effect
               UIView.animate(
                   withDuration: duration,
                   delay: delayFactor * Double(indexPath.row),
                   usingSpringWithDamping: 0.4,
                   initialSpringVelocity: 0.1,
                   options: [.curveEaseInOut],
                   animations: {
                       cell.transform = CGAffineTransform(translationX: 0, y: 0)
                   })
           }
       }

       /**
        Creates a slide-in animation for table view cells.
        
        - Parameters:
           - duration: The duration of the animation.
           - delayFactor: A factor to calculate the delay for each cell based on its row index.
        - Returns: An `Animation` closure that performs the slide-in animation.
        */
       static func makeSlideIn(duration: TimeInterval, delayFactor: Double) -> Animation {
           return { cell, indexPath, tableView in
               // Set the initial state of the cell to be off the screen to the right
               cell.transform = CGAffineTransform(translationX: tableView.bounds.width, y: 0)

               // Animate the cell to its final position
               UIView.animate(
                   withDuration: duration,
                   delay: delayFactor * Double(indexPath.row),
                   options: [.curveEaseInOut],
                   animations: {
                       cell.transform = CGAffineTransform(translationX: 0, y: 0)
                   })
           }
       }

       /**
        Creates a move-up with fade-in animation for table view cells.
        
        - Parameters:
           - rowHeight: The height of the table view rows.
           - duration: The duration of the animation.
           - delayFactor: A factor to calculate the delay for each cell based on its row index.
        - Returns: An `Animation` closure that performs the move-up with fade-in animation.
        */
       static func makeMoveUpWithFade(rowHeight: CGFloat, duration: TimeInterval, delayFactor: Double) -> Animation {
           return { cell, indexPath, tableView in
               // Set the initial state of the cell to be below its final position and fully transparent
               cell.transform = CGAffineTransform(translationX: 0, y: rowHeight / 2)
               cell.alpha = 0

               // Animate the cell to its final position and full opacity
               UIView.animate(
                   withDuration: duration,
                   delay: delayFactor * Double(indexPath.row),
                   options: [.curveEaseInOut],
                   animations: {
                       cell.transform = CGAffineTransform(translationX: 0, y: 0)
                       cell.alpha = 1
                   })
           }
       }
   }
