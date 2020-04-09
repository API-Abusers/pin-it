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
import FirebaseFirestore

class EntriesManager {
    
    static var entriesList = [Entry]()
    static var db = Firestore.firestore()
    static var imageCache = NSCache<NSString, UIImage>()
    
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
            
            self.entriesList.append(Entry(username: "joe mama, this is mhu real name",
                                          location: [40.328562, 126.734141],
                                          title: "Engaging in Forced Labor, Stuck in North Korea",
                                          description: "SOS, I need to get out of this North Korean camp. \n\nThe Democratic People's Republic of Korea is a genuine workers' state in which all the people are completely liberated from exploitation and oppression. \n\nThe workers, peasants, soldiers and intellectuals are the true masters of their destiny and are in a unique position to defend their interests.",
                                          id: "some id"))
            print("[EntriesManager]: Retrieving Posts\n\(self.entriesList)")
            db.collection("posts").getDocuments() { (querySnapshot, err) in
                if let err = err { seal.reject(err) }
                for document in querySnapshot!.documents {
                    let ent = document.data() as [String : Any]
                    print(ent)
                    self.entriesList.append(Entry(
                        username: ent["userName"] as! String,
                        location: [ent["userLat"] as! Double,
                                   ent["userLong"] as! Double],
                        title: ent["title"] as! String,
                        description: ent["description"] as! String,
                        id: ent["id"] as! String))
                }
                seal.fulfill(self.entriesList)
            }
        }
    }
    
    // MARK: Post Data
    static func postEntry(data: [String: Any]) -> Promise<Void> {
        return Promise { seal in
            let ref = db.document("posts/\(data["id"] as! String)")
            ref.setData(data) { (err) in
                if let err = err { seal.reject(err) }
                else {
                    print("[EntriesManager]: post uploaded\n\(data)")
                    seal.fulfill(Void())
                }
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
                print("[EntriesManager]: Attempting to download images")
                for (ind, imgRef) in list.items.enumerated() {
                    let key = String(describing: imgRef) as NSString
                    
                    if let img = imageCache.object(forKey: key) {
                        print("reading from cache for \(imgRef)")
                        assets.append(img)
                        if (ind == list.items.count - 1) { seal.fulfill(assets) }
                        continue
                    }
                    

                    print("downloading \(imgRef)")
                    imgRef.getData(maxSize: 700 * 1024 * 1024) { (dat, err) in
                        if let err = err { seal.reject(err) }
                        
                        print("caching \(imgRef)")
                        let img = UIImage(data: dat!)!
                        
                        imageCache.setObject(img, forKey: key)
                        assets.append(img)
                        
                        if (ind == list.items.count - 1) { seal.fulfill(assets) }
                    }
                }
            })
        }
    }

}
