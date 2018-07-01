//
//  PhotoDetailViewProvider.swift
//  Simple-PhotoList-Sample
//
//  Created by kawaharadai on 2018/06/30.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

class PhotoDetailViewProvider: NSObject {
    var photoList = [PhotoData]()
    
    func setPhotoList(photoList: [PhotoData]) {
        self.photoList = photoList
    }
}

extension PhotoDetailViewProvider: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoDetailViewCell.identifier, for: indexPath) as? PhotoDetailViewCell else {
            fatalError("cell is nil")
        }
        
        cell.photoData = self.photoList[indexPath.row]
        
        return cell
    }
}
