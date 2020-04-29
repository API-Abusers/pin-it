//
//  AppDelegate.swift
//  Pin It
//
//  Created by Joseph Jin on 1/8/20.
//  Copyright © 2020 AnimatorJoe. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var authVC: UIViewController!
    var mapVC: UIViewController!
    var storyboard = UIStoryboard(name: "Main", bundle: nil)
    var window: UIWindow?
    
    // Restrict Orientations
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .landscape
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.statusBarStyle = .darkContent
        
        // load in conf based on info plist
        guard let fbconf = AppConfigs.getConfig(forKey: "fbConf") as? String else {
            assert(false, "Couldn't load config file")
        }
        let filePath = Bundle.main.path(forResource: fbconf, ofType: "plist")
        guard let fileopts = FirebaseOptions(contentsOfFile: filePath!) else {
            assert(false, "Couldn't load config file")
        }
        print("[AppDelegate]: Loading firebase config from \(fbconf)")
        FirebaseApp.configure(options: fileopts)
    
        // Use Firebase library to configure APIs
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        // The default cache size threshold is 100 MB. Configure "cacheSizeBytes"
        let settings = Firestore.firestore().settings
        settings.cacheSizeBytes = 5 * 1024 * 1024
        Firestore.firestore().settings = settings
        
        // selecting inital view controller
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        authVC = storyboard.instantiateViewController(withIdentifier: "AuthView")
        mapVC = storyboard.instantiateViewController(withIdentifier: "MapView")
        
        guard let _ = Auth.auth().currentUser else {
            presentViewController(vc: authVC)
            return true
        }
        
        presentViewController(vc: mapVC)
        return true
    }
    
    // MARK: Set Main View Controller
    func presentViewController(vc : UIViewController) {
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
    }
    
    // MARK: Sign Out Current User
    func signOutCurrentUser() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        presentViewController(vc: authVC)
    }
    
    // MARK: URL Stuff
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
      -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "Pin_It")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}


// Implementing GIDSignInDelegate functions
extension AppDelegate: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {

        if let error = error {
            print(error)
            return
        }

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                     accessToken: authentication.accessToken)

        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error)
                return
            }
            // User is signed in
            let user = authResult?.user
            print("signed in \(user!.uid)")
            print("\(String(describing: user!.email))")
            (self.mapVC as! MapViewController).prepareDeinit()
            self.mapVC = self.storyboard.instantiateViewController(withIdentifier: "MapView")
            self.presentViewController(vc: self.mapVC!)
        }

    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
        // Perform any operations when the user disconnects from app here.
        self.presentViewController(vc: self.authVC)
    }
    
}

