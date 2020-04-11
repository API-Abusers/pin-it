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
    
    static var db = Firestore.firestore()
    static var imageCache = NSCache<NSString, UIImage>()
    static var query: Query!
    static var lastDoc: QueryDocumentSnapshot!
    static var batchSize = 1
    
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
    
    // MARK: Return An Entry For A Given Document
    static func getEntry(from doc: QueryDocumentSnapshot) -> Entry? {
        let doc = doc.data() as [String : Any]
        if let userName = doc["userName"] as? String,
            let lat = doc["userLat"] as? Double,
            let long = doc["userLong"] as? Double,
            let title = doc["title"] as? String,
            let desc = doc["description"] as? String,
            let id = doc["id"] as? String {
            return Entry(username: userName, location: [lat, long], title: title, desc: desc, id: id)
        }
        return nil
    }
    
    // MARK: Get Entries From Server
    static func getEntriesFromServer() -> Promise<[Entry]> {
        return Promise { seal in
            var entriesList = [Entry]()
            if lastDoc == nil {
                entriesList.append(Entry(username: "this is a really long user name to see if the ui breaks",
                                         location: [40.328562, 126.734141],
                                         title: "Engaging in Forced Labor, Stuck in North Korea",
                                         desc: "SOS, I need to get out of this North Korean camp. \n\nThe Democratic People's Republic of Korea is a genuine workers' state in which all the people are completely liberated from exploitation and oppression. \n\nThe workers, peasants, soldiers and intellectuals are the true masters of their destiny and are in a unique position to defend their interests.",
                                         id: "some id"))
                query = db.collection("posts")
                            .order(by: "timestamp", descending: true)
                            .limit(to: batchSize)
            } else {
                query = query.start(afterDocument: lastDoc)
            }
            
            query.getDocuments() { (querySnapshot, err) in
                if let err = err { seal.reject(err) }
                for document in querySnapshot!.documents {
                    if let ent = getEntry(from: document) {
                        entriesList.append(ent)
                    }
                }
                lastDoc = querySnapshot?.documents.last
                print("[EntriesManager]: Retrieved Posts")
                entriesList.forEach { (e) in print(e) }
                seal.fulfill(entriesList)
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
                for imgRef in list.items {
                    let key = String(describing: imgRef) as NSString
                    
                    if let img = imageCache.object(forKey: key) {
                        print("reading from cache for \(imgRef)")
                        assets.append(img)
                        if (assets.count == list.items.count) { seal.fulfill(assets) }
                        continue
                    }
                    

                    print("downloading \(imgRef)")
                    imgRef.getData(maxSize: 700 * 1024 * 1024) { (dat, err) in
                        if let err = err { seal.reject(err) }
                        
                        print("caching \(imgRef)")
                        let img = UIImage(data: dat!)!
                        
                        imageCache.setObject(img, forKey: key)
                        assets.append(img)
                        
                        if (assets.count == list.items.count) { seal.fulfill(assets) }
                    }
                }
            })
        }
    }

}
