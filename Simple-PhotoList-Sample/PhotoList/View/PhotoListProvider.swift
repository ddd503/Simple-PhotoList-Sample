//
//  PhotoListProvider.swift
//  Simple-PhotoList-Sample
//
//  Created by kawaharadai on 2018/06/30.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

class PhotoListProvider: NSObject {
    var photoList = [PhotoData]()
    
    func setPhotoList(photoList: [PhotoData]) {
        self.photoList = photoList
    }
}

extension PhotoListProvider: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoListViewCell.identifier, for: indexPath) as? PhotoListViewCell else {
            fatalError("cell is nil")
        }
        
        cell.photoData = photoList[indexPath.row]
        
        return cell
    }
}
