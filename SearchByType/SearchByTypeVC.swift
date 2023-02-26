//
//  SearchByTypeVC.swift
//  iDonate
//
//  Created by Im043 on 15/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

class SearchByTypeVC: BaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITabBarDelegate {
    
    @IBOutlet var notificationTabBar: UITabBar!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var searchByTypeCollection: UICollectionView!
    @IBOutlet var bottomView: UIView!
    var typeSelectedString:String = ""
    var type:String = ""
    var selectedIndex = -1
    var selectedValues:[String] = [String]()
    
    let typeList = ["ARTS,CULTURE & HUMANITIES","EDUCATION","ENVIRONMENT","ANIMAL-RELATED",
                      "HEALTH CARE","DISEASES & MEDICAL DISCIPLINES","CRIME & LEGAL-RELATED","HOUSING & SHELTER","CIVIL RIGHTS,SOCIAL ACTION & ADVOCACY","SOCIAL SCIENCE","MUTUAL & MEMBERSHIP BENEF"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        searchByTypeCollection.allowsMultipleSelection = true
       
        // Do any additional setup after loading the view.
    }
    
     @IBAction func resetAction(_sender:UIButton) {
        UserDefaults.standard.removeObject(forKey: "SelectedType")
        searchByTypeCollection .reloadData()
    }
    
    @IBAction func applyAction(_ sender:UIButton){
        let joiner = ", "
        let joinedStrings = selectedValues.joined(separator: joiner)
        print("joinedStrings: \(joinedStrings)")
        UserDefaults.standard.set(joinedStrings.capitalized, forKey: "SelectedType")
        if(type == "Type") {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByNameVC") as? SearchByNameVC
            self.navigationController?.pushViewController(vc!, animated: true)
        } else {
        self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func backAction(_sender:UIButton)  {
        let alert = UIAlertController(title: "", message: "Returning to previous screen without making any changes?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)

    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
        if(item.tag == 0){
            UserDefaults.standard.set(0, forKey: "tab")
            self.navigationController?.pushViewController(vc!, animated: false)
        } else {
            UserDefaults.standard.set(1, forKey: "tab")
            self.navigationController?.pushViewController(vc!, animated: false)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension SearchByTypeVC
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return typeList.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "typeCell", for: indexPath)as! typeCell
        cell.lbl_title.text = typeList[indexPath.row]
        cell.bgView.backgroundColor = UIColor.clear
        cell.lbl_title.textColor =  UIColor.init(red: 153/255, green: 112/255, blue: 146/255, alpha: 1.0)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedCell : typeCell = collectionView.cellForItem(at: indexPath)! as! typeCell
        typeSelectedString =  typeList[indexPath.row]
        selectedCell.bgView.backgroundColor = UIColor.init(red: 153/255, green: 112/255, blue: 146/255, alpha: 1.0)
                    selectedCell.lbl_title.textColor = ivoryColor
                    selectedCell.bgView.layer.cornerRadius = 5
        selectedIndex = indexPath.row
        selectedValues.append(typeList[indexPath.row])
        print(selectedValues)
        UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn],
                       animations: {
                        self.bottomConstraint.constant = 0
                        self.loadViewIfNeeded()
        }, completion: nil)
      
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        
        
        let removeString = typeList[indexPath.row]
        for (index, element) in selectedValues.enumerated() {
            print("Item \(index): \(element)")
            if(element == removeString)
            {
                selectedValues.remove(at: index)
            }
        }
        print(selectedValues)
        let selectedCell : typeCell = collectionView.cellForItem(at: indexPath)! as! typeCell
        
         selectedCell.bgView.backgroundColor = UIColor.clear
                selectedCell.lbl_title.textColor =  UIColor.init(red: 153/255, green: 112/255, blue: 146/255, alpha: 1.0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         if(iDonateClass.hasSafeArea)
         {
            let padding: CGFloat =  10
            let collectionViewSize = collectionView.frame.size.width-padding
            let collectionViewHeigthSize = collectionView.frame.size.height-200
            return CGSize(width: collectionViewSize/2.0, height:collectionViewHeigthSize/7.0)
        }
         else{
        let padding: CGFloat =  10
        let collectionViewSize = collectionView.frame.size.width-padding
        let collectionViewHeigthSize = collectionView.frame.size.height-200
        return CGSize(width: collectionViewSize/2.0, height:collectionViewHeigthSize/4.5)
        }
    }
}

class typeCell:UICollectionViewCell
{
    @IBOutlet var lbl_title: UILabel!
   
    @IBOutlet var bgView: UIView!
}
