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
import Firebase

class EntriesManager {
    
    static var entriesList = [Entry]()
    
    // MARK: Get Id Token
    static func getIdToken() -> Promise<String> {
        return Promise { seal in
            Auth.auth().currentUser!.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
                if error != nil { seal.reject(error!) }
                seal.fulfill(idToken!)
            })
        }
    }
    
    // MARK: Get Entries From Server
    static func getEntriesFromServer() -> Promise<[Entry]> {
        return genEntriesFromServer(fromMonthsAgo: 1)
    }
    
    // MARK: Get Entries From Server
    static func genEntriesFromServer(fromMonthsAgo months: Int) -> Promise<[Entry]> {
        return Promise { seal in
            getIdToken().done { (token) in
                let header = ["authorization": token]
                Alamofire.request(URL(string: QueryConfig.url.rawValue + QueryConfig.getEndPoint.rawValue + "?range=\(months)")!,
                                  method: .get,
                                  encoding: JSONEncoding.default,
                                  headers: header)
                .validate()
                .responseJSON { response in

                    switch response.result {
                    case .success(let value):
                        // parsing JSON
                        let dat = JSON(value)
                        print("INITIAL SERVER RESPONSE")
                        print(dat)
                        
                        self.entriesList.append(Entry(username: "joe mama, this is mhu real name",
                                                      location: [40.328562, 126.734141],
                                                      title: "Engaging in Forced Labor, Stuck in North Korea",
                                                      description: "SOS, I need to get out of this North Korean camp."))
                        
                        for ent in dat.array! {
                            self.entriesList.append(Entry(
                                username: String(describing: ent["userName"]),
                                location: [Double(String(describing: ent["userLat"]))!,
                                           Double(String(describing: ent["userLong"]))!],
                                title: String(describing: ent["title"]),
                                description: String(describing: ent["description"])
                            ))
                        }
                        
                        seal.fulfill(self.entriesList)
                        
                    case .failure:
                        seal.reject(response.error!)
                    }
                    
                }
            }
        }
    }
    
    // MARK: Post Data
    static func postEntry(data: [String: Any]) -> Promise<String> {
        return Promise { seal in
            print("[EntriesManager] attempting to send: \n\(data)")
            getIdToken().done { (token) in
                let header = ["authorization": token]
                Alamofire.request(URL(string: QueryConfig.url.rawValue + QueryConfig.postEndPoint.rawValue)!,
                                  method: .post,
                                  parameters: data,
                                  encoding: JSONEncoding.default,
                                  headers: header)
                .responseJSON { (res) in
                    switch res.result {
                    case .success:
                        seal.fulfill(res.description)
                    case .failure:
                        seal.reject(res.error!)
                    }
                }
            }
        }
    }
    
    // MARK: Attach Images to Post
    static func attachFiles(files: [Data], addTo id: String) {
        getIdToken().done { token in
            let header = ["authorization": token]
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    for i in 0 ... files.count - 1 {
                        multipartFormData.append(files[i], withName: "img\(i)", fileName: "img\(i).jpg", mimeType: "image/jpg")
                    }
                    multipartFormData.append(Data(id.utf8), withName: "id")
                },

                to: URL(string: QueryConfig.url.rawValue + QueryConfig.postEndPoint.rawValue)!,
                method: .post,
                headers: header
            )
            { (result) in
                switch result {
                case .success(let upload, _, _):

                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress: \(progress.fractionCompleted)")
                    })

                    upload.responseJSON { response in
                        print(response.result.value as Any)
                    }

                case .failure(let encodingError):
                    print(encodingError)
                }
            }

        }
    }
    
    // MARK: Get Post Images
    static func getPostImages (ofId id: String) -> [UIImage] {
        // TODO: Query post images based on post id
        return [UIImage]()
    }

    
}
