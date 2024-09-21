//
//  NewViewfromadvancedSearchViewController.swift
//  i2-Donate
//

import UIKit

/// View controller for displaying advanced search options and filtering results based on tax deductible status.
class NewViewfromadvancedSearchViewController: BaseViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var exempt: UIButton! // Outlet for the button representing tax exempt status
    @IBOutlet weak var notexempt: UIButton! // Outlet for the button representing not tax exempt status
    @IBOutlet weak var bottomView: UIView! // Outlet for the bottom view
    
    // MARK: - Properties
    
    var deductible = "" // Variable to store the tax deductible status
    var countryCode = "" // Variable to store the country code
    var latitude = "" // Variable to store the latitude
    var longitude = "" // Variable to store the longitude
    var address = "" // Variable to store the address
    var searchNameKey = "" // Variable to store the search name key
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        // Check if tax deductible status is set and show/hide bottom view accordingly
        if "\(UserDefaults.standard.value(forKey: "TaxDetectable") ?? "")" == ""{
            self.bottomView.isHidden = true
        }
        else{
            self.bottomView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set menu button frame based on safe area availability
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        // Add target and action for the menu button
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        
        // Add menu button to the view and set its image
        self.view.addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
    }
    
    /// Action triggered when the back button is pressed
    @objc func backAction(_sender:UIButton)  {
        // Show confirmation alert before returning to the previous screen
        let alert = UIAlertController(title: "", message: "Returning To previous screen without making changes?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            UserDefaults.standard.set("", forKey: "TaxDetectable")
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Action triggered when the apply button is pressed
    @IBAction func applyAction(_ sender: Any) {
        // Switch statement to handle different country codes
        switch countryCode {
        case "US":
            // Instantiate and configure view controller for the United States
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
            // Configure view controller properties
            vc?.headertitle = "UNITED STATES"
            vc?.country = countryCode
            vc?.deductible = deductible
            vc?.locationSearch = address
            vc?.lattitude = latitude
            vc?.longitute = longitude
            vc?.isFromAdvanceSearch = true
            vc?.hidesBottomBarWhenPushed = false
            // Push the view controller to the navigation stack
            self.navigationController?.pushViewController(vc!, animated: true)
            break
        case "INT":
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
            // Configure view controller properties
            vc?.headertitle = "INTERNATIONAL CHARITIES REGISTERED IN USA"
            vc?.country = countryCode
            vc?.deductible = deductible
            vc?.locationSearch = address
            vc?.lattitude = latitude
            vc?.longitute = longitude
            vc?.isFromAdvanceSearch = true
            vc?.hidesBottomBarWhenPushed = false
            // Push the view controller to the navigation stack
            self.navigationController?.pushViewController(vc!, animated: true)
            break
        default:
            // Instantiate and configure default view controller
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByNameVC") as? SearchByNameVC
            // Configure view controller properties
            vc?.deductible = deductible
            vc?.locationSearch = address
            vc?.lattitude = latitude
            vc?.longitute = longitude
            vc?.isFromAdvanceSearch = true
            vc?.searchedName = self.searchNameKey
            // Push the view controller to the navigation stack
            self.navigationController?.pushViewController(vc!, animated: true)
            break
        }
    }
    /// Action triggered when the reset button is pressed
    @IBAction func resetAction(_ sender: Any) {
        // Reset button colors and deductible value
        exempt.backgroundColor = UIColor.clear
        exempt.setTitleColor(UIColor(red:0.60, green:0.44, blue:0.57, alpha:1.0), for: .normal)
        notexempt.backgroundColor = UIColor.clear
        notexempt.setTitleColor(UIColor(red:0.60, green:0.44, blue:0.57, alpha:1.0), for: .normal)
        deductible = ""
        // Hide bottom view with animation
        UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseOut],
                       animations: {
            self.bottomView.isHidden = true
            self.loadViewIfNeeded()
        }, completion: nil)
        // Reset tax deductible status in user defaults
        UserDefaults.standard.set("", forKey: "TaxDetectable")
        
    }
    /// Action triggered when the tax exempt button is pressed
    @IBAction func exemptAction(_ sender: Any) {
        // Update UI to reflect tax exempt status
        exempt.setTitleColor(ivoryColor, for: .normal)
        exempt.backgroundColor = UIColor.init(red: 153/255, green: 112/255, blue: 146/255, alpha: 1.0)
        notexempt.backgroundColor = UIColor.clear
        notexempt.setTitleColor(UIColor(red:0.60, green:0.44, blue:0.57, alpha:1.0), for: .normal)
        deductible = "1"
        UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn],
                       animations: {
            self.bottomView.isHidden = false
        }, completion: nil)
        // Update user defaults
        
        UserDefaults.standard.set("1", forKey: "TaxDetectable")
    }
    /// Action triggered when the not tax exempt button is pressed
    @IBAction func notExemptAction(_ sender: Any) {
        // Update UI to reflect not tax exempt status
        notexempt.setTitleColor(ivoryColor, for: .normal)
        notexempt.backgroundColor = UIColor.init(red: 153/255, green: 112/255, blue: 146/255, alpha: 1.0)
        exempt.backgroundColor = UIColor.clear
        exempt.setTitleColor(UIColor(red:0.60, green:0.44, blue:0.57, alpha:1.0), for: .normal)
        deductible = "0"
        UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn],
                       animations: {
            self.bottomView.isHidden = false
        }, completion: nil)
        // Update user defaults
        UserDefaults.standard.set("0", forKey: "TaxDetectable")
    }
    
    /// Action triggered when the "Search By Types" button is pressed
    @IBAction func showSearchByTypes(_ sender: Any) {
        // Instantiate AdvancedVC from Main storyboard
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AdvancedVC") as? AdvancedVC
        // Set properties for AdvancedVC
        vc?.address = address
        vc?.latitude = latitude
        vc?.longitude = longitude
        vc?.countryCode = countryCode
        vc?.taxDeductible = deductible
        vc?.searchNameKey = self.searchNameKey
        // Push AdvancedVC onto the navigation stack
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    /// Action triggered when the "Annual Review" button is pressed
    @IBAction func showAnnualReview(_ sender: Any) {
        // Instantiate AnnualRevenueViewController from Main storyboard
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AnnualRevenueViewController") as? AnnualRevenueViewController
        // Set properties for AnnualRevenueViewController
        vc?.address = address
        vc?.latitude = latitude
        vc?.longitude = longitude
        vc?.countryCode = countryCode
        vc?.taxDeductible = deductible
        // Push AnnualRevenueViewController onto the navigation stack
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
