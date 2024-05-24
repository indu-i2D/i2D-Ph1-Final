//
//  AdvancedVC.swift
//  i2-Donate
//


import UIKit
import Alamofire
import MBProgressHUD

/**
 A view controller responsible for managing advanced search functionality.
 */
class AdvancedVC: BaseViewController,UITableViewDataSource,UITableViewDelegate {
    
    /// The bottom view containing apply and reset buttons.
    @IBOutlet weak var bottomView: UIView!
    
    /// The apply button.
    @IBOutlet weak var apply: UIButton!
    
    /// The reset button.
    @IBOutlet weak var reset: UIButton!
    
    /// The table view displaying the types for advanced search.
    @IBOutlet weak var typesTableView : UITableView!
    
    /// An array to hold the category codes.
    var categoryCode = [String]()
    
    /// An array to hold the selected indices in the table view.
    var selectedIndex:[Int] = [Int]()
    
    /// An instance of `AdvancedModel` to hold advanced search response data.
    var advancedResponse :  AdvancedModel?
    
    /// An array to hold types data.
    var typesArray : [Types]?
    
    /// A boolean flag indicating the selection status.
    var selectionFlag :Bool = false

    /// The selected parent section index.
    var selectParentscetion:Int = -1
    
    /// The country code.
    var countryCode = ""
    
    /// The latitude.
    var latitude = ""
    
    /// The longitude.
    var longitude = ""
    
    /// The address.
    var address = ""
    
    /// The tax deductible status.
    var taxDeductible = ""
    
    /// A boolean flag indicating if coming from type.
    var comingFromType = false
    
    /// The search name key.
    var searchNameKey = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Adjust menu button frame based on screen
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else{
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        // Set menu button action
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view.addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        // Configure table view
        typesTableView.estimatedRowHeight = 60
        typesTableView.rowHeight = UITableView.automaticDimension
        typesTableView.delegate = self
        typesTableView.dataSource = self

        // Fetch types data from API
        getTypesWebservice()
    }
    
    /// Adjusts content inset of the table view.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.typesTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }
    
    // MARK: - Networking

    /// Fetches types data from the server.
    func getTypesWebservice() {
        // Check if user data is available in UserDefaults
        guard let userIDData = UserDefaults.standard.data(forKey: "people"),
              let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: userIDData) as? UserDetails else {
            // Exit function if user data is not available
            return
        }
        
        // Extract token from user data
        let token = myPeopleList.token
        
        // Prepare parameters for the API request
        let postDict: Parameters = [
            "user_id": String(myPeopleList.userID),  // Required: User ID
            "token": token ?? ""                      // Optional: Authentication token
        ]
        
        // Get API endpoint URL
        let urlString = URLHelper.iDonateCategories
        
        // Show loading indicator
        let loadingNotification = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        
        // Make API request to fetch types data
        WebserviceClass.sharedAPI.performRequest(type: AdvancedModel.self, urlString: urlString, methodType: .post, parameters: postDict, success: { (response) in
            // Handle successful response
            
            // Store response data in the view controller's property
            self.advancedResponse = response
            
            // Extract types array from the response
            self.typesArray = self.advancedResponse?.data
            
            // Reload table view to reflect updated data
            self.typesTableView.reloadData()
            
            // Hide loading indicator
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
            
        }) { (response) in
            // Handle failed response
            
            // Hide loading indicator
            MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        }
    }

    
    // MARK: - Button Actions
    
    /// Apply action triggered when apply button is tapped.
    @IBAction func applyAction(_ sender: Any) {
        // Handle apply action based on country code
        switch countryCode {
        case "US":
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
            vc?.headerTitleText = "UNITED STATES"
            vc?.country = countryCode
            vc?.deductible = taxDeductible
            vc?.categoryCode = categoryCode
            vc?.locationSearch = address
            vc?.latitude = latitude
            vc?.longitude = longitude
            vc?.searchName = self.searchNameKey
            vc?.isFromAdvanceSearch = true
            vc?.hidesBottomBarWhenPushed = false
            self.navigationController?.pushViewController(vc!, animated: true)
            break
        case "INT":
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
            vc?.headerTitleText = "INTERNATIONAL CHARITIES REGISTERED IN USA"
            vc?.country = countryCode
            vc?.deductible = taxDeductible
            vc?.categoryCode = categoryCode
            vc?.locationSearch = address
            vc?.latitude = latitude
            vc?.longitude = longitude
            vc?.searchName = self.searchNameKey
            vc?.isFromAdvanceSearch = true
            vc?.hidesBottomBarWhenPushed = false
            self.navigationController?.pushViewController(vc!, animated: true)
            break
        default:
             let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByNameVC") as? SearchByNameVC
             vc?.deductible = taxDeductible
             vc?.categoryCode = categoryCode
             vc?.locationSearch = address
             vc?.lattitude = latitude
             vc?.longitute = longitude
             vc?.comingFromType = comingFromType
             vc?.searchedName = self.searchNameKey
             vc?.isFromAdvanceSearch = true
             self.navigationController?.pushViewController(vc!, animated: true)
            break
        }
    }
    
    @IBAction func resetAction(_ sender: Any) {
        // Animate hiding of bottom view
        UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseOut], animations: {
            self.bottomView.isHidden = true
            self.loadViewIfNeeded()
        }, completion: nil)
        
        // Clear selected index and category code arrays
        self.selectedIndex.removeAll()
        self.categoryCode.removeAll()
        
        // Reload table view data
        self.typesTableView.reloadData()
    }

    /// Handles the action when the back button is pressed.
    ///
    /// - Parameter _sender: The UIButton triggering the action.
    @objc func backAction(_sender: UIButton) {
        // Display an alert to confirm returning to the previous screen without making changes
        let alert = UIAlertController(title: "", message: "Returning To previous screen without making changes?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            // Pop view controller if user confirms
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            // Do nothing if user chooses not to go back
        }))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typesArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue reusable cell and cast it to your custom cell class
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! headercustomCell
        
        // Configure cell with type data
        cell.headertitle.text = typesArray?[indexPath.row].category_name
        
        // Check if the current cell is selected
        if selectedIndex.contains(indexPath.row) {
            // Add index to selectedIndex array
            selectedIndex.append(indexPath.row)
            
            // Update cell UI to indicate selection
            cell.backgroundlbl.backgroundColor = hexStringToUIColor(hex: "F4DEEF")
            cell.selectbtn.isSelected = true
            cell.narrowlabel.isHidden = false
            cell.narrowArrow.isHidden = false
        } else {
            // Remove index from selectedIndex array
            selectedIndex = selectedIndex.filter { $0 != indexPath.row }
            
            // Update cell UI to indicate deselection
            cell.backgroundlbl.backgroundColor = .clear
            cell.selectbtn.isSelected = false
            cell.narrowlabel.isHidden = true
            cell.narrowArrow.isHidden = true
        }
        
        // Check if user is logged in
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            // User is logged in, show appropriate label
            cell.narrowlabel.text = "Filter by sub-types"
        } else {
            // User is not logged in, show appropriate label
            cell.narrowlabel.text = "Filter by sub-types (Requires Login)"
        }
        
        // Set target for narrowArrow button tap
        cell.narrowArrow.addTarget(self, action: #selector(showSubTypes(_:)), for: .touchUpInside)
        
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row after selection
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get reference to selected cell
        let cell = tableView.cellForRow(at: indexPath) as! headercustomCell
        
        // Toggle selection status
        if !selectedIndex.contains(indexPath.row) {
            // Add index to selectedIndex array
            selectedIndex.append(indexPath.row)
            
            // Update cell UI to indicate selection
            cell.backgroundlbl.backgroundColor = hexStringToUIColor(hex: "F4DEEF")
            cell.selectbtn.isSelected = true
            cell.narrowlabel.isHidden = false
            cell.narrowArrow.isHidden = false
            
            // Append category code to categoryCode array
            categoryCode.append((typesArray?[indexPath.row].category_code)!)
        } else {
            // Remove index from selectedIndex array
            selectedIndex = selectedIndex.filter { $0 != indexPath.row }
            
            // Remove category code from categoryCode array
            categoryCode = categoryCode.filter { $0 != (typesArray?[indexPath.row].category_code)!}
            
            // Update cell UI to indicate deselection
            cell.narrowlabel.isHidden = true
            cell.backgroundlbl.backgroundColor = .clear
            cell.selectbtn.isSelected = false
            cell.narrowArrow.isHidden = true
        }
        
        // Show or hide bottom view based on selected indexes
        if selectedIndex.count > 0 {
            self.bottomView.isHidden = false
        } else {
            self.bottomView.isHidden = true
        }
    }

    
    // MARK: - Helper Methods
    
    /// Displays subtypes based on the selected type.
    ///
    /// - Parameter sender: The button triggering the action.
    @objc func showSubTypes(_ sender: UIButton) {
        // Logic to display subtypes if the user is logged in, else prompt for login.
    }
}

