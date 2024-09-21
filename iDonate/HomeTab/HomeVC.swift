//
//  HomeVC.swift
//  i2-Donate
//


import UIKit
import SideMenu

/// Home Page of the iDonate App
///
/// This class manages the home screen of the application, displaying browsing options and handling navigation based on user selection.
class HomeVC: BaseViewController, UIScrollViewDelegate {
    
    /// List of browsing options displayed on the home screen.
    let browseList = ["UNITED STATES", "INTERNATIONAL CHARITIES REGISTERED IN USA", "NAME", "TYPE"]
    
    /// Collection view displaying the browsing options.
    @IBOutlet var browseCollectionList: UICollectionView!
    
    /// Scroll view containing the advanced search button and other UI elements.
    @IBOutlet var browseScroll: UIScrollView!
    
    /// Content view within the scroll view.
    @IBOutlet var scrollContentView: UIView!
    
    /// Button that triggers the advanced search functionality.
    @IBOutlet var advancedSearch: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up menu button
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        } else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        menuBtn.addTarget(self, action: #selector(menuAction(_:)), for: .touchUpInside)
        self.view.addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "menu"), for: .normal)
        menuBtn.imageView?.contentMode = .center
        
        // Set up advanced search button
        advancedSearch.addTarget(self, action:#selector(advancedSearch(_:)), for:.touchUpInside)
        advancedSearch.titleLabel?.font = boldSystem17
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Remove the selected type from UserDefaults if it exists
        if UserDefaults.standard.value(forKey: "SelectedType") != nil {
            UserDefaults.standard.removeObject(forKey: "SelectedType")
        }
        
        // Check the tab value in UserDefaults and switch the tab bar accordingly
        if let tab = UserDefaults.standard.value(forKey: "tab") as? Int {
            self.tabBarController?.selectedIndex = tab
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Adjust the content size of the scroll view based on the position of the advanced search button
        if (advancedSearch.frame.origin.y + advancedSearch.frame.size.height) > browseScroll.frame.height {
            browseScroll.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: self.view.frame.height + 40)
        } else {
            browseScroll.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: browseScroll.frame.height)
            browseScroll.isScrollEnabled = false
        }
    }
    
    /// Triggers the advanced search functionality.
    ///
    /// - Parameter sender: The object that triggered the action.
    @IBAction func advancedSearch(_ sender: Any) {
        if let data = UserDefaults.standard.data(forKey: "people"),
           let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserDetails {
            print(myPeopleList.name)
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "newcontrollerID") as? NewViewfromadvancedSearchViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        } else {
            let alertController = UIAlertController(title: "", message: "For Advanced Features Please Log-in/Register", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default) { _ in
                let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(ok)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /// Handles the menu button action to display the side menu.
    ///
    /// - Parameter sender: The menu button that triggered the action.
    @objc func menuAction(_ sender: UIButton) {
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

extension HomeVC: UICollectionViewDelegateFlowLayout {
    /// Returns the size for the specified item in the collection view.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view requesting the size.
    ///   - collectionViewLayout: The layout object that manages the collection view.
    ///   - indexPath: The index path of the item.
    /// - Returns: The size of the item.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        
        if Iphone678 || Iphone5orSE {
            collectionViewLayout?.sectionInset = UIEdgeInsets(top: 0, left: 15.0, bottom: 0, right: 15.0)
            collectionViewLayout?.invalidateLayout()
            let padding: CGFloat = 15
            let collectionViewSize = collectionView.frame.size.height - padding
            return CGSize(width: collectionViewSize / 2.0, height: collectionViewSize / 2.0)
        } else if IphoneXR {
            collectionViewLayout?.sectionInset = UIEdgeInsets(top: 10, left: 20.0, bottom: 10, right: 20.0)
            collectionViewLayout?.invalidateLayout()
            return CGSize(width: 160, height: 160)
        }
        
        let padding: CGFloat = 20
        let collectionViewSize = collectionView.frame.size.height - padding
        return CGSize(width: 160, height: 160)
    }
}

// MARK: - UICollectionViewDataSource
extension HomeVC: UICollectionViewDataSource {
    /// Asks your data source object for the number of items in the specified section of the collection view.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - section: An index number identifying a section in collectionView. This index value is 0-based.
    /// - Returns: The number of rows (items) in section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return browseList.count
    }
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - indexPath: The index path that specifies the location of the item.
    /// - Returns: A configured cell object. You must not return nil from this method.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "browseCell", for: indexPath) as! browseCell
        cell.lbl_title.text = browseList[indexPath.row]
        cell.lbl_title.font = boldSystem14
        cell.img_view.image = UIImage(named: browseList[indexPath.row])
        cell.lbl_title.numberOfLines = 0
        cell.lbl_title.minimumScaleFactor = 0.5
        cell.lbl_title.adjustsFontSizeToFitWidth = true
        cell.backgroundColor = bottomNavigationBgColorEnd.withAlphaComponent(0.3)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension HomeVC: UICollectionViewDelegate {
    /// Tells the delegate that the item at the specified index path was selected.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - indexPath: The index path of the cell that was selected.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
            vc?.headertitle = "UNITED STATES"
            vc?.country = "US"
            UserDefaults.standard.set(false, forKey: "country")
            self.navigationController?.pushViewController(vc!, animated: true)
        case 1:
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
            vc?.headertitle = "INTERNATIONAL CHARITIES REGISTERED IN USA"
            vc?.country = "INT"
            UserDefaults.standard.set(true, forKey: "country")
            self.navigationController?.pushViewController(vc!, animated: true)
        case 2:
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByNameVC") as? SearchByNameVC
            self.navigationController?.pushViewController(vc!, animated: true)
        case 3:
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AdvancedVC") as? AdvancedVC
            vc?.comingFromType = true
            self.navigationController?.pushViewController(vc!, animated: true)
        default:
            break
        }
    }
}
/// Custom UICollectionViewCell used in the browse collection view.
class browseCell: UICollectionViewCell {
    // The label displaying the title of the browse option.
    @IBOutlet var lbl_title: UILabel!
    
    // The image view displaying the image associated with the browse option.
    @IBOutlet var img_view: UIImageView!
}
