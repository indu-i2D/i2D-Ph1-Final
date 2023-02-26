//
//  TapViewController.swift
//  iDonate
//
//  Created by Im043 on 16/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

class HomeTabViewController: UITabBarController {
  @IBOutlet var notificationTabBar: UITabBar!
    
    let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let browseViewController = storyBoard.instantiateViewController(withIdentifier: "HomeVC")
        let spaceViewController = storyBoard.instantiateViewController(withIdentifier: "MySpaceVC")

        browseViewController.tabBarItem = UITabBarItem(title: "Browse", image: #imageLiteral(resourceName: "browse").withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "browseselected").withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
        spaceViewController.tabBarItem = UITabBarItem(title: "My Space", image: #imageLiteral(resourceName: "myspace").withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "myspaceselected").withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : Login_registerBtnColor], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : ivoryColor], for: .selected)
        
        // Do any additional setup after loading the view.
                
        let layerGradient = CAGradientLayer()
        layerGradient.colors = [bottomNavigationBgColorStart.cgColor, bottomNavigationBgColorEnd.cgColor]
        layerGradient.startPoint = CGPoint(x: 0, y: 0.5)
        layerGradient.endPoint = CGPoint(x: 1, y: 0.5)
        layerGradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        self.tabBar.layer.insertSublayer(layerGradient, at: 0)
        
        
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
