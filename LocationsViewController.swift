//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Donald Lee on 2015-05-10.
//  Copyright (c) 2015 mylocations. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext!
    var locations = [Location]()
    
    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier( "LocationCell") as! UITableViewCell
        
        let location = locations[indexPath.row]
        
        let descriptionLabel = cell.viewWithTag(100) as! UILabel
        descriptionLabel.text = location.locationDescription
            
        let addressLabel = cell.viewWithTag(101) as! UILabel
        if let placemark = location.placemark {
            addressLabel.text = "\(placemark.subThoroughfare) \(placemark.thoroughfare)," +
            "\(placemark.locality)"
        } else {
            addressLabel.text = ""
        }
            
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 1 - The NSFetchRequest is the object that describes which objects you’re going to fetch from the data store. To retrieve an object that you previously saved to the data store, you create a fetch request that describes the search parameters of the object – or multiple objects – that you’re looking for.
        let fetchRequest = NSFetchRequest()
        // 2 - The NSEntityDescription tells the fetch request you’re looking for Location entities.
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity
        // 3 - The NSSortDescriptor tells the fetch request to sort on the date attribute, in ascending order. In order words, the Location objects that the user added first will be at the top of the list. You can sort on any attribute here (later in this tutorial you’ll sort on the Location’s category as well).
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        // 4 - Execute fetch request, executeFetchRequest() returns an array with sorted objects, or nil in case of error
        var error: NSError?
        let foundObjects = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
        if foundObjects == nil {
            fatalCoreDataError(error)
            return
        }
        // 5
        locations = foundObjects as! [Location]
    }
}
