//
//  SubTypesViewController.swift
//  i2-Donate


import UIKit

/// View controller to display subtypes of selected category.
class SubTypesViewController: BaseViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var subTypesTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var headerLbl: UILabel!
    
    // MARK: - Properties
    
    var selectedType: Types? // Selected category type
    var selectedSubTypesCodeArray = [String]() // Array to store selected subtype codes
    var selectedChildTypesCodeArray = [String]() // Array to store selected child type codes
    var selectedSubTypesIndexArray = [Int]() // Array to store selected subtype indexes
    var selectedCategoryCode = String() // Selected category code
    var taxDeductible = String() // Tax deductible status
    var selectedSubtypesandChildTypes = [String: [String]]() // Dictionary to store selected subtypes and child types
    var countryCode = "" // Country code
    var latitude = "" // Latitude
    var longitude = "" // Longitude
    var address = "" // Address
    var comingFromType = false // Indicates if coming from type
    var searchNameKey = "" // Search name key
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set menu button frame based on safe area
        if iDonateClass.hasSafeArea {
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        // Add action for menu button
        menuBtn.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        self.view.addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        // Set header label text
        headerLbl.text = selectedType?.category_name?.capitalized
        
        // Set table view delegate and data source
        subTypesTableView.delegate = self
        subTypesTableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Set content inset for table view
        self.subTypesTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }
    
    // MARK: - Actions
    
    /// Action to handle navigation back to the previous screen.
    @objc func backAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: "Returning to the previous screen without making changes?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    /// Performs necessary actions when the "Apply" button is tapped.
    @IBAction func applyAction(_ sender: Any) {
        // Retrieve selected subtype and child type codes
        selectedSubTypesCodeArray = Array(selectedSubtypesandChildTypes.keys)
        selectedChildTypesCodeArray = Array(selectedSubtypesandChildTypes.values).flatMap { $0 }
        selectedCategoryCode = selectedType?.category_code ?? ""
        
        // Navigate to different view controllers based on the country code
        switch countryCode {
        case "US":
            // If the country code is "US", navigate to the SearchByLocationVC for United States.
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
            vc?.headerTitleText = "UNITED STATES"
            vc?.country = countryCode
            vc?.deductible = taxDeductible
            vc?.subCategoryCode = selectedSubTypesCodeArray
            vc?.childCategory = selectedChildTypesCodeArray
            vc?.categoryCode = [selectedCategoryCode]
            vc?.locationSearch = address
            vc?.hidesBottomBarWhenPushed = false
            self.navigationController?.pushViewController(vc!, animated: true)
        case "INT":
            // If the country code is "INT", navigate to the SearchByLocationVC for international charities registered in the USA.
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
            vc?.headerTitleText = "INTERNATIONAL CHARITIES REGISTERED IN USA"
            vc?.country = countryCode
            vc?.deductible = taxDeductible
            vc?.subCategoryCode = selectedSubTypesCodeArray
            vc?.childCategory = selectedChildTypesCodeArray
            vc?.categoryCode = [selectedCategoryCode]
            vc?.locationSearch = address
            vc?.hidesBottomBarWhenPushed = false
            self.navigationController?.pushViewController(vc!, animated: true)
        default:
            // For other countries, navigate to the SearchByNameVC to search by name.
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByNameVC") as? SearchByNameVC
            vc?.deductible = taxDeductible
            vc?.subCategoryCode = selectedSubTypesCodeArray
            vc?.childCategory = selectedChildTypesCodeArray
            vc?.categoryCode = [selectedCategoryCode]
            vc?.locationSearch = address
            vc?.comingFromType = comingFromType
            vc?.searchedName = self.searchNameKey
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
}
// MARK: - UITableViewDataSource

extension SubTypesViewController: UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections based on the subcategories of the selected type
        return selectedType?.subcategory?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in each section based on the child categories
        if selectedSubTypesIndexArray.contains(section) {
            return selectedType?.subcategory?[section].child_category?.count ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Set the height of each row in the table view
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Set the height of each section header
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Configure and return the view for each section header
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
        headerCell.headertitle.text = selectedType?.subcategory?[section].sub_category_name
        headerCell.selectbtn.tag = section
        headerCell.selectbtn.addTarget(self, action: #selector(selectedSectionStoredButtonClicked(sender:)), for: .touchUpInside)
        headerCell.plusIMage.contentMode = .center
        
        // Configure the appearance of the section header based on its expansion state
        if selectedType?.subcategory?[section].child_category?.count ?? 0 > 0 {
            headerCell.plusIMage.isHidden = false
            headerCell.headertitle.font = boldSystem17
        } else {
            headerCell.plusIMage.isHidden = true
            headerCell.headertitle.font = systemFont18
        }
        
        if selectedSubTypesIndexArray.contains(section) {
            headerCell.selectbtn.isSelected = true
            headerCell.plusIMage.image = #imageLiteral(resourceName: "minus")
        } else {
            headerCell.selectbtn.isSelected = false
            headerCell.plusIMage.image = #imageLiteral(resourceName: "plus")
        }
        
        return headerCell
    }
    @objc func selectedSectionStoredButtonClicked (sender : UIButton) {
            
            if selectedSubTypesIndexArray.contains(sender.tag){
                
                selectedSubTypesIndexArray = selectedSubTypesIndexArray.filter { $0 != sender.tag }
                
                selectedSubTypesCodeArray = selectedSubTypesCodeArray.filter { $0 != (selectedType?.subcategory?[sender.tag].sub_category_code)! }

                selectedChildTypesCodeArray.removeAll()
                
                selectedSubtypesandChildTypes.removeValue(forKey: (selectedType?.subcategory?[sender.tag].sub_category_code)!)
                
            } else{
                
                selectedSubTypesIndexArray.append(sender.tag)
                selectedSubTypesCodeArray.append((selectedType?.subcategory?[sender.tag].sub_category_code)!)
                
                selectedChildTypesCodeArray.removeAll()
                
                if selectedType?.subcategory?[sender.tag].child_category?.count ?? 0 > 0 {
                    for child in (selectedType?.subcategory?[sender.tag].child_category!)!  {
                        selectedChildTypesCodeArray.append(child.child_category_code!)
                    }
                }
                
                selectedSubtypesandChildTypes[(selectedType?.subcategory?[sender.tag].sub_category_code)!] = selectedChildTypesCodeArray
                
            }
            
            print(selectedSubtypesandChildTypes)
            
            if Array(selectedSubtypesandChildTypes.keys).count > 0{
                self.bottomView.isHidden = false
            } else {
                self.bottomView.isHidden = true
            }
            
            subTypesTableView.reloadData()
            
        }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure and return the cell for each row in the table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell2") as! CustomCell
        cell.headertitle.text = selectedType?.subcategory?[indexPath.section].child_category?[indexPath.row].child_category_name
        cell.selectbtn.tag = indexPath.row
        cell.selectbtn.isUserInteractionEnabled = false
        
        // Configure the selection state of the cell based on the selected subtypes and child types
        let selectedChild = selectedType?.subcategory?[indexPath.section].child_category?[indexPath.row].child_category_code ?? ""
        let childTypesCode = selectedSubtypesandChildTypes[(selectedType?.subcategory?[indexPath.section].sub_category_code) ?? ""]
        
        if (childTypesCode?.contains(selectedChild) ?? true) {
            cell.selectbtn.isSelected = true
        } else {
            cell.selectbtn.isSelected = false
        }
        
        return cell
    }
}
///The headercustomCell class is  subclass of UITableViewCell, indicating that it's used for displaying cells in a UITableView. This particular cell seems to be designed for displaying headers or sections within the table view.
class headercustomCell:UITableViewCell{
    
    @IBOutlet weak var headertitle: UILabel!
    @IBOutlet weak var backgroundlbl: UIView!
    @IBOutlet weak var selectbtn: UIButton!
    @IBOutlet weak var subtypeHeaderSelect: UIButton!
    @IBOutlet weak var narrowlabel: UILabel!
    @IBOutlet weak var narrowArrow: UIButton!

}

///The CustomCell class extends the functionality of UITableViewCell by adding specific outlets for UI elements that are used to customize the appearance of the cell. These outlets allow developers to access and manipulate the UI elements directly from code.
class CustomCell:UITableViewCell {
    @IBOutlet weak var headertitle: UILabel!
    @IBOutlet weak var selectbtn: UIButton!
    @IBOutlet weak var plusIMage: UIImageView!
    @IBOutlet weak var leadingConstraint : NSLayoutConstraint!
}
