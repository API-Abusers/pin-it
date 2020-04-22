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
    var query: Query?
    var lastDoc: QueryDocumentSnapshot?
    var batchSize = 5
    
    // MARK: Initializer
    init() {}
    
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
    
    // MARK: Handle Data Change
    func onDataChange(execute: @escaping (Entry, DocumentChangeType) -> Void) {
        struct Holder { static var timesCalled = 0 }
        EntriesManager.db.collection("posts").addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
                print("[EntriesManager.onDataChange] Error:\(err)")
                return
            }
            
            print("[EntriesManager.onDataChange]: Data changed")
            for docChange in querySnapshot!.documentChanges {
                print(docChange.type)
                print(docChange.document.data())
                guard let entry = EntriesManager.getEntry(from: docChange.document) else { continue }
                execute(entry, docChange.type)
            }
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
            let owner = doc["owner"] as? String ?? "none"
            return Entry(username: userName, location: [lat, long], title: title, desc: desc, id: id, owner: owner)
        }
        return nil
    }
    
    // MARK: Get Entries From Server
    func getEntriesFromServer() -> Promise<[Entry]?> {
        return Promise { seal in
            var entriesList = [Entry]()
            
            if let query = query {
                guard let lastDoc = lastDoc else {
                    seal.fulfill(nil)
                    return
                }
                self.query = query.start(afterDocument: lastDoc)
            } else {
                entriesList.append(Entry(username: "this is a really long user name to see if the ui breaks",
                                         location: [40.328562, 126.734141],
                                         title: "Engaging in Forced Labor, Stuck in North Korea",
                                         desc: "SOS, I need to get out of this North Korean camp. \n\nThe Democratic People's Republic of Korea is a genuine workers' state in which all the people are completely liberated from exploitation and oppression. \n\nThe workers, peasants, soldiers and intellectuals are the true masters of their destiny and are in a unique position to defend their interests.",
                                         id: "some id",
                                         owner: "none"))
                query = EntriesManager.db.collection("posts")
                            .order(by: "timestamp", descending: true)
                            .limit(to: batchSize)
            }
            
            guard let query = query else {
                seal.fulfill(nil)
                return
            }
            
            query.getDocuments() { (querySnapshot, err) in
                if let err = err { seal.reject(err) }
                for document in querySnapshot!.documents {
                    if let ent = EntriesManager.getEntry(from: document) {
                        entriesList.append(ent)
                    }
                }
                self.lastDoc = querySnapshot?.documents.last
                print("[EntriesManager.getEntriesFromServer]: Retrieved Posts")
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
                    print("[EntriesManager.postEntry]: post uploaded\n\(data)")
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
                guard let uid = Auth.auth().currentUser?.uid else { continue }
                let uploadRef = Storage.storage().reference(withPath: "/users/\(uid)/\(id)/img-\(i).jpg")
                
                var dat: Data?
                let f = files[i]
                if(f.size.height > f.size.width && f.size.height > 1024) {
                    if let resizedImage = f.resized(toHeight: 1024) {
                        dat = resizedImage.jpegData(compressionQuality: 0.75)
                    }
                } else if (f.size.width >= f.size.height && f.size.width > 1024) {
                    if let resizedImage = f.resized(toWidth: 1024) {
                        dat = resizedImage.jpegData(compressionQuality: 0.75)
                    }
                } else {
                    dat = f.jpegData(compressionQuality: 1)
                }
                
                guard let imageData = dat else { continue }
                
                print("[EntriesManager.attachImageFiles] Uploading image of size \(imageData.count)")
                let upload = StorageMetadata.init()
                upload.contentType = "image/jpeg"
                
                let ref = uploadRef.putData(imageData, metadata: upload) { (dat, err) in
                    if let err = err {
                        print("[EntriesManager.attachImageFiles] Error while uploading image:\n\(err)")
                        seal.reject(err)
                    }
                    print(dat ?? "")
                }
                
                let img = UIImage(data: imageData)!
                let key = String(describing: ref) as NSString
                imageCache.setObject(img, forKey: key)
                
                if (i == files.count - 1) {
                    ref.observe(.success) { _ in
                        print("[EntriesManager.attachImageFiles] Image upload successful for post \(id)")
                        seal.fulfill(Void())
                    }
                }
            }
        }
    }
    
    // MARK: Get Post Images
    static func getPostImages(ofEntry e: Entry) -> Promise<[UIImage]?> {
        return Promise { seal in
            var assets = [UIImage]()
            let ref = Storage.storage().reference(withPath: "/users/\(e.owner)/\(e.id)")
            ref.listAll(completion: {(list, err) in
                if let err = err { seal.reject(err) }
                print("[EntriesManager.getPostImages]: Attempting to download images")
                if list.items.isEmpty { seal.fulfill(nil) }
                
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
    
    // MARK: Edit Post
    static func editPostFields(ofPost e: Entry, writes: [String : Any]) -> Promise<Void>{
        return Promise { seal in
            let batch = db.batch()
            let ref = db.document("posts/\(e.id)")
            batch.updateData(writes, forDocument: ref)
            
            batch.commit() { err in
                if let err = err {
                    seal.reject(err)
                } else {
                    seal.fulfill(Void())
                }
            }
        }
    }
    
    // MARK: Delete Post
    static func deletePost(_ e: Entry) -> Promise<Void> {
        return Promise { seal in
            db.document("posts/\(e.id)").delete() { err in
                if let err = err {
                    seal.reject(err)
                }
                
                let imageRef = Storage.storage().reference(withPath: "/users/\(e.owner)/\(e.id)/")
                imageRef.listAll() { (res, err) in
                    if let err = err { seal.reject(err) }
                    res.items.forEach { (ref) in
                        ref.delete { err in
                            if let err = err { print(err) }
                        }
                    }
                }
                seal.fulfill(Void())
            }
        }
    }
    
    static func deletePost(ofId id: String) -> Promise<Void> {
        return Promise { seal in
            db.document("posts/\(id)").delete() { err in
                if let err = err {
                    seal.reject(err)
                }
                seal.fulfill(Void())
            }
        }
    }

}
