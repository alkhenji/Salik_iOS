//
//  OrderViewController.swift
//  Salik
//
//  Created by ME on 6/7/16.
//  Copyright © 2016 com. All rights reserved.
//

import UIKit


class OrderViewController: BaseViewController{
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var carInfoLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var circleImageView: UIImageView!
    
    @IBOutlet weak var minuteLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    var timer:NSTimer = NSTimer();
    var startTime = NSTimeInterval()
    
    let params: NSMutableDictionary = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad();
      
        startTimer()
        initData()
        self.initView()
    }
    
    func initData(){
        
    }
    
    func initView(){
        locationLabel.text = appData.order_location_address
        phoneNumberLabel.text = appData.user_phone_number
        if appData.isSelectedCar == true {
            carInfoLabel.text = appData.car_info[appData.selected_car_index]["car_type"]
        } else if appData.isSelectedDeliery == true{
            carInfoLabel.text = "QAR (20)"

        }
        appController.setBorderView(cancelButton, color: UIColor(red: 45/255.0, green: 190/255/0, blue: 221/255.0, alpha: 1.0), width: 1.0)
         appController.setBorderView(circleImageView, color: UIColor(red: 45/255.0, green: 190/255/0, blue: 221/255.0, alpha: 1.0), width: 2.0)
        appController.cropCircleImage(circleImageView)
    }
    
    func startTimer() {
        if (!timer.valid) {
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(OrderViewController.timeUpdate), userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate()
        }

        
    }
    
    func timeUpdate()  {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        //Find the difference between current time and start time.
        var elapsedTime: NSTimeInterval = currentTime - startTime
        
        //calculate the minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)

        let strMinutes = String(format: "%01d", 4-minutes)
        let strSeconds = String(format: "%02d", 59-seconds)
      
        minuteLabel.text = strMinutes
        secondLabel.text = strSeconds
        
        if minuteLabel.text == "0" && secondLabel.text == "00"{
            stopTimer()
        }
        
    }
    
    func stopTimer() {
        timer.invalidate()
        let alertController = self.appController.showAlert("Warning!", message: "Please contact support!")
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func initAppData(){
        appData.selected_car_index = -1
//        appData.order_location_address = ""
        appData.user_comment = ""
        appData.user_phone_number = ""
    }
    
    func goHome() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        self.navigationController!.popToViewController(viewControllers[0], animated: true);
    }
    
    //MARK: Custom Action
  
    @IBAction func onCall(sender: UIButton) {
        let url = NSURL(string: "tel://8000005")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func onCancel(sender: UIButton) {
        setParams()
        showConfirmDialog()
    }
    
    func setParams() {
//        params.setValue(appData.order_id, forKey: ORDER_ID)
        params.setValue(appController.getUserDefault(ORDER_ID), forKey: ORDER_ID)
    }
    
    func showConfirmDialog(){
        let alertController = UIAlertController(title: "Order Cancel", message: "Are you sure?", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
            self.orderCancel()
        }
        let noAction = UIAlertAction(title:"No", style: .Default){ (action) -> Void in
            
        }
        alertController.addAction(okAction)
        alertController.addAction(noAction)
        
        
        presentViewController(alertController, animated: true, completion: nil)

    }
    
    func orderCancel(){
        timer.invalidate()
        
        let window = UIApplication.sharedApplication().keyWindow!
        self.appController.showActivityIndicator(window)
        
        appController.httpRequest(API_ORDER_CANCEL, params: params, completion: { result in
            
            dispatch_async(dispatch_get_main_queue(), {
                self.appController.hideActivityIndicator(window)
                
            })
            
            let status: Int = result.objectForKey(STATUS) as!  Int
            if status == 1 {
                self.initAppData()
                dispatch_async(dispatch_get_main_queue(), {
                    self.goHome()
                    return
                })
            } else{
            
                dispatch_async(dispatch_get_main_queue(), {
                    let alertController = self.appController.showAlert("Error!", message: "Check your Internet connection!")
                    self.presentViewController(alertController, animated: true, completion: nil)
                    return
                })
            }
            }, errors: {
                dispatch_async(dispatch_get_main_queue(), {
                    self.appController.hideActivityIndicator(window)
                    
                })
                dispatch_async(dispatch_get_main_queue(), {
                    let alertController = self.appController.showAlert("Error!", message: "Check your Internet connection!")
                    self.presentViewController(alertController, animated: true, completion: nil)
                    return
                })
        })
    }
    
    func orderConfirm(){
        let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ConfirmViewController") as! ConfirmViewController
        pushFromLeft(nextViewController)
    }
    
   
}
