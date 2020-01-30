//
//  EntriesManager.swift
//  Pin It
//
//  Created by Joseph Jin on 1/10/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

class EntriesManager {
    
    static var entriesList = [Entry]()
    
    // MARK: Get Entries From Server
    static func getEntriesFromServer() -> Promise<[Entry]> {

        let data = ["pinId": "-1162172850807958123"]
        
        return Promise { seal in
            Alamofire.request(URL(string: QueryConfig.url.rawValue + QueryConfig.getEndPoint.rawValue)!,
                              method: .get,
                              encoding: JSONEncoding.default,
                              headers: data)
                .validate()
                .responseJSON { response in

                    switch response.result {
                    case .success(let value):
                        // parsing JSON
                        let dat = JSON(value)
                        print("INITIAL SERVER RESPONSE")
                        print(dat)
                        
//                        self.entriesList.append(Entry(
//                            username: String(describing: dat["userName"]),
//                            location: [Double(String(describing: dat["userLat"]))!,
//                                       Double(String(describing: dat["userLong"]))!],
//                            title: String(describing: dat["title"]),
//                            description: String(describing: dat["description"])))
                        
                        self.entriesList.append(Entry(username: "joe mama, this is mhu real name",
                                                      location: [40.328562, 126.734141],
                                                      title: "Engaging in Forced Labor, Stuck in North Korea",
                                                      description: "SOS, I need to get out of this North Korean camp."))
                        
                        seal.fulfill(self.entriesList)
                        
                    case .failure:
                        seal.reject(response.error!)
                    }
                    
            }
        }
    
    }
}
