//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Donald Lee on 2015-05-09.
//  Copyright (c) 2015 mylocations. All rights reserved.
//

import UIKit
import CoreLocation

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
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var descriptionText = ""
    
    @IBAction func done() {
        println("Description '\(descriptionText)'")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.text = descriptionText
        categoryLabel.text = ""
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        dateLabel.text = formatDate(NSDate())
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 88
        } else if indexPath.section == 2 && indexPath.row == 2 {
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width -
            addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20
        } else {
            return 44
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