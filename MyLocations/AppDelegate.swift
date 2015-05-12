//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Donald Lee on 2015-05-08.
//  Copyright (c) 2015 mylocations. All rights reserved.
//

import UIKit
import CoreData

let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"

func fatalCoreDataError(error: NSError?) {
    if let error = error {
        println("*** Fatal error: \(error), \(error.userInfo)")
    }
    NSNotificationCenter.defaultCenter().postNotificationName( MyManagedObjectContextSaveDidFailNotification, object: error)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let tabBarController = window!.rootViewController as! UITabBarController
        if let tabBarViewControllers = tabBarController.viewControllers {
            let currentLocationViewController = tabBarViewControllers[0] as! CurrentLocationViewController
            currentLocationViewController.managedObjectContext = managedObjectContext
        
            let navigationController = tabBarViewControllers[1] as! UINavigationController
            let locationsViewController = navigationController.viewControllers[0] as! LocationsViewController
            locationsViewController.managedObjectContext = managedObjectContext
            
            let mapViewController = tabBarViewControllers[2] as! MapViewController
            mapViewController.managedObjectContext = managedObjectContext
        }
        
        listenForFatalCoreDataNotifications()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // 1
        /*The Core Data model you created earlier is stored in your application bundle in a folder named “DataModel.momd”. Here you create an NSURL object pointing at this folder. Paths to files and folders are often represented by URLs in the iOS frameworks.*/
        if let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd") {
            // 2
            /*Create an NSManagedObjectModel from that URL. This object represents the data model during runtime. You can ask it what sort of entities it has, what attributes these entities have, and so on. In most apps you don’t need to use the NSManagedObjectModel object directly. (Note: this is another example of a failable initializer.)*/
            if let model = NSManagedObjectModel(contentsOfURL: modelURL) {
                // 3
                /* Create an NSPersistentStoreCoordinator object. This object is in charge of the SQLite database.*/
                let coordinator = NSPersistentStoreCoordinator( managedObjectModel: model)
                // 4
                /*The app’s data is stored in an SQLite database inside the app’s Documents folder. Here you create an NSURL object pointing at the DataStore.sqlite file.*/
                let urls = NSFileManager.defaultManager().URLsForDirectory( .DocumentDirectory, inDomains: .UserDomainMask)
                let documentsDirectory = urls[0] as! NSURL
                let storeURL = documentsDirectory.URLByAppendingPathComponent("DataStore.sqlite")
                // 5
                /*Add the SQLite database to the store coordinator.*/
                var error: NSError?
                if let store = coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) {
                    // 6
                    /*Finally, create the NSManagedObjectContext object and return it.*/
                    let context = NSManagedObjectContext()
                    context.persistentStoreCoordinator = coordinator
                    return context
                // 7
                /*If something went wrong, then print an error message and abort the app. In theory, errors should never happen here but you definitely want to have some println()’s in place to help with debugging.*/
                } else {
                    println("Error adding persistent store at \(storeURL): \(error!)")
                }
            } else {
                println("Error initializing model from: \(modelURL)")
            }
        } else {
            println("Could not find data model in app bundle")
        }
        abort()
    }()
    
    func listenForFatalCoreDataNotifications() {
        // 1
        /*
        Tell NSNotificationCenter that you want to be notified whenever a MyManagedObjectContextSaveDidFailNotification is posted. The actual code that is performed when that happens sits in a closure following usingBlock:.
        This closure has one parameter, notification, containing an NSNotification object. This object is not used anywhere inside the closure, so you could also have written: “_ in” to tell Swift you want to ignore the parameter. The _ is called the wildcard and you can use it whenever a name is expected but you don’t really care about it.
        */
        NSNotificationCenter.defaultCenter().addObserverForName(
        MyManagedObjectContextSaveDidFailNotification, object: nil,
        queue: NSOperationQueue.mainQueue(),
        usingBlock: { notification in
            // 2 - Create a UIAlertController to show the error message.
            let alert = UIAlertController(title: "Internal Error", message:
            "There was a fatal error in the app and it cannot continue.\n\n" + "Press OK to terminate the app. Sorry for the inconvenience.", preferredStyle: .Alert)
            // 3
            /*Add an action for the alert’s OK button. The code for handling the button press is again a closure (these things are everywhere!). Instead of calling abort(), the closure creates an NSException object. That’s a bit nicer and it provides more information to the crash log. Note that this closure also uses the _ wildcard to ignore its parameter.
            */
            let action = UIAlertAction(title: "OK", style: .Default) { _ in
                let exception = NSException(
                                    name: NSInternalInconsistencyException,
                                    reason: "Fatal Core Data error", userInfo: nil)
                exception.raise()
            }
            alert.addAction(action)
            
            // 4 - Present the alert
            self.viewControllerForShowingAlert().presentViewController(
            alert, animated: true, completion: nil)
        })
    }
    
    // 5 - To show the alert with presentViewController(animated, completion) you need a view controller that is currently visible, so this helper method finds one that is. Unfortunately you can’t simply use the window’s rootViewController – in this app that is the tab bar controller – because it will be hidden when the Location Details screen is open.
    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = self.window!.rootViewController!
        if let presentedViewController = rootViewController.presentedViewController {
            return presentedViewController
        } else {
            return rootViewController
        }
    }
}

