//  FeedViewController.swift
//  ExchangeAGram
//
//  Created by steven wong on 6/13/15.
//  Copyright (c) 2015 steven.w. All rights reserved.
//

import UIKit

//  Importing MobileCoreServices gives access to UIImagePickerController
import MobileCoreServices

//  This will allow us to create FeedItems as well as access the NSObjects context from the appdelegate
import CoreData

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    //  Add additional property to interact with CoreData
    var feedArray:[AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = NSFetchRequest(entityName: "FeedItem")
        
        //  This will give us access to the AppDelegate instance and with that we can get access to our NSManagedContext
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDelegate.managedObjectContext!
        
        //  Executes fetch request
        feedArray = context.executeFetchRequest(request, error: nil)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //  Camera button on storyboard
    @IBAction func snapBarButtonItemTapped(sender: UIBarButtonItem) {
        
        //  Test to see if camera is working
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            var cameraController = UIImagePickerController()
            cameraController.delegate = self
            
            //  Set the source type to camera so that we can use it
            cameraController.sourceType = UIImagePickerControllerSourceType.Camera
            
            //  Set media type to Images
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            cameraController.mediaTypes = mediaTypes
            cameraController.allowsEditing = false
            
            //  Present camera controller on the screen
            self.presentViewController(cameraController, animated: true, completion: nil)
        }
        //  Photo Library is available and we want to use this instead of camera
        else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            var photoLibraryController = UIImagePickerController()
            photoLibraryController.delegate = self
            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            photoLibraryController.mediaTypes = mediaTypes
            photoLibraryController.allowsEditing = false
            self.presentViewController(photoLibraryController, animated: true, completion: nil)
        } else {
            var alertController = UIAlertController(title: "Alert", message: "Your device does not support the camera or photo library", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    //  UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        //  This code gets back the original image as a UIImage
        let image = info[UIImagePickerControllerOriginalImage] as UIImage
        
        //  Converts image into a data representation of our image which we can use this as our Binary data that we set up as our FeedItem
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        
        //  Implement thumbnail data
        let thumbNaildata = UIImageJPEGRepresentation(image, 0.1)
        
        //  Process to create FeedItem. Create managedObjectContext and entityDescription
        let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext!)
        
        let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
        
        feedItem.image = imageData
        feedItem.caption = "test caption"
        feedItem.thumbNail = thumbNaildata
        
        //  Save all the changes that are made to the entity
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        
        feedArray.append(feedItem)
        
        //  Dismiss the view controller after we display the image so that we can see the feed view controller again
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //  Collection view to reload itself so that it will appear 
        self.collectionView.reloadData()
    }
    
    //  UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:FeedCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as FeedCell
        let thisItem = feedArray[indexPath.row] as FeedItem
        
        cell.imageView.image = UIImage(data: thisItem.image)
        cell.captionLabel.text = thisItem.caption
        
        return cell
    }
    
    /*  UICollectionViewDelegate
        This functionality transitions/segues to the FilterViewController */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let thisItem = feedArray[indexPath.row] as FeedItem
        
        //  Segues to the FilterViewController since there isn't one in the storyboard.
        var filterVC = FilterViewController()
        filterVC.thisFeedItem = thisItem
        
        self.navigationController?.pushViewController(filterVC, animated: false)
    }
}
