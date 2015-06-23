//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by steven wong on 6/14/15.
//  Copyright (c) 2015 steven.w. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var thisFeedItem: FeedItem!
    var collectionView: UICollectionView!
    let kIntensity = 0.7
    var context:CIContext = CIContext(options: nil)
    var filters:[CIFilter] = []
    let placeHolderImage = UIImage(named: "Placeholder")
    
    //  NSTemporaryDirectory will automatically clear out the items by itself
    let tmp = NSTemporaryDirectory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  UICollectionView in code instead of storyboard
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.whiteColor()
        
        //  Register filtercell class with the collection view
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "MyCell")
        
        self.view.addSubview(collectionView)
        
        //  Use helper function to get back array of filter instances.
        filters = photoFilters()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //  UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell:FilterCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as FilterCell
        
        //  Optimization: Only show image view's image first time we load the view controller
        
        cell.imageView.image = placeHolderImage
        
        let filterQueue:dispatch_queue_t = dispatch_queue_create("filter queue", nil)
        
        //  Tell queue what code to run
        dispatch_async(filterQueue, { () -> Void in
            
            let filterImage = self.getCachedImage(indexPath.row)
            
            //  Get back to main thread after we get filtered image
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView.image = filterImage
            })
        })

        return cell
    }
    
    //  UICollectionViewDelegate
    //  Using image instead of thumbnail because we want to filter the main image
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        self.createUIAlertController(indexPath)

    }
    
    //  Helper function
    func photoFilters() -> [CIFilter]{
        
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]
    }

    func filteredImageFromImage (imageData: NSData, filter: CIFilter) -> UIImage {
        
        let unfilteredImage = CIImage(data: imageData)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        let filteredImage:CIImage = filter.outputImage
        
        let extent = filteredImage.extent()
        let cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        
        let finalImage = UIImage(CGImage: cgImage)
        
        return finalImage!
    }
    
    //  UIALertController Helper Functions
    
    func createUIAlertController(indexPath: NSIndexPath){
        let alert = UIAlertController(title: "Photo Options:", message: "Please choose an option.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Add Caption"
            textField.secureTextEntry = false
            
        let textField = alert.textFields![0] as UITextField
            
        let photoAction = UIAlertAction(title: "Post photo on Facebook with caption", style: UIAlertActionStyle.Destructive, handler: { (UIAlertAction) -> Void in

            var text = textField.text

            self.saveFilterToCoreData(indexPath, caption: text)
            self.shareToFacebook(indexPath)
        })
            
        alert.addAction(photoAction)
            
        let saveFilterAction = UIAlertAction(title: "Save filter without posting on Facebook", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in

            var text = textField.text

            self.saveFilterToCoreData(indexPath, caption: text)
        })
        
        alert.addAction(saveFilterAction)
            
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
            
        })
            
        alert.addAction(cancelAction)
            
        //  Display on screen
        self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //  Helper fucnction
    func saveFilterToCoreData(indexPath:NSIndexPath,caption:String){
        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image, filter: self.filters[indexPath.row])
        let imageData = UIImageJPEGRepresentation(filterImage, 1.0)
        //  Update thisFeedItem with new item
        self.thisFeedItem.image = imageData

        //  Update thumbnail
        let thumbNailData = UIImageJPEGRepresentation(filterImage, 0.1)
        self.thisFeedItem.thumbNail = thumbNailData
        
        self.thisFeedItem.caption = caption

        //  Save to file system
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //  Share image on facebook
    func shareToFacebook(indexPath:NSIndexPath){
        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image, filter: self.filters[indexPath.row])
        
        //  FB Parameter that we will be using is expecting an NSArray
        let photos:NSArray = [filterImage]
        let params = FBPhotoParams()
        params.photos = photos
        
        //
        FBDialogs.presentMessageDialogWithPhotoParams(params, clientState: nil) { (call, result, error) -> Void in
            if (result? != nil){
                println(result)
            } else {
                println(error)
            }
        }
        
    }
    
    //  Caching functions
    func cacheImage(imageNumber: Int){
        //  Create a filename
        let fileName = "\(imageNumber)"
        //  Create a unique path for the directory. Each image in collectionview has a unique number.
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        
        //  Checking to see if file exists at file path. If it doesn't exist, we want to generate a filter.
        if !NSFileManager.defaultManager().fileExistsAtPath(fileName){
            
            //  Generate image with fitler
            let data = self.thisFeedItem.thumbNail
            let filter = self.filters[imageNumber]
            let image = filteredImageFromImage(data, filter: filter)
            
            //  Save this to data
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true)
        }
    }
    
    //  Ability to receive cache function
    func getCachedImage(imageNumber:Int) -> UIImage {
        let fileName = "\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        
        var image:UIImage
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath){
            image = UIImage(contentsOfFile: uniquePath)!
        } else {
            self.cacheImage(imageNumber)
            image = UIImage(contentsOfFile: uniquePath)!
        }
        return image
    }
}
