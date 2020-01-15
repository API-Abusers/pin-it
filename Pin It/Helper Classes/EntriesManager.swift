////
////  EntriesManager.swift
////  Pin It
////
////  Created by Joseph Jin on 1/10/20.
////  Copyright © 2020 AnimatorJoe. All rights reserved.
////
//
//import Foundation
//import Alamofire
//
//class EntriesManager {
//    
//    static var entriesList = [Entry]()
//    
//    static func getEntriesFromServer() -> Result<[Entry], Error> {
//        
//        let data = ["pinId": "-1162172850807958123"]
//
//        // MARK: queries the server and update the entriesList
//        Alamofire.request(URL(string: QueryConfig.url.rawValue + QueryConfig.getEndPoint.rawValue)!,
//                          method: .get,
//                          encoding: JSONEncoding.default,
//                          headers: data)
//            .then { response in
//                
////            print("the response ")
////            print(response)
////
////            print(response.request)   // original url request
////            print(response.response) // http url response
////            print(response.result)  // response serialization result
//            if let json = response.result.value {
//                print("JSON: \(json)") // serialized json response
//                guard let dat = json as? [String: Any] else {
//                    print("JSON parsing failed, bye bye")
//                    return
//                }
//                
//                entriesList.append(Entry(username: dat["userName"] as! String,
//                                         location: [dat["userLat"] as! Double,
//                                                    dat["userLong"] as! Double],
//                                         title: dat["title"] as! String,
//                                         description: dat["description"] as! String))
//            }
//            return entriesList
//        }
//    
//        // add test entry
//        entriesList.append(Entry(username: "joe mama", location: [40.328562, 126.734141], title: "Engaging in Forced Labor", description: "SOS, I need to get out of this North Korean camp."))
//        print("entries list")
//        print(entriesList)
//
////        return entriesList
//        
//    }
//}
