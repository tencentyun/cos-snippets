//
//  SecretStorage.swift
//  QCloudCOSXMLSwfitDemo
//
//  Created by karisli(李雪) on 2019/12/2.
//  Copyright © 2019 tencentyun.com. All rights reserved.
//

import Foundation
class SecretStorage: NSObject {
    var appID:NSString?;
    var secretID:NSString?;
    var secretKey:NSString?
    static let shared = SecretStorage();
    
    override init() {
        super.init();
        let path = Bundle.main.path(forResource: "key", ofType: "json");
        if path != nil {
            let jsondata = NSData.init(contentsOfFile: path!);
            
            if let usableData = jsondata {
                do {
                    let json = try JSONSerialization.jsonObject(with: usableData as Data, options: .mutableContainers)  as! [String:AnyObject]
                    let dic = json as Dictionary<String,Any>;
                    self.secretID = dic["secretID"] as? NSString;
                    self.secretKey = dic["secretKey"] as? NSString;
                } catch {
                    print("JSON Processing Failed")
                }
            }
            
        }
      
       
    }
    
}
