//
//  NewViewfromadvancedSearchViewController.swift
//  iDonate
//
//  Created by Im043 on 20/09/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

class NewViewfromadvancedSearchViewController: BaseViewController {
    
    @IBOutlet weak var exempt: UIButton!
    @IBOutlet weak var notexempt: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    var deductible = ""
    var countryCode = ""
    var latitude = ""
    var longitude = ""
    var address = ""
    override func viewWillAppear(_ animated: Bool) {
        if "\(UserDefaults.standard.value(forKey: "TaxDetectable") ?? "")" == ""{
            self.bottomView.isHidden = true
        }
        else{
            self.bottomView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(iDonateClass.hasSafeArea){
            menuBtn.frame = CGRect(x: 0, y: 40, width: 50, height: 50)
        }else {
            menuBtn.frame = CGRect(x: 0, y: 20, width: 50, height: 50)
        }
        
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
    }
    
    @objc func backAction(_sender:UIButton)  {
        let alert = UIAlertController(title: "", message: "Returning To previous screen without making changes?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            UserDefaults.standard.set("", forKey: "TaxDetectable")
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func applyAction(_ sender: Any) {
        switch countryCode {
        case "US":
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
            vc?.headertitle = "UNITED STATES"
            vc?.country = countryCode
            vc?.deductible = deductible
            vc?.locationSearch = address
            vc?.lattitude = latitude
            vc?.longitute = longitude
            vc?.hidesBottomBarWhenPushed = false
            self.navigationController?.pushViewController(vc!, animated: true)
            break
        case "INT":
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
            vc?.headertitle = "INTERNATIONAL CHARITIES REGISTERED IN USA"
            vc?.country = countryCode
            vc?.deductible = deductible
            vc?.locationSearch = address
            vc?.lattitude = latitude
            vc?.longitute = longitude
            vc?.hidesBottomBarWhenPushed = false
            self.navigationController?.pushViewController(vc!, animated: true)
            break
        default:
             let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByNameVC") as? SearchByNameVC
             vc?.deductible = deductible
             vc?.locationSearch = address
             vc?.lattitude = latitude
             vc?.longitute = longitude
             self.navigationController?.pushViewController(vc!, animated: true)
            break
        }
    }
    
    @IBAction func resetAction(_ sender: Any) {
        exempt.backgroundColor = UIColor.clear
        exempt.setTitleColor(UIColor(red:0.60, green:0.44, blue:0.57, alpha:1.0), for: .normal)
        notexempt.backgroundColor = UIColor.clear
        notexempt.setTitleColor(UIColor(red:0.60, green:0.44, blue:0.57, alpha:1.0), for: .normal)
        deductible = ""
        UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseOut],
                       animations: {
                        self.bottomView.isHidden = true
                        self.loadViewIfNeeded()
        }, completion: nil)
        
        UserDefaults.standard.set("", forKey: "TaxDetectable")

    }
    
    @IBAction func exemptAction(_ sender: Any) {
        exempt.setTitleColor(ivoryColor, for: .normal)
        exempt.backgroundColor = UIColor.init(red: 153/255, green: 112/255, blue: 146/255, alpha: 1.0)
        notexempt.backgroundColor = UIColor.clear
        notexempt.setTitleColor(UIColor(red:0.60, green:0.44, blue:0.57, alpha:1.0), for: .normal)
        deductible = "1"
        UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn],
                       animations: {
                        self.bottomView.isHidden = false
        }, completion: nil)
        
        UserDefaults.standard.set("1", forKey: "TaxDetectable")
    }
    
    @IBAction func notExemptAction(_ sender: Any) {
        notexempt.setTitleColor(ivoryColor, for: .normal)
        notexempt.backgroundColor = UIColor.init(red: 153/255, green: 112/255, blue: 146/255, alpha: 1.0)
        exempt.backgroundColor = UIColor.clear
        exempt.setTitleColor(UIColor(red:0.60, green:0.44, blue:0.57, alpha:1.0), for: .normal)
        deductible = "0"
        UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn],
                       animations: {
                        self.bottomView.isHidden = false
        }, completion: nil)
        UserDefaults.standard.set("0", forKey: "TaxDetectable")
    }
    
    @IBAction func showSearchByTypes(_ sender: Any) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AdvancedVC") as? AdvancedVC
        vc?.address = address
        vc?.latitude = latitude
        vc?.longitude = longitude
        vc?.countryCode = countryCode
        vc?.taxDeductible = deductible
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    @IBAction func showAnnualReview(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AnnualRevenueViewController") as? AnnualRevenueViewController
        vc?.address = address
        vc?.latitude = latitude
        vc?.longitude = longitude
        vc?.countryCode = countryCode
        vc?.taxDeductible = deductible
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}
