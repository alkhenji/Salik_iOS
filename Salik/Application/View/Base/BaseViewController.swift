//
//  BaseViewController.swift
//  Salik
//
//  Created by ME on 6/7/16.
//  Copyright © 2016 com. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    var isLodingBase:Bool!
    var appController = AppController.sharedInstance
    var appData = AppData.sharedInstance
        
    override func viewDidLoad() {
        super.viewDidLoad();
        isLodingBase = false

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Change Status Bar Style
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func navToBack(sender: UIButton) {
        if (self.isLodingBase == true) {
            return
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func pushFromLeft(vc:UIViewController){
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        
        self.navigationController!.view.layer.addAnimation(transition, forKey: kCATransition)        
        self.navigationController!.pushViewController(vc, animated: false)
    }
    
    @IBAction func popFromRight(){
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.45;
        transition.timingFunction = timeFunc
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromRight;
        
        self.navigationController!.view.layer.addAnimation(transition, forKey: kCATransition)
        self.navigationController!.popViewControllerAnimated(true)


    }
    
    

}
