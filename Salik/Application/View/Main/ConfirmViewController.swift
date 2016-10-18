//
//  ConfirmViewController.swift
//  Salik
//
//  Created by ME on 6/20/16.
//  Copyright © 2016 com. All rights reserved.
//

import UIKit

class ConfirmViewController: BaseViewController {
    
    
    @IBOutlet weak var driver_name: UILabel!
    @IBOutlet weak var car_type: UILabel!
    @IBOutlet weak var car_plate_number: UILabel!
    @IBOutlet weak var pick_location: UILabel!
    @IBOutlet weak var phone_number: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        initUI()
    }
    
    func initUI() {
        driver_name.text = appData.order_driver_info.object(forKey: "driver_fullname") as? String
        car_type.text = appData.order_driver_info.object(forKey: "car_type") as? String
        car_plate_number.text = appData.order_driver_info.object(forKey: "car_plate_number") as? String
        pick_location.text = self.appController.getUserDefault(ORDER_LOCATION_ADDRESS) as? String
        phone_number.text = self.appController.getUserDefault(ORDER_PHONE_NUMBER) as? String
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
    
    @IBAction func onCall(_ sender: AnyObject) {
        let url = URL(string: "tel://8000005")
        UIApplication.shared.openURL(url!)
    }
    
    func goHome() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        self.navigationController!.popToViewController(viewControllers[0], animated: true);
    }
    
    func test() {
        print("TEST")
    }
}
