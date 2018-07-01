//
//  PhotoListViewCell.swift
//  Simple-PhotoList-Sample
//
//  Created by kawaharadai on 2018/06/30.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

class PhotoListViewCell: UICollectionViewCell {
    
    // MARK: - Propaties
    @IBOutlet weak var photoView: UIImageView!
    
    static var identifier: String {
        return String(describing: self)
    }
    
    var photoData: PhotoData? {
        didSet {
            self.photoView.image = photoData?.image
        }
    }
}
