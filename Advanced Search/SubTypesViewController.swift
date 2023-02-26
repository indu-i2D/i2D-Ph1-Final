//
//  SubTypesViewController.swift
//  iDonate
//
//  Created by Satheesh k on 27/06/20.
//  Copyright © 2020 Im043. All rights reserved.
//

import UIKit

class SubTypesViewController: BaseViewController {

    @IBOutlet weak var subTypesTableView : UITableView!
    @IBOutlet weak var bottomView : UIView!
    @IBOutlet weak var applyBtn : UIButton!
    @IBOutlet weak var resetBtn : UIButton!
    @IBOutlet weak var headerLbl : UILabel!
    
    var selectedType : Types?
    
    var selectedSubTypesCodeArray = [String]()
    var selectedChildTypesCodeArray = [String]()
    var selectedSubTypesIndexArray = [Int]()
    
    var selectedCategoryCode = String()
    var taxDeductible = String()

    var selectedSubtypesandChildTypes = [String:[String]]()
    
    var countryCode = ""
    var latitude = ""
    var longitude = ""
    var address = ""
    var comingFromType = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else{
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        
        headerLbl.text = selectedType?.category_name?.capitalized
        
        subTypesTableView.delegate = self
        subTypesTableView.dataSource = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.subTypesTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @objc func backAction(_sender:UIButton)  {
        
        let alert = UIAlertController(title: "", message: "Returning To previous screen without making changes?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
}

extension SubTypesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return selectedType?.subcategory?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
        if selectedSubTypesIndexArray.contains(section){
            return selectedType?.subcategory?[section].child_category?.count ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
        headerCell.headertitle.text = selectedType?.subcategory?[section].sub_category_name
        headerCell.selectbtn.tag = section
        headerCell.selectbtn.addTarget(self, action: #selector(selectedSectionStoredButtonClicked(sender:)), for: .touchUpInside)
        headerCell.plusIMage.contentMode = .center
        
        if selectedType?.subcategory?[section].child_category?.count ?? 0 > 0 {
            headerCell.plusIMage.isHidden = false
            headerCell.headertitle.font = boldSystem17
        } else {
            headerCell.plusIMage.isHidden = true
            headerCell.headertitle.font = systemFont18
        }
    
        if selectedSubTypesIndexArray.contains(section){
            headerCell.selectbtn.isSelected = true
            headerCell.plusIMage.image = #imageLiteral(resourceName: "minus")
        } else {
            headerCell.selectbtn.isSelected = false
            headerCell.plusIMage.image = #imageLiteral(resourceName: "plus")
        }

        return headerCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell2") as! CustomCell
        cell.headertitle.text = selectedType?.subcategory?[indexPath.section].child_category?[indexPath.row].child_category_name
        cell.selectbtn.tag = indexPath.row
        cell.selectbtn.isUserInteractionEnabled = false
        
        let selectedChild = selectedType?.subcategory?[indexPath.section].child_category?[indexPath.row].child_category_code ?? ""

        let childTypesCode = selectedSubtypesandChildTypes[(selectedType?.subcategory?[indexPath.section].sub_category_code) ?? ""]

        if (childTypesCode?.contains(selectedChild) ?? true) {
            cell.selectbtn.isSelected = true
        } else {
            cell.selectbtn.isSelected = false
        }
        
        return cell
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        var childTypesCode = selectedSubtypesandChildTypes[(selectedType?.subcategory?[indexPath.section].sub_category_code)!]
        
        let selectedChild = selectedType?.subcategory?[indexPath.section].child_category?[indexPath.row].child_category_code ?? ""
        
        if (childTypesCode?.contains(selectedChild)) ?? true {
            childTypesCode = childTypesCode?.filter {$0 != selectedChild}
        } else {
            childTypesCode?.append(selectedChild)
        }
       
        selectedSubtypesandChildTypes[(selectedType?.subcategory?[indexPath.section].sub_category_code)!] = childTypesCode ?? [String]()
        
        if  childTypesCode?.count ?? 0 < selectedSubtypesandChildTypes[(selectedType?.subcategory?[indexPath.section].sub_category_code)!]?.count ?? 0 {

            selectedSubTypesIndexArray = selectedSubTypesIndexArray.filter { $0 != indexPath.section }
            
            selectedSubTypesCodeArray = selectedSubTypesCodeArray.filter { $0 != (selectedType?.subcategory?[indexPath.section].sub_category_code)! }
            
        }
        
        print(selectedSubtypesandChildTypes)
                
        self.subTypesTableView.reloadData()
        
    }
    
    @IBAction func applyAction(_ sender: Any) {
        
        print("selectedSubTypesCodeArray", selectedSubTypesCodeArray)
        print("selectedChildTypesCodeArray", selectedChildTypesCodeArray)
        
        selectedSubTypesCodeArray = Array(selectedSubtypesandChildTypes.keys)
        selectedChildTypesCodeArray =  Array(selectedSubtypesandChildTypes.values).flatMap { $0 }
        selectedCategoryCode = selectedType?.category_code ?? ""

        
        switch countryCode {
        case "US":
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
            vc?.headertitle = "UNITED STATES"
            vc?.country = countryCode
            vc?.deductible = taxDeductible
            vc?.subCategoryCode = selectedSubTypesCodeArray
            vc?.childCategory = selectedChildTypesCodeArray
            vc?.categoryCode = [selectedCategoryCode]
            vc?.locationSearch = address
            vc?.hidesBottomBarWhenPushed = false
            self.navigationController?.pushViewController(vc!, animated: true)
            break
        case "INT":
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
            vc?.headertitle = "INTERNATIONAL CHARITIES REGISTERED IN USA"
            vc?.country = countryCode
            vc?.deductible = taxDeductible
            vc?.subCategoryCode = selectedSubTypesCodeArray
            vc?.childCategory = selectedChildTypesCodeArray
            vc?.categoryCode = [selectedCategoryCode]
            vc?.locationSearch = address
            vc?.hidesBottomBarWhenPushed = false
            self.navigationController?.pushViewController(vc!, animated: true)
            break
        default:
             let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByNameVC") as? SearchByNameVC
             vc?.deductible = taxDeductible
             vc?.subCategoryCode = selectedSubTypesCodeArray
             vc?.childCategory = selectedChildTypesCodeArray
             vc?.categoryCode = [selectedCategoryCode]
             vc?.locationSearch = address
             vc?.comingFromType = comingFromType
             self.navigationController?.pushViewController(vc!, animated: true)
            break
        }
                
                
    }
    
    @IBAction func resetAction(_ sender: Any) {
        selectedSubtypesandChildTypes.removeAll()
        selectedSubTypesIndexArray.removeAll()
        selectedChildTypesCodeArray.removeAll()
        selectedSubTypesCodeArray.removeAll()
        self.subTypesTableView.reloadData()
        self.bottomView.isHidden = true
    }
    
    // MARK: - tabBar  delegate methods
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
        if(item.tag == 0){
            UserDefaults.standard.set(0, forKey: "tab")
            UserDefaults.standard.synchronize()
            self.navigationController?.pushViewController(vc!, animated: false)
        }
        else{
            UserDefaults.standard.set(1, forKey: "tab")
            UserDefaults.standard.synchronize()
            self.navigationController?.pushViewController(vc!, animated: false)
        }
    }
}

class headercustomCell:UITableViewCell{
    
    @IBOutlet weak var headertitle: UILabel!
    @IBOutlet weak var backgroundlbl: UIView!
    @IBOutlet weak var selectbtn: UIButton!
    @IBOutlet weak var subtypeHeaderSelect: UIButton!
    @IBOutlet weak var narrowlabel: UILabel!
    @IBOutlet weak var narrowArrow: UIButton!

}


class CustomCell:UITableViewCell {
    @IBOutlet weak var headertitle: UILabel!
    @IBOutlet weak var selectbtn: UIButton!
    @IBOutlet weak var plusIMage: UIImageView!
    @IBOutlet weak var leadingConstraint : NSLayoutConstraint!
}
