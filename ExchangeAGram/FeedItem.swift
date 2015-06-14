//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by steven wong on 6/14/15.
//  Copyright (c) 2015 steven.w. All rights reserved.
//

//  Creating this file helps the user save to coredata
import Foundation
import CoreData

//  Code that interacts with objective-c
@objc (FeedItem)
class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData

}
