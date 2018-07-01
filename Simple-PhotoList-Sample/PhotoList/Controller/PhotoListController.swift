//
//  PhotoListController.swift
//  Simple-PhotoList-Sample
//
//  Created by kawaharadai on 2018/06/30.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

// リストビューの選択状態
enum PhotoListStatus {
    case selectMode
    case normalMode
}

final class AppContext {
    // ナビゲーションバーの高さ
    static let navigationBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height + 44
    // ここを変更する場合は、storyboardでPhotoDetailViewCell内のimageViewの比率を変更する必要がある
    static let photoDetailHeightRatio: CGFloat = 0.7
}

class PhotoListController: UIViewController, TransitionType {
    
    @IBOutlet weak var photoListView: UICollectionView!
    private let provider = PhotoListProvider()
    private var selectedPhotoFrame: CGRect?
    private var selectedPhoto: UIImage?
    private var customInteractor : CustomInteractor?
    private var photoListStatus: PhotoListStatus = .normalMode
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    deinit {
        self.photoListView.delegate = nil
    }
    
    // MARK: - Setup
    private func setup() {
        self.navigationController?.delegate = self
        self.photoListView.delegate = self
        self.photoListView.dataSource = provider
        provider.setPhotoList(photoList: DataSource.create())
        
        DispatchQueue.main.async {
            self.photoListView.reloadData()
        }
    }
    
    /// 右上の選択ボタンの状態を変更する
    private func selectButtonStatus(button: UIBarButtonItem) {
        switch photoListStatus {
        case .normalMode:
            self.photoListStatus = .selectMode
            DispatchQueue.main.async {
                self.navigationItem.title = "項目を選択"
                button.title = "キャンセル"
                button.style = .done
                self.navigationController?.setToolbarHidden(false, animated: true)
            }
        case .selectMode:
            self.photoListStatus = .normalMode
            DispatchQueue.main.async {
                self.navigationItem.title = "カメラロール"
                button.title = "選択"
                button.style = .plain
                self.navigationController?.setToolbarHidden(true, animated: true)
                // TODO: セルの選択状態も戻す
            }
        }
    }
    
    // MARK: - Action
    @IBAction func selectButton(_ sender: UIBarButtonItem) {
        // 選択ボタンの状態に合わせてレイアウトを切り替える
        self.selectButtonStatus(button: sender)
    }
}

// MARK: - UICollectionViewDelegate
extension PhotoListController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 押した際のviewの状態によって分岐
        switch photoListStatus {
        case .normalMode:
            
            guard let cellLayout = collectionView.layoutAttributesForItem(at: indexPath) else {
                print("selected cell is nil")
                return
            }
            
            // 以下UIViewControllerAnimatedTransitioningで使用するためプロパティに持つ
            // cellのサイズをcgrectで取得
            self.selectedPhotoFrame = collectionView.convert(cellLayout.frame, to: collectionView.superview)
            // 遷移中のViewで写すimage（UIViewControllerTransitioningDelegateで使用）
            self.selectedPhoto = self.provider.photoList[indexPath.row].image
            
            self.navigationController?.pushViewController(PhotoDetailViewController.make(photoList: self.provider.photoList,
                                                                                         selectedPhotoIndex: indexPath), animated: true)
            
        case .selectMode:
            // TODO: 編集モード時のタップアクションを作成
            print("編集時のタップ")
            // 押されたセルを取得
//            guard let didSelectCell = collectionView.cellForItem(at: indexPath) as? PhotoListViewCell else {
//                return
//            }
            //            didSelectCell.whiteView.isHidden = false
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoListController: UICollectionViewDelegateFlowLayout {
    
    // アイテムの大きさを設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = self.view.frame.width / 4 - 1 // セル同士の横幅分の1
        
        return CGSize(width: size, height: size)
    }
    
    // コレクションビュー自体の周りのinset（セル同士のinsetはstoryboardで）
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let inset: CGFloat =  0
        
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
}

// MARK: - UINavigationControllerDelegate
extension PhotoListController: UINavigationControllerDelegate {
    
    // 遷移状態進行を管理
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let ci = customInteractor else {
            print("ci is nil")
            return nil }
        return ci.transitionInProgress ? customInteractor : nil
    }
    
    // 遷移をカスタムを適用する
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let frame = self.selectedPhotoFrame else { return nil }
        guard let photo = self.selectedPhoto else { return nil }
        
        switch operation {
        case .push:
            self.customInteractor = CustomInteractor(attachTo: toVC)
            return CustomAnimator(duration: TimeInterval(UINavigationControllerHideShowBarDuration),
                                  isPresenting: true,
                                  originFrame: frame,
                                  image: photo)
        case .pop:
            return CustomAnimator(duration: TimeInterval(UINavigationControllerHideShowBarDuration),
                                  isPresenting: false,
                                  originFrame: frame,
                                  image: photo)
        default:
            return nil
        }
    }
}
