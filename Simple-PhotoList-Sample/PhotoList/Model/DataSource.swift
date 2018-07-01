//
//  DataSource.swift
//  Simple-PhotoList-Sample
//
//  Created by kawaharadai on 2018/06/30.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

final class DataSource {
    
    static func create() -> [PhotoData] {
        
        var result = [PhotoData]()
        
        guard
            let filePath =  Bundle.main.path(forResource: "PhotoLibrary", ofType: "plist"),
            let contentsOfFile = NSDictionary(contentsOfFile: filePath),
            let photoList = contentsOfFile.object(forKey: "Photos") as? NSArray
            else {
                return result
        }
        
        // dicを配列に入れた上でArrayメソッドのforEachで処理
        photoList.forEach {
            
            guard let dic = $0 as? NSDictionary else {
                return
            }
            
            if let imageName = dic["name"] as? String,
                let image = UIImage(named: imageName),
                let title = dic["title"] as? String,
                let days = dic["days"] as? String {
                
                let photoData = PhotoData(image: image, title: title, days: days)
                result.append(photoData)
            }
        }
        return result
    }
}
