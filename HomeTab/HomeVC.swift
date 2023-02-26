//
//  HomeVC.swift
//  iDonate
//
//  Created by Im043 on 24/04/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit
import SideMenu
class HomeVC: BaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate {
    
  //  @IBOutlet weak var bottomConatraint: NSLayoutConstraint!
    let browseList = ["UNITED STATES","INTERNATIONAL CHARITIES REGISTERED IN USA","NAME","TYPE"]
    @IBOutlet var browseCollectionList: UICollectionView!
    @IBOutlet var browseScroll: UIScrollView!
    @IBOutlet var scrollContentView: UIView!
    @IBOutlet var advancedSearch: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.setNeedsLayout()
        
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        }
        else{
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(menuAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "menu"), for: .normal)
        menuBtn.imageView?.contentMode = .center
        advancedSearch.addTarget(self, action:#selector(setter: advancedSearch), for:.touchUpInside)
        advancedSearch.titleLabel?.font = boldSystem17
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if((UserDefaults.standard.value(forKey:"SelectedType")) != nil){
            UserDefaults.standard.removeObject(forKey: "SelectedType")
        }
        if((UserDefaults.standard.value(forKey: "tab")) != nil){
            if(UserDefaults.standard.value(forKey: "tab") as! Int == 1){
                self.tabBarController?.selectedIndex = 1
            }
            else{
                self.tabBarController?.selectedIndex = 0
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (advancedSearch.frame.origin.y + advancedSearch.frame.size.height) > self.browseScroll.frame.height {
            browseScroll.contentSize = CGSize(width :UIScreen.main.bounds.size.width, height: self.view.frame.height + 40)
        } else {
            browseScroll.contentSize = CGSize(width :UIScreen.main.bounds.size.width, height: browseScroll.frame.height)
            browseScroll.isScrollEnabled = false
        }
    }
    
    @IBAction func advancedSearch(_ sender: Any) {
        if let data = UserDefaults.standard.data(forKey: "people"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "newcontrollerID") as? NewViewfromadvancedSearchViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        } else {
            let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
            let messageFont = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 18.0)!]
            let messageAttrString = NSMutableAttributedString(string: "For Advance Features Please Log-in/Register", attributes: messageFont)
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
           let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                
            }
            alertController.addAction(ok)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    @objc func menuAction(_sender:UIButton){
        
        let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        let menu = SideMenuNavigationController(rootViewController: menuLeftNavigationController)
        menu.setNavigationBarHidden(true, animated: false)
        menu.leftSide = true
        menu.statusBarEndAlpha = 0
        menu.menuWidth = screenWidth
        menu.dismissOnPresent = false
        present(menu, animated: true, completion: nil)
        
    }
    
    
}

extension HomeVC{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return browseList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "browseCell", for: indexPath)as! browseCell
        cell.lbl_title.text = browseList[indexPath.row]
        cell.lbl_title.font = boldSystem14
        cell.img_view.image = UIImage(named: browseList[indexPath.row])
        cell.lbl_title.numberOfLines = 0
        cell.lbl_title.minimumScaleFactor = 0.5
        cell.lbl_title.adjustsFontSizeToFitWidth = true
        cell.backgroundColor = bottomNavigationBgColorEnd.withAlphaComponent(0.3)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.row {
            
        case 0:
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
            vc?.headertitle = "UNITED STATES"
            vc?.country = "US"
            UserDefaults.standard.set(false, forKey: "country")
            vc?.hidesBottomBarWhenPushed = false
            self.navigationController?.pushViewController(vc!, animated: true)
        case 1:
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
            vc?.headertitle = "INTERNATIONAL CHARITIES REGISTERED IN USA"
            vc?.country = "INT"
            UserDefaults.standard.set(true, forKey: "country")
            self.navigationController?.pushViewController(vc!, animated: true)
        case 2:
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByNameVC") as? SearchByNameVC
            self.navigationController?.pushViewController(vc!, animated: true)
        case 3:
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AdvancedVC") as? AdvancedVC
            vc?.comingFromType = true
            self.navigationController?.pushViewController(vc!, animated: true)
            
        default: break
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout

        if Iphone678 || Iphone5orSE {
            collectionViewLayout?.sectionInset = UIEdgeInsets(top: 0, left: 15.0, bottom: 0, right: 15.0)
            collectionViewLayout?.invalidateLayout()
            let padding: CGFloat =  15
            let collectionViewSize = collectionView.frame.size.height - padding
            print("collectionViewSize", collectionViewSize)
            return CGSize(width: collectionViewSize/2.0, height:collectionViewSize/2.0)
        } else if IphoneXR {
            collectionViewLayout?.sectionInset = UIEdgeInsets(top: 10, left: 20.0, bottom: 10, right: 20.0)
            collectionViewLayout?.invalidateLayout()
            return CGSize(width: 160, height:160)

        }
                
        let padding: CGFloat =  20
        let collectionViewSize = collectionView.frame.size.height - padding
        print("collectionViewSize", collectionViewSize)
        return CGSize(width: 160, height:160)
        
    }
}

class browseCell:UICollectionViewCell{
    @IBOutlet var lbl_title: UILabel!
    @IBOutlet var img_view: UIImageView!
}
