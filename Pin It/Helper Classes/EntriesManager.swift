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
                if let idToken = idToken {
                    seal.fulfill(idToken)
                } else {
                    seal.reject(error!)
                }
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
                                                      description: "SOS, I need to get out of this North Korean camp. \n\nThe Democratic People's Republic of Korea is a genuine workers' state in which all the people are completely liberated from exploitation and oppression. \n\nThe workers, peasants, soldiers and intellectuals are the true masters of their destiny and are in a unique position to defend their interests.",
                                                      id: "some id"))
                        
                        for ent in dat.array! {
                            self.entriesList.append(Entry(
                                username: String(describing: ent["userName"]),
                                location: [Double(String(describing: ent["userLat"]))!,
                                           Double(String(describing: ent["userLong"]))!],
                                title: String(describing: ent["title"]),
                                description: String(describing: ent["description"]),
                                id: String(describing: ent["pinId"])
                            ))
                        }
                        
                        seal.fulfill(self.entriesList)
                        
                    case .failure:
                        seal.reject(response.error!)
                    }
                    
                }
            }.catch { (err) in
                seal.reject(err)
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
            }.catch { (err) in
                seal.reject(err)
            }
        }
    }
    
    // MARK: Attach Images to Post
    static func attachImageFiles(files: [UIImage], addTo id: String) -> Promise<Void> {
        return Promise { seal in
            if(files.isEmpty) {
                seal.fulfill(Void())
                return
            }
            for i in 0 ... files.count - 1 {
                let uploadRef = Storage.storage().reference(withPath: "/\(id)/img-\(i).jpg")
                guard let imageData = files[i].jpegData(compressionQuality: 0.75) else { continue }
                let upload = StorageMetadata.init()
                upload.contentType = "image/jpeg"
                let ref = uploadRef.putData(imageData, metadata: upload) { (dat, err) in
                    if let err = err {
                        print("[EntriesManager] Error while uploading image:\n\(err)")
                        seal.reject(err)
                    }
                    print(dat as Any?)
                }
                
                if (i == files.count - 1) {
                    ref.observe(.success) { _ in
                        print("[EntriesManager] Image upload successful for post \(id)")
                        seal.fulfill(Void())
                    }
                }
            }
        }
    }
    
    // MARK: Get Post Images
    static func getPostImages (ofId id: String) -> Promise<[UIImage]> {
        return Promise { seal in
            var assets = [UIImage]()
            let ref = Storage.storage().reference(withPath: id)
            ref.listAll(completion: {(list, err) in
                if let err = err { seal.reject(err) }
                print("Attempting to download images")
                for imgRef in list.items {
                    print(imgRef)
                    imgRef.getData(maxSize: 700 * 1024 * 1024) { (dat, err) in
                        if let err = err { seal.reject(err) }
                        assets.append(UIImage(data: dat!)!)
                        if (assets.count == list.items.count) { seal.fulfill(assets) }
                    }
                }
            })
        }
    }

}
