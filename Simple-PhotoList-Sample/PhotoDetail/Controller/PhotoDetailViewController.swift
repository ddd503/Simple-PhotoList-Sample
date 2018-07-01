//
//  PhotoDetailViewController.swift
//  Simple-PhotoList-Sample
//
//  Created by kawaharadai on 2018/06/30.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController, TransitionType {

    @IBOutlet weak var photoListView: UICollectionView!
    private let provider = PhotoDetailViewProvider()
    var photoList = [PhotoData]()
    var selectedPhotoIndex: IndexPath!
    
    static var identifer: String {
        return String(describing: self)
    }
    
    // MARK: - Factory
    class func make(photoList: [PhotoData], selectedPhotoIndex: IndexPath) -> PhotoDetailViewController {
        let storyboard = UIStoryboard(name: PhotoDetailViewController.identifer, bundle: nil)
        guard let photoDetailVC = storyboard.instantiateViewController(withIdentifier: PhotoDetailViewController.identifer) as? PhotoDetailViewController else {
            fatalError("VCのインスタンス化に失敗")
        }
        photoDetailVC.photoList = photoList
        photoDetailVC.selectedPhotoIndex = selectedPhotoIndex
        return photoDetailVC
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.photoListView.scrollToItem(at: self.selectedPhotoIndex, at: .centeredHorizontally, animated: false)
    }
    
    // MARK: - Private
    private func setup() {
        self.photoListView.delegate = self
        self.photoListView.dataSource = self.provider
        self.provider.photoList = self.photoList
        
        let layout = UICollectionViewFlowLayout()
        
        // セルのサイズ
        layout.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        // 横スクロールにする
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0

        self.photoListView.setCollectionViewLayout(layout, animated: false)
        
        // 水平方向のスクロールバーを非表示にする
        self.photoListView.showsHorizontalScrollIndicator = false
        self.photoListView.backgroundColor = UIColor.white
        
        DispatchQueue.main.async {
            self.photoListView.reloadData()
        }
    }
    
    func transformScale(cell: UICollectionViewCell) {
        // 計算してスケールを変更する
        // セルが画面の中心にいるときに最大値(1.0)をとり、中心からずれた分だけ縮小率に応じて縮小させる、ということをする
        let cellCenter: CGPoint = self.photoListView.convert(cell.center, to: nil) //セルの中心座標
        let screenCenterX: CGFloat = UIScreen.main.bounds.width / 2  //画面の中心座標x
        let reductionRatio: CGFloat = -0.0005                        //縮小率
        let maxScale: CGFloat = 1                                    //最大値
        let cellCenterDisX: CGFloat = abs(screenCenterX - cellCenter.x)   //中心までの距離
        let newScale = reductionRatio * cellCenterDisX + maxScale   //新しいスケール
        cell.transform = CGAffineTransform(scaleX:newScale, y:maxScale)
    }
}

extension PhotoDetailViewController: UICollectionViewDelegate {

}

extension PhotoDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /*
         visibleCellsで現在画面内で実際に目に見えているセルを取得することができます。これで、UICollectionViewCellの配列が取得できます。
         セルを１つずつ取り出してスケールの変更をする、という実装です。
         */
        // 画面内に表示されているセルを取得
        let cells = self.photoListView.visibleCells
        for cell in cells {
            // ここでセルのScaleを変更する
            transformScale(cell: cell)
        }
    }
}
