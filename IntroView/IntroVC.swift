//
//  IntroVC.swift
//  iDonate
//
//  Created by Im043 on 16/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

class IntroVC: UIViewController,UIScrollViewDelegate {
    
    var timerIntro: Timer?
    var isChecked:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timerIntro = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(removeIntroScreen), userInfo: nil, repeats: false)
            
        // Do any additional setup after loading the view.
    }
    
    @IBAction func checkBox(_ sender: UIButton) {
        if(sender.isSelected == false){
            sender.isSelected = true
            isChecked = true
            UserDefaults.standard.set(true, forKey: "Intro")
        }
        else{
            sender.isSelected = false
            isChecked = false
            UserDefaults.standard.set(false, forKey: "Intro")
        }
    }
    
    @IBAction func skip(_ sender: Any){
        timerIntro?.invalidate()
        removeIntroScreen()
    }
    
    @objc func removeIntroScreen() {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
        self.navigationController?.pushViewController(vc!, animated: true)
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
