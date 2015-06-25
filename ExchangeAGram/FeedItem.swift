//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by steven wong on 6/23/15.
//  Copyright (c) 2015 steven.w. All rights reserved.
//

import Foundation
import CoreData

//  Code that interacts with objective-c
@objc(FeedItem)

class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData
    @NSManaged var thumbNail: NSData
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber

}
