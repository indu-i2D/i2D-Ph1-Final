//
//  SearchByNameVC.swift
//  iDonate
//
//  Created by Im043 on 13/05/19.
//  Copyright © 2019 Im043. All rights reserved.
//

import UIKit

class SearchByLocationVC: BaseViewController,UITableViewDelegate,UITableViewDataSource {
   
     @IBOutlet var searchTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
  searchTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "searchcell")
        
        if(iDonateClass.hasSafeArea)
        {
            menuBtn.frame = CGRect(x: 10, y: 40, width: 24, height: 24)
        }
        else
        {
            menuBtn.frame = CGRect(x: 10, y: 30, width: 20, height: 20)
            
        }
        menuBtn.addTarget(self, action: #selector(backAction(_sender:)), for: .touchUpInside)
        self.view .addSubview(menuBtn)
        menuBtn.setBackgroundImage(UIImage(named: "back"), for: .normal)
        // Do any additional setup after loading the view.
    }
    @objc func backAction(_sender:UIButton)  {
        
        self.navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "searchcell") as! SearchTableViewCell
        let animation = AnimationFactory.makeMoveUpWithFade(rowHeight: 150, duration: 0.5, delayFactor: 0.05)
        let animator = Animator(animation: animation)
        animator.animate(cell: cell, at: indexPath, in: tableView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
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
