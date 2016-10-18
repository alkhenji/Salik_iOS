//
//  WelcomeViewController.swift
//  Salik
//
//  Created by ME on 6/7/16.
//  Copyright © 2016 com. All rights reserved.
//

import UIKit

class WelcomeViewController: BaseViewController {
    
    @IBOutlet weak var pageContol: UIPageControl!
    
    @IBOutlet weak var firstView: UIView!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
       
    @IBAction func next(_ sender: UIButton) {
        
        let carSelectViewController = self.storyboard!.instantiateViewController(withIdentifier: "CarSelectViewController") as! CarSelectViewController
        
        pushFromLeft(carSelectViewController)

       

    }
    
}
