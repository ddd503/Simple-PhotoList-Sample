//
//  PhotoData.swift
//  Simple-PhotoList-Sample
//
//  Created by kawaharadai on 2018/06/30.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

struct PhotoData {
    var image: UIImage
    var title: String
    var days: String
    
    init(image: UIImage, title: String, days: String) {
        self.image = image
        self.title = title
        self.days = days
    }
}
