//
//  IntroVC.swift
//  iDonate
//
//  Created by Im043 on 16/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

///The IntroVC class is responsible for managing the introductory screen of the iDonate app. It displays a checkbox that allows users to indicate whether they want to see the intro screen in future launches. It also provides a skip button to navigate directly to the main screen after a certain duration. The class includes functionality to toggle the checkbox state, handle the skip action, and remove the intro screen. Additionally, it utilizes a timer to automatically remove the intro screen after a specified time interval.
class IntroVC: UIViewController,UIScrollViewDelegate {
    
    var timerIntro: Timer?
    var isChecked:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timerIntro = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(removeIntroScreen), userInfo: nil, repeats: false)
        
        // Do any additional setup after loading the view.
    }
    
    /**
     Action method triggered when the user taps the checkbox button to toggle its state.
     
     - Parameter sender: The UIButton that triggered the action.
     */
    @IBAction func checkBox(_ sender: UIButton) {
        if sender.isSelected == false {
            sender.isSelected = true
            isChecked = true
            UserDefaults.standard.set(true, forKey: "Intro")
        } else {
            sender.isSelected = false
            isChecked = false
            UserDefaults.standard.set(false, forKey: "Intro")
        }
    }
    
    /**
     Action method triggered when the user taps the skip button to skip the intro screen.
     
     - Parameter sender: The UIButton that triggered the action.
     */
    @IBAction func skip(_ sender: Any) {
        timerIntro?.invalidate()
        removeIntroScreen()
    }
    
    /**
     Method to remove the intro screen and navigate to the main screen.
     */
    @objc func removeIntroScreen() {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TapViewController") as? HomeTabViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }}
