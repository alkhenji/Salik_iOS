//
//  AppController.swift
//  Salik
//
//  Created by ME on 6/7/16.
//  Copyright © 2016 com. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class AppController: NSObject {
    
    class var sharedInstance: AppController {
        struct Static {
            static let instance: AppController = AppController()
        }
        return Static.instance
    }

    var screen: CGRect = UIScreen.main.bounds

    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func UIColorFromHex(_ rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }

    
    func showActivityIndicator(_ uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColorFromHex(0x000000, alpha: 0.5)
        
        loadingView.frame = CGRect(x: 0, y: 0, width: (screen.size.width * 80) / 414, height: (screen.size.height * 80) / 736)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColorFromHex(0x444444, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: (screen.size.width * 40) / 414, height: (screen.size.height * 40) / 736)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2);
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator(_ uiView: UIView) {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
        
    }

    // Common Utils Functions
    func showAlert (_ title: String, message: String) ->UIAlertController{
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
        }
        alertController.addAction(okAction)
        return alertController
    }
    func getUserDefault (_ key: String) -> AnyObject{
        var val: AnyObject! = UserDefaults.standard.object(forKey: key) as AnyObject!

        if (val is String && (val == nil || val.isEqual(to: "0"))){
            val = nil
        }
        return val
    }
    func setUserDefault (_ key: String, val: AnyObject){
        
        var value: AnyObject! = val
        if (val is String && val.isEqual(to: "")) {
            value = "0" as AnyObject!
        }
        UserDefaults.standard.set(value, forKey: key)
    }
    func removeUserDefault (_ key: String){
        UserDefaults.standard.removeObject(forKey: key)
    }
    func setUserDefaultDic(_ key: String, dic: NSMutableDictionary){
        var newKey: String = ""
        for dicKey in dic.allKeys {
            newKey = (key + "_") + (dicKey as! String)
            self.setUserDefault(newKey, val: dic.object(forKey: dicKey)! as AnyObject)
        }
    }
    func getUserDefaultDic(_ key:String) -> NSMutableDictionary {
        
        let dic: NSMutableDictionary! = NSMutableDictionary()
        let dicAll = UserDefaults.standard.dictionaryRepresentation()
        
        for dicKey:String in dicAll.keys {

            if ((dicKey.range(of: key + "_")) != nil) {
                let strKey : String = key + "_" + dicKey
                dic.setObject(UserDefaults.standard.object(forKey: dicKey), forKey:strKey as NSCopying)
            }
        }

        return dic
    }
    func setUserDefaultMutableArray(_ key: String, array: NSMutableArray){
        
        let dataSave: Data = NSKeyedArchiver.archivedData(withRootObject: array)
        UserDefaults.standard.set(dataSave, forKey: key)
        UserDefaults.standard.synchronize()
    }
    func getUserDefaultMutableArray(_ key: String) -> NSMutableArray {
        
        let data: Data! = UserDefaults.standard.object(forKey: key) as! Data
        let savedArray: NSMutableArray! = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSMutableArray
        return savedArray
    }
    func removeUserDefaultNutableArray(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    func cropCircleImage (_ imageView: UIImageView){
        var maxScaleLength: CGFloat!
        maxScaleLength = imageView.frame.size.width
        if (imageView.frame.size.height > maxScaleLength) {
            maxScaleLength = imageView.frame.size.height
        }
        imageView.frame.size = CGSize(width: maxScaleLength, height: maxScaleLength)
        imageView.layer.cornerRadius = maxScaleLength/2
        imageView.clipsToBounds = true
    }
    func setRoundRectBorderButton(_ button: UIButton, borderWidth: CGFloat, borderColor: UIColor, borderRadius: CGFloat){
        
        button.clipsToBounds = true
        button.layer.cornerRadius = borderRadius
        button.layer.borderColor = borderColor.cgColor
        button.layer.borderWidth = borderWidth
    }
    func setRoundRectView(_ view: UIView, cornerRadius: CGFloat){
        
        view.clipsToBounds = true
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = true
    }
    
    func setBorderView(_ view: UIView, color:UIColor, width:CGFloat) {
        view.layer.borderColor = color.cgColor
        view.layer.borderWidth = width
    }
    
    func httpRequest(_ url: String, params: NSMutableDictionary, completion: @escaping (NSMutableDictionary) -> (), errors: @escaping () ->()) {
        
        var result: NSMutableDictionary = NSMutableDictionary()
        
        var request = URLRequest(url: URL(string: url)!)
        var body: Data!
        
        do{
            body = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
            request.httpBody = body
        } catch let error as NSError{
            print("A JSON parsing error occurred, here are the details:\n \(error)")

        }
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue(API_KEY, forHTTPHeaderField: "api-key")
        request.addValue(String(body.count), forHTTPHeaderField: "Content-Length")

        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse{
                print(httpResponse.statusCode)
                if httpResponse.statusCode == 200
                {

                        let tempDict = self.convertStringToDictionary(text: data!)

                    if (tempDict != nil){
                        result = NSMutableDictionary.init(dictionary: tempDict!)
                        print(result)
                        completion(result)
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
            
        })
        
        task.resume()

        }

    func convertStringToDictionary(text: Data) -> [String:AnyObject]? {

            do {
                return try JSONSerialization.jsonObject(with: text, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)

        }
        return nil
    }
    
}
