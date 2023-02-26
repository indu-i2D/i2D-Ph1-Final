//
//  ResultVC.swift
//  iDonate
//
//  Created by Im043 on 27/07/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

class ResultVC: BaseViewController {
    
    var timerIntro: Timer?
    var donateType:String = ""
     @IBOutlet weak var amountText: UILabel!
    override func viewDidLoad() {
        
        let amountString = UserDefaults.standard.value(forKey: "Amount") as! String
        amountText.text = amountString
        super.viewDidLoad()
        timerIntro = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(gotAction), userInfo: nil, repeats: false)

        // Do any additional setup after loading the view.
    }
    
    
    func popViewControllerss(popViews: Int, animated: Bool = true) {
        if self.navigationController!.viewControllers.count > popViews
        {
            let vc = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - popViews - 1]
            self.navigationController?.popToViewController(vc, animated: animated)
        }
    }
    
    @IBAction func gotAction(_ sender: Any){
        self.popViewControllerss(popViews: 2)
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
