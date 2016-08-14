//
//  AppController.swift
//  Salik
//
//  Created by ME on 6/7/16.
//  Copyright © 2016 com. All rights reserved.
//

import UIKit

class AppController: NSObject {
    
    class var sharedInstance: AppController {
        struct Static {
            static let instance: AppController = AppController()
        }
        return Static.instance
    }

    var screen: CGRect = UIScreen.mainScreen().bounds

    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }

    
    func showActivityIndicator(uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColorFromHex(0x000000, alpha: 0.5)
        
        loadingView.frame = CGRectMake(0, 0, (screen.size.width * 80) / 414, (screen.size.height * 80) / 736)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColorFromHex(0x444444, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRectMake(0, 0, (screen.size.width * 40) / 414, (screen.size.height * 40) / 736)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.center = CGPointMake(loadingView.frame.size.width / 2, loadingView.frame.size.height / 2);
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator(uiView: UIView) {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
        
    }

    // Common Utils Functions
    func showAlert (title: String, message: String) ->UIAlertController{
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
        }
        alertController.addAction(okAction)
        return alertController
    }
    func getUserDefault (key: String) -> AnyObject{
        var val: AnyObject! = NSUserDefaults.standardUserDefaults().objectForKey(key)
        if (val.isKindOfClass(NSString) && (val == nil || val.isEqualToString("0"))){
            val = nil
        }
        return val
    }
    func setUserDefault (key: String, val: AnyObject){
        
        var value: AnyObject! = val
        if (val.isKindOfClass(NSString) && val.isEqualToString("")) {
            value = "0"
        }
        NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
    }
    func removeUserDefault (key: String){
        NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
    }
    func setUserDefaultDic(key: String, dic: NSMutableDictionary){
        var newKey: String = ""
        for dicKey in dic.allKeys {
            newKey = key.stringByAppendingString("_").stringByAppendingString(dicKey as! String)
            self.setUserDefault(newKey, val: dic.objectForKey(dicKey)!)
        }
    }
    func getUserDefaultDic(key:String) -> NSMutableDictionary {
        
        let dic: NSMutableDictionary! = NSMutableDictionary()
        let dicAll = NSUserDefaults.standardUserDefaults().dictionaryRepresentation()
        
        for dicKey:NSString in dicAll.keys {
            if (dicKey.rangeOfString(key.stringByAppendingString("_")).location != NSNotFound) {
                dic.setObject(NSUserDefaults.standardUserDefaults().objectForKey(dicKey as String)!, forKey: key.stringByAppendingString("_").stringByAppendingString(dicKey as String))
            }
        }
        
        return dic
    }
    func setUserDefaultMutableArray(key: String, array: NSMutableArray){
        
        let dataSave: NSData = NSKeyedArchiver.archivedDataWithRootObject(array)
        NSUserDefaults.standardUserDefaults().setObject(dataSave, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    func getUserDefaultMutableArray(key: String) -> NSMutableArray {
        
        let data: NSData! = NSUserDefaults.standardUserDefaults().objectForKey(key) as! NSData
        let savedArray: NSMutableArray! = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSMutableArray
        return savedArray
    }
    func removeUserDefaultNutableArray(key: String) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
    }
    
    func cropCircleImage (imageView: UIImageView){
        var maxScaleLength: CGFloat!
        maxScaleLength = imageView.frame.size.width
        if (imageView.frame.size.height > maxScaleLength) {
            maxScaleLength = imageView.frame.size.height
        }
        imageView.frame.size = CGSizeMake(maxScaleLength, maxScaleLength)
        imageView.layer.cornerRadius = maxScaleLength/2
        imageView.clipsToBounds = true
    }
    func setRoundRectBorderButton(button: UIButton, borderWidth: CGFloat, borderColor: UIColor, borderRadius: CGFloat){
        
        button.clipsToBounds = true
        button.layer.cornerRadius = borderRadius
        button.layer.borderColor = borderColor.CGColor
        button.layer.borderWidth = borderWidth
    }
    func setRoundRectView(view: UIView, cornerRadius: CGFloat){
        
        view.clipsToBounds = true
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = true
    }
    
    func setBorderView(view: UIView, color:UIColor, width:CGFloat) {
        view.layer.borderColor = color.CGColor
        view.layer.borderWidth = width
    }
    
    func httpRequest(url: String, params: NSMutableDictionary, completion: (NSMutableDictionary) -> (), errors: () ->()) {
        
        var result: NSMutableDictionary = NSMutableDictionary()
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var body: NSData!
        
        do{
            body = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
            request.HTTPBody = body
        } catch let error as NSError{
            print("A JSON parsing error occurred, here are the details:\n \(error)")

        }
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue(API_KEY, forHTTPHeaderField: "api-key")
        request.addValue(String(body.length), forHTTPHeaderField: "Content-Length")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if let httpResponse = response as? NSHTTPURLResponse{
                print(httpResponse.statusCode)
                if httpResponse.statusCode == 200
                {
                    do{
                        result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSMutableDictionary
                        print(result)
                        completion(result)
                        
                    } catch let error as NSError{
                        print("A JSON parsing error occurred, here are the details:\n \(error)")
                        errors()
                    }
                } else{
                    print("response was not 200: \(response)")
                    errors()
                }
            }
            if error != nil{
                print("response was not 200: \(error)")
                errors()
            }
            
        }
        
        task.resume()

        }
    
}
