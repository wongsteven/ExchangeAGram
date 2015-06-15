//
//  FilterCell.swift
//  ExchangeAGram
//
//  Created by steven wong on 6/14/15.
//  Copyright (c) 2015 steven.w. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    //  Add custom initializer so that collectionView cell setup our image view
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        contentView.addSubview(imageView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
