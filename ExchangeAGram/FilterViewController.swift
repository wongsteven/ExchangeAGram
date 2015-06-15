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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //  UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell:FilterCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as FilterCell
        
        cell.imageView.image = UIImage(named: "Placeholder")
        
        return cell
    }
}
