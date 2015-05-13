//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Donald Lee on 2015-05-09.
//  Copyright (c) 2015 mylocations. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

private let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    println("dateFormat")
    return formatter
}()

class LocationDetailsViewController: UITableViewController {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var descriptionText = ""
    var categoryName = "No Category"
    
    var managedObjectContext: NSManagedObjectContext!
    var date = NSDate()
    
    var image :UIImage?
    var observer :AnyObject!

    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    
    @IBAction func done() {
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        
        var location: Location
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
            location.locationDescription = descriptionText
            location.category = categoryName
            location.latitude = coordinate.latitude
            location.longitude = coordinate.longitude
            location.date = date
            location.placemark = placemark
            if let image = image {
                // 1
                if !location.hasPhoto {
                    location.photoID = Location.nextPhotoID()
                }
                // 2
                let data = UIImageJPEGRepresentation(image, 0.5)
                // 3
                var error: NSError?
                if !data.writeToFile(location.photoPath, options: .DataWritingAtomic,error: &error) {
                    println("Error writing file: \(error)")
                }
            }
        } else {
            hudView.text = "Tagged"
        
            // 1 --ask the NSEntityDescription class to insert a new object for your entity into the managed object context. It’s a bit of a weird way to make new objects but that’s how you do it in Core Data. The string "Location" is the name of the entity that you added in the data model earlier.
            let location = NSEntityDescription.insertNewObjectForEntityForName( "Location", inManagedObjectContext: managedObjectContext) as! Location
            
            location.photoID = nil
            location.locationDescription = descriptionText
            location.category = categoryName
            location.latitude = coordinate.latitude
            location.longitude = coordinate.longitude
            location.date = date
            location.placemark = placemark
            if let image = image {
                // 1
                if !location.hasPhoto {
                    location.photoID = Location.nextPhotoID()
                }
                // 2
                let data = UIImageJPEGRepresentation(image, 0.5)
                // 3
                var error: NSError?
                if !data.writeToFile(location.photoPath, options: .DataWritingAtomic,error: &error) {
                    println("Error writing file: \(error)")
                }
            }
        }
        

        // 3 - Save the context
        var error: NSError?
        if !managedObjectContext.save(&error) {
            fatalCoreDataError(error)
            return
        }
        
        afterDelay(0.6, {self.dismissViewControllerAnimated(true, completion: nil)})
    }
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
        let controller = segue.sourceViewController as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        if let location = locationToEdit {
            title = "Edit Location"
            if  location.hasPhoto{
                if let image = location.photoImage{
                    showImage(image)
                }
            }
        }
        
        if let location = locationToEdit{
            title = "Edit Location"
        }
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        categoryLabel.text = ""
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        dateLabel.text = formatDate(date)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gestureRecognizer.cancelsTouchesInView = false
        
        tableView.addGestureRecognizer(gestureRecognizer)
        listenForBackgroundNotification()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        descriptionTextView.frame.size.width = view.frame.size.width - 30
    }
    
    func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch(indexPath.section, indexPath.row){
            case (0, 0):
                return 88
        
            case(1, _):
                return imageView.hidden ? 44: 280
            
            case(2,2):
                addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
                addressLabel.sizeToFit()
                addressLabel.frame.origin.x = view.bounds.size.width -
                addressLabel.frame.size.width - 15
                return addressLabel.frame.size.height + 20
        
            default:
                return 44
        }
            
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            pickPhoto()
        }
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        return "\(placemark.subThoroughfare) \(placemark.thoroughfare), " +
        "\(placemark.locality), " +
        "\(placemark.administrativeArea) \(placemark.postalCode)," +
        "\(placemark.country)"
    }
    
    func formatDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    func showImage(image: UIImage) {
        imageView.image = image
        imageView.hidden = false
        imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
        addPhotoLabel.hidden = true
    }
    
    func listenForBackgroundNotification() {
        observer = NSNotificationCenter.defaultCenter().addObserverForName(
            UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
               [weak self] notification in // weak self indicates that closure will not keep view controller alive
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil {
                strongSelf.dismissViewControllerAnimated(false, completion: nil) }
                strongSelf.descriptionTextView.resignFirstResponder()
            }
        }
    }
    
    deinit {
        println("*** deinit \(self)")
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
}

extension LocationDetailsViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange
                  range: NSRange, replacementText text: String) -> Bool {
        descriptionText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        descriptionText = textView.text
    }
}

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhoto(){
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil,preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo",style: .Default, handler: {_ in self.takePhotoWithCamera()})
        alertController.addAction(takePhotoAction)
        
            let chooseFromLibraryAction = UIAlertAction(title:"Choose From Library", style: .Default, handler: {_ in self.choosePhotoFromLibrary()})
        alertController.addAction(chooseFromLibraryAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
            image = info[UIImagePickerControllerEditedImage] as! UIImage?
            if let image = image {
                showImage(image)
            }
            tableView.reloadData()
            dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
            dismissViewControllerAnimated(true, completion: nil)
    }
}
