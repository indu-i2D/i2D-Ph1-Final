//
//  annualrevenueViewController.swift
//  iDonate
//
//  Created by Im043 on 20/09/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

class AnnualRevenueViewController: BaseViewController {
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var bottomview: UIView!
    @IBOutlet weak var apply: UIButton!
    @IBOutlet weak var reset: UIButton!
    
    var butt1bool: Bool! = false
    var butt2bool: Bool! = false
    var butt3bool: Bool! = false
    var butt4bool: Bool! = false
    var butt5bool: Bool! = false
    
    
    var incomeFromArray = ["0","90001","200001","500001","1000001"]
    var incomeToArray = ["90000","200000","500000","1000000",""]
    
    var incomeFrom = ""
    var incomeTo = ""
    var taxDeductible = ""
    var address = ""
    var latitude = ""
    var longitude = ""
    var countryCode = ""
    
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
        
        if incomeFrom.count == 0{
            let alert = UIAlertController(title: "", message: "Returning to previous screen without making any changes?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.navigationController?.popViewController(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        

    }
    

    // butt 1
    
    @IBAction func backAction1(_sender:UIButton) {
        if  button2.backgroundColor == UIColor.clear || button3.backgroundColor == UIColor.clear || button4.backgroundColor == UIColor.clear || button5.backgroundColor == UIColor.clear {
            button1.setTitleColor(ivoryColor, for: .normal)
            colorSet(button: button1)
            UserDefaults.standard.set(true, forKey: "Search Selected")
            
            button2.backgroundColor = UIColor.clear
            button3.backgroundColor = UIColor.clear
            button4.backgroundColor = UIColor.clear
            button5.backgroundColor = UIColor.clear
            button2.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button3.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button4.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button5.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn],
                           animations: {
                            self.bottomview.isHidden = false
            }, completion: nil)
        }else {
            
            button1.setTitleColor(ivoryColor, for: .normal)
            colorSet(button: button1)
            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn],
                           animations: {
                            self.bottomview.isHidden = false
            }, completion: nil)
            
            button2.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button3.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button4.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button5.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button2.backgroundColor = UIColor.clear
            button3.backgroundColor = UIColor.clear
            button4.backgroundColor = UIColor.clear
            button5.backgroundColor = UIColor.clear
        }
        
        incomeFrom = incomeFromArray[_sender.tag]
        incomeTo = incomeToArray[_sender.tag]
    }

    // butt 2
    
    @IBAction func backAction2(_sender:UIButton) {
        if  button1.backgroundColor == UIColor.clear || button3.backgroundColor == UIColor.clear || button4.backgroundColor == UIColor.clear || button5.backgroundColor == UIColor.clear {
            button2.setTitleColor(ivoryColor, for: .normal)
            colorSet(button: button2)
            UserDefaults.standard.set(true, forKey: "Search Selected")
            
            button1.backgroundColor = UIColor.clear
            button3.backgroundColor = UIColor.clear
            button4.backgroundColor = UIColor.clear
            button5.backgroundColor = UIColor.clear
            button1.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button3.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button4.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button5.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn],
                           animations: {
                            self.bottomview.isHidden = false
            }, completion: nil)
        }else {
            
            button2.setTitleColor(ivoryColor, for: .normal)
            colorSet(button: button2)

            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn],
                           animations: {
                            self.bottomview.isHidden = false
            }, completion: nil)
            
            button1.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button3.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button4.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button5.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button1.backgroundColor = UIColor.clear
            button3.backgroundColor = UIColor.clear
            button4.backgroundColor = UIColor.clear
            button5.backgroundColor = UIColor.clear
        }
        incomeFrom = incomeFromArray[_sender.tag]
        incomeTo = incomeToArray[_sender.tag]
    }
    
    
    // butt 3
    
    @IBAction func backAction3(_sender:UIButton) {
        if  button2.backgroundColor == UIColor.clear || button1.backgroundColor == UIColor.clear || button4.backgroundColor == UIColor.clear || button5.backgroundColor == UIColor.clear {
            button3.setTitleColor(ivoryColor, for: .normal)
            colorSet(button: button3)
            UserDefaults.standard.set(true, forKey: "Search Selected")
            
            button2.backgroundColor = UIColor.clear
            button1.backgroundColor = UIColor.clear
            button4.backgroundColor = UIColor.clear
            button5.backgroundColor = UIColor.clear
            button2.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button1.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button4.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button5.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn],
                           animations: {
                            self.bottomview.isHidden = false
            }, completion: nil)
        }else {
            
            button3.setTitleColor(ivoryColor, for: .normal)
            colorSet(button: button3)
    
            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn],
                           animations: {
                            self.bottomview.isHidden = false
            }, completion: nil)
            
            button2.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button1.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button4.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button5.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button2.backgroundColor = UIColor.clear
            button1.backgroundColor = UIColor.clear
            button4.backgroundColor = UIColor.clear
            button5.backgroundColor = UIColor.clear
        }
        incomeFrom = incomeFromArray[_sender.tag]
        incomeTo = incomeToArray[_sender.tag]
    }
    
    // butt 4
    
    @IBAction func backAction4(_sender:UIButton) {
        if  button2.backgroundColor == UIColor.clear || button3.backgroundColor == UIColor.clear || button1.backgroundColor == UIColor.clear || button5.backgroundColor == UIColor.clear {
            button4.setTitleColor(ivoryColor, for: .normal)
            colorSet(button: button4)
            
            UserDefaults.standard.set(true, forKey: "Search Selected")
            button2.backgroundColor = UIColor.clear
            button3.backgroundColor = UIColor.clear
            button1.backgroundColor = UIColor.clear
            button5.backgroundColor = UIColor.clear
            
            button2.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button3.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button5.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            button1.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn],
                           animations: {
                            self.bottomview.isHidden = false
            }, completion: nil)
        }else {
            
            button4.setTitleColor(ivoryColor, for: .normal)
            colorSet(button: button4)
            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn],
                           animations: {
                            self.bottomview.isHidden = false
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
        incomeFrom = incomeFromArray[_sender.tag]
        incomeTo = incomeToArray[_sender.tag]
    }
    
    // butt 5
    
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
                            self.bottomview.isHidden = false
            }, completion: nil)
        }else {
            
            button5.setTitleColor(ivoryColor, for: .normal)
            colorSet(button: button5)
            UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseIn],
                           animations: {
                            self.bottomview.isHidden = false
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
    
    @IBAction func applyAction(_sender:UIButton) {
        
        switch countryCode {
        case "US":
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
            vc?.headertitle = "UNITED STATES"
            vc?.country = countryCode
            vc?.deductible = taxDeductible
            vc?.incomeFrom = incomeFrom
            vc?.incomeTo = incomeTo
            vc?.locationSearch = address
            vc?.hidesBottomBarWhenPushed = false
            self.navigationController?.pushViewController(vc!, animated: true)
            break
        case "INT":
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByLocationVC") as? SearchByLocationVC
            vc?.headertitle = "INTERNATIONAL CHARITIES REGISTERED IN USA"
            vc?.country = countryCode
            vc?.deductible = taxDeductible
            vc?.incomeFrom = incomeFrom
            vc?.incomeTo = incomeTo
            vc?.locationSearch = address
            vc?.hidesBottomBarWhenPushed = false
            self.navigationController?.pushViewController(vc!, animated: true)
            break
        default:
             let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchByNameVC") as? SearchByNameVC
             vc?.deductible = taxDeductible
             vc?.incomeFrom = incomeFrom
             vc?.incomeTo = incomeTo
             vc?.locationSearch = address
             self.navigationController?.pushViewController(vc!, animated: true)
            break
        }
    }
    
    @IBAction func resetAction(_sender:UIButton) {
        button1.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
        button2.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
        button3.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
        button4.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
        button5.setTitleColor(UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0), for: .normal)
        
        clearcolor(button: button1)
        clearcolor(button: button2)
        clearcolor(button: button3)
        clearcolor(button: button4)
        clearcolor(button: button5)
        
        UIView.animate(withDuration: 3.0, delay: 3.5, options: [.curveEaseOut],
                       animations: {
                        self.bottomview.isHidden = true
                        self.loadViewIfNeeded()
        }, completion: nil)
        
        incomeFrom = ""
        incomeTo = ""
    }
    
    
    func colorSet(button: UIButton) {
        button.backgroundColor = UIColor.init(red: 153/255, green: 112/255, blue: 146/255, alpha: 1.0)
    }
    
    func defaultcolorSet(button: UIButton) {
        button.backgroundColor = UIColor.init(red: 120/255, green: 82/255, blue: 65/255, alpha: 1.0)
    }
    
    func clearcolor(button: UIButton) {
        button.backgroundColor = UIColor.clear
    }
    
}
