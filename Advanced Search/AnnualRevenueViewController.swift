//
//  annualrevenueViewController.swift
//  i2-Donate


import UIKit
///AnnualRevenueViewController class plays a crucial role in managing user interactions related to selecting annual revenue ranges and applying filters for charity searches within the iDonate app.
class AnnualRevenueViewController: BaseViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var button1: UIButton! // Outlet for button 1
    @IBOutlet weak var button2: UIButton! // Outlet for button 2
    @IBOutlet weak var button3: UIButton! // Outlet for button 3
    @IBOutlet weak var button4: UIButton! // Outlet for button 4
    @IBOutlet weak var button5: UIButton! // Outlet for button 5
    @IBOutlet weak var bottomView: UIView! // Outlet for bottom view
    @IBOutlet weak var applyButton: UIButton! // Outlet for apply button
    @IBOutlet weak var resetButton: UIButton! // Outlet for reset button
    
    // MARK: - Properties
    
    var butt1Bool: Bool = false // Boolean flag for button 1
    var butt2Bool: Bool = false // Boolean flag for button 2
    var butt3Bool: Bool = false // Boolean flag for button 3
    var butt4Bool: Bool = false // Boolean flag for button 4
    var butt5Bool: Bool = false // Boolean flag for button 5
    
    var incomeFromArray = ["0", "90001", "200001", "500001", "1000001"] // Array for income from values
    var incomeToArray = ["90000", "200000", "500000", "1000000", ""] // Array for income to values
    
    var incomeFrom = "" // Selected income from value
    var incomeTo = "" // Selected income to value
    var taxDeductible = "" // Tax deductible value
    var address = "" // Address value
    var latitude = "" // Latitude value
    var longitude = "" // Longitude value
    var countryCode = "" // Country code value
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adjust menu button position based on safe area
        if iDonateClass.hasSafeArea {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        menuBtn.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        self.view.addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
    }
    
    
    /**
     Handles the action when the back button is tapped.
     
     - Parameters:
        - _sender: The button triggering the action.
     */
    @objc func backAction(_ sender: UIButton) {

        // Checks if the incomeFrom property is empty
        if incomeFrom.count == 0 {
            // Presents an alert if no changes were made
            let alert = UIAlertController(title: "", message: "Returning to previous screen without making any changes?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                // Pops the view controller to navigate back
                self.navigationController?.popViewController(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                // No action required
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            // Pops the view controller to navigate back
            self.navigationController?.popViewController(animated: true)
        }
    }

    /**
     Handles the action when button 1 is tapped.
     
     - Parameters:
        - _sender: The button triggering the action.
     */
    @IBAction func backAction1(_sender:UIButton) {
        // Checks if buttons 2, 3, 4, and 5 are not selected
        if  button2.backgroundColor == UIColor.clear || button3.backgroundColor == UIColor.clear || button4.backgroundColor == UIColor.clear || button5.backgroundColor == UIColor.clear {
            // Sets button 1's color and triggers animations
            button1.setTitleColor(ivoryColor, for: .normal)
            colorSet(button: button1)
            UserDefaults.standard.set(true, forKey: "Search Selected")
            // Clears selection and resets colors for buttons 2, 3, 4, and 5
            button2.backgroundColor = UIColor.clear
            button3.backgroundColor = UIColor.clear
            button4.backgroundColor = UIColor.clear
            button5.backgroundColor = UIColor.clear
            button2.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button3.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button4.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button5.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            // Animates the bottom view
            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn], animations: {
                self.bottomView.isHidden = false
            }, completion: nil)
        } else {
            // Sets button 1's color and triggers animations
            button1.setTitleColor(ivoryColor, for: .normal)
            colorSet(button: button1)
            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn], animations: {
                self.bottomView.isHidden = false
            }, completion: nil)
            // Resets colors for buttons 2, 3, 4, and 5
            button2.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button3.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button4.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button5.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button2.backgroundColor = UIColor.clear
            button3.backgroundColor = UIColor.clear
            button4.backgroundColor = UIColor.clear
            button5.backgroundColor = UIColor.clear
        }
        // Updates incomeFrom and incomeTo properties based on the button tag
        incomeFrom = incomeFromArray[_sender.tag]
        incomeTo = incomeToArray[_sender.tag]
    }

    /**
     Handles the action when button 2 is tapped.
     
     - Parameters:
        - _sender: The button triggering the action.
     */
    @IBAction func backAction2(_sender:UIButton) {
        // Checks if buttons 1, 3, 4, and 5 are not selected
        if  button1.backgroundColor == UIColor.clear || button3.backgroundColor == UIColor.clear || button4.backgroundColor == UIColor.clear || button5.backgroundColor == UIColor.clear {
            // Sets button 2's color and triggers animations
            button2.setTitleColor(ivoryColor, for: .normal)
            colorSet(button: button2)
            UserDefaults.standard.set(true, forKey: "Search Selected")
            // Clears selection and resets colors for buttons 1, 3, 4, and 5
            button1.backgroundColor = UIColor.clear
            button3.backgroundColor = UIColor.clear
            button4.backgroundColor = UIColor.clear
            button5.backgroundColor = UIColor.clear
            button1.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button3.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button4.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button5.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            // Animates the bottom view
            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn], animations: {
                self.bottomView.isHidden = false
            }, completion: nil)
        } else {
            // Sets button 2's color and triggers animations
            button2.setTitleColor(ivoryColor, for: .normal)
            colorSet(button: button2)
            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn], animations: {
                self.bottomView.isHidden = false
            }, completion: nil)
            // Resets colors for buttons 1, 3, 4, and 5
            button1.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button3.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button4.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button5.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button1.backgroundColor = UIColor.clear
            button3.backgroundColor = UIColor.clear
            button4.backgroundColor = UIColor.clear
            button5.backgroundColor = UIColor.clear
        }
        // Updates incomeFrom and incomeTo properties based on the button tag
        incomeFrom = incomeFromArray[_sender.tag]
        incomeTo = incomeToArray[_sender.tag]
    }

    /**
     Handles the action when button 3 is tapped.
     
     - Parameters:
        - _sender: The button triggering the action.
     */
    @IBAction func backAction3(_sender:UIButton) {
        // Checks if buttons 2, 1, 4, and 5 are not selected
        if  button2.backgroundColor == UIColor.clear || button1.backgroundColor == UIColor.clear || button4.backgroundColor == UIColor.clear || button5.backgroundColor == UIColor.clear {
            // Sets button 3's color and triggers animations
            button3.setTitleColor(ivoryColor, for: .normal)
            colorSet(button: button3)
            UserDefaults.standard.set(true, forKey: "Search Selected")
            // Clears selection and resets colors for buttons 2, 1, 4, and 5
            button2.backgroundColor = UIColor.clear
            button1.backgroundColor = UIColor.clear
            button4.backgroundColor = UIColor.clear
            button5.backgroundColor = UIColor.clear
            button2.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button1.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button4.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button5.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            // Animates the bottom view
            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn], animations: {
                self.bottomView.isHidden = false
            }, completion: nil)
        } else {
            // Sets button 3's color and triggers animations
            button3.setTitleColor(ivoryColor, for: .normal)
            colorSet(button: button3)
            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn], animations: {
                self.bottomView.isHidden = false
            }, completion: nil)
            // Resets colors for buttons 2, 1, 4, and 5
            button2.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button1.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button4.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button5.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button2.backgroundColor = UIColor.clear
            button1.backgroundColor = UIColor.clear
            button4.backgroundColor = UIColor.clear
            button5.backgroundColor = UIColor.clear
        }
        // Updates incomeFrom and incomeTo properties based on the button tag
        incomeFrom = incomeFromArray[_sender.tag]
        incomeTo = incomeToArray[_sender.tag]
        
    }
    
    /**
     Handles the action when button 4 is tapped.
     
     - Parameters:
        - _sender: The button triggering the action.
     */
    
    @IBAction func backAction4(_sender:UIButton) {
        if  button2.backgroundColor == UIColor.clear || button3.backgroundColor == UIColor.clear || button1.backgroundColor == UIColor.clear || button5.backgroundColor == UIColor.clear {
            button4.setTitleColor(ivoryColor, for: .normal)
            colorSet(button: button4)
            
            UserDefaults.standard.set(true, forKey: "Search Selected")
            button2.backgroundColor = UIColor.clear
            button3.backgroundColor = UIColor.clear
            button1.backgroundColor = UIColor.clear
            button5.backgroundColor = UIColor.clear
            // Resets colors for buttons 2, 1, 4, and 5

            button2.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button3.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button5.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button1.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            // Animates the bottom view

            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn],
                           animations: {
                            self.bottomView.isHidden = false
            }, completion: nil)
        }else {
            // Sets button 4's color and triggers animations

            button4.setTitleColor(ivoryColor, for: .normal)
            colorSet(button: button4)
            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn],
                           animations: {
                            self.bottomView.isHidden = false
            }, completion: nil)
            
            button2.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button3.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button1.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button5.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button2.backgroundColor = UIColor.clear
            button3.backgroundColor = UIColor.clear
            button1.backgroundColor = UIColor.clear
            button5.backgroundColor = UIColor.clear
        }
        // Updates incomeFrom and incomeTo properties based on the button tag

        incomeFrom = incomeFromArray[_sender.tag]
        incomeTo = incomeToArray[_sender.tag]
    }
    
    /**
     Handles the action when button 5 is tapped.
     
     - Parameters:
        - _sender: The button triggering the action.
     */
    
    @IBAction func backAction5(_sender:UIButton) {
        if  button2.backgroundColor == UIColor.clear || button3.backgroundColor == UIColor.clear || button4.backgroundColor == UIColor.clear || button1.backgroundColor == UIColor.clear {
            button5.setTitleColor(ivoryColor, for: .normal)
            colorSet(button: button5)
            UserDefaults.standard.set(true, forKey: "Search Selected")
            
            button2.backgroundColor = UIColor.clear
            button3.backgroundColor = UIColor.clear
            button4.backgroundColor = UIColor.clear
            button1.backgroundColor = UIColor.clear
            button2.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button3.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button4.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button1.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            
            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn],
                           animations: {
                            self.bottomView.isHidden = false
            }, completion: nil)
        }else {
            
            button5.setTitleColor(ivoryColor, for: .normal)
            colorSet(button: button5)
            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn],
                           animations: {
                            self.bottomView.isHidden = false
            }, completion: nil)
            
            button2.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button3.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button4.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button1.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button2.backgroundColor = UIColor.clear
            button3.backgroundColor = UIColor.clear
            button4.backgroundColor = UIColor.clear
            button1.backgroundColor = UIColor.clear
        }
        
        incomeFrom = incomeFromArray[_sender.tag]
        incomeTo = incomeToArray[_sender.tag]
    }
    
    // MARK: - Actions

        // Action triggered when the apply button is pressed
        @IBAction func applyAction(_sender: UIButton) {
            // Switch based on the country code
            switch countryCode {
            case "US":
                // Instantiate the SearchByLocationVC for US
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
                vc?.headerTitleText = "UNITED STATES" // Set the header title
                vc?.country = countryCode // Pass the country code
                vc?.deductible = taxDeductible // Pass tax deductible status
                vc?.incomeFrom = incomeFrom // Pass income from value
                vc?.incomeTo = incomeTo // Pass income to value
                vc?.locationSearch = address // Pass the address
                vc?.hidesBottomBarWhenPushed = false // Do not hide the bottom bar
                vc?.isFromAdvanceSearch = true // Indicate this is from advanced search
                self.navigationController?.pushViewController(vc!, animated: true) // Push the view controller onto the navigation stack
            case "INT":
                // Instantiate the SearchByLocationVC for international charities
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
                vc?.headerTitleText = "INTERNATIONAL CHARITIES REGISTERED IN USA" // Set the header title
                vc?.country = countryCode // Pass the country code
                vc?.deductible = taxDeductible // Pass tax deductible status
                vc?.incomeFrom = incomeFrom // Pass income from value
                vc?.incomeTo = incomeTo // Pass income to value
                vc?.locationSearch = address // Pass the address
                vc?.hidesBottomBarWhenPushed = false // Do not hide the bottom bar
                vc?.isFromAdvanceSearch = true // Indicate this is from advanced search
                self.navigationController?.pushViewController(vc!, animated: true) // Push the view controller onto the navigation stack
            default:
                // Instantiate the SearchByNameVC for other cases
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByNameVC") as? SearchByNameVC
                vc?.deductible = taxDeductible // Pass tax deductible status
                vc?.incomeFrom = incomeFrom // Pass income from value
                vc?.incomeTo = incomeTo // Pass income to value
                vc?.locationSearch = address // Pass the address
                vc?.isFromAdvanceSearch = true // Indicate this is from advanced search
                self.navigationController?.pushViewController(vc!, animated: true) // Push the view controller onto the navigation stack
            }
        }
        
        // Action triggered when the reset button is pressed
        @IBAction func resetAction(_sender: UIButton) {
            // Set the title color for all buttons
            button1.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button2.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button3.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button4.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button5.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            
            // Clear background color for all buttons
            clearcolor(button: button1)
            clearcolor(button: button2)
            clearcolor(button: button3)
            clearcolor(button: button4)
            clearcolor(button: button5)
            
            // Animate hiding the bottom view
            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseOut],
                           animations: {
                            self.bottomView.isHidden = true
                            self.loadViewIfNeeded()
            }, completion: nil)
            
            // Reset income fields
            incomeFrom = ""
            incomeTo = ""
        }
        
        // MARK: - Helper Methods
        
        // Method to set button background color to a custom color
        func colorSet(button: UIButton) {
            button.backgroundColor = UIColor.init(red: 153/255, green: 112/255, blue: 146/255, alpha: 1.0)
        }
        
        // Method to set button background color to a default custom color
        func defaultcolorSet(button: UIButton) {
            button.backgroundColor = UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0)
        }
        
        // Method to clear button background color
        func clearcolor(button: UIButton) {
            button.backgroundColor = UIColor.clear
        }
        
    }
