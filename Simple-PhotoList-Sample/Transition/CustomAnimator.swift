//
//  CustomAnimator.swift
//  Simple-PhotoList-Sample
//
//  Created by kawaharadai on 2018/06/30.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

final class CustomAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var duration: TimeInterval
    var isPresenting: Bool
    var originFrame: CGRect
    var image: UIImage
    
    init(duration : TimeInterval, isPresenting : Bool, originFrame : CGRect, image : UIImage) {
        self.duration = duration
        self.isPresenting = isPresenting
        self.originFrame = originFrame
        self.image = image
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    /*
     pushの場合
     遷移先のviewをalphaが0の状態で上に乗せて、遷移元の大きさにアニメーションさせる
     popの場合
     遷移先のviewを遷移元のviewの下に置いて,遷移元のviewを薄くしながら、遷移先のviewの大きさに寄せていく、完了と同時に消える（photoViewは薄くならない？）
     */
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        /// 遷移情報をインスタンス化
        let container = transitionContext.containerView
        
        /// 遷移元と遷移後の情報からそれぞれ元のViewを取り出す
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else { return }
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }
        
        self.isPresenting ? container.addSubview(toView) : container.insertSubview(toView, belowSubview: fromView)
        
        let detailView = isPresenting ? toView : fromView
        detailView.alpha = 0
        
        // 遷移先のphotoViewをインスタンス化
        guard
            let destinationVC = isPresenting ? transitionContext.viewController(forKey: .to) as? TransitionType : transitionContext.viewController(forKey: .from) as? TransitionType,
            let photoListView = destinationVC.photoListView else {
                return
        }
        
        // 写真詳細画面のimageViewのy座標を擬似的に取得
        let adjustPhotoViewPositionY = ((detailView.frame.size.height - detailView.frame.size.height * AppContext.photoDetailHeightRatio) + AppContext.navigationBarHeight) / 2
        // 写真詳細画面のimageViewのframeを擬似的に取得
        let adjustPhotoViewFrame = CGRect(x: 0,
                                          y: adjustPhotoViewPositionY,
                                          width: detailView.frame.size.width,
                                          height: detailView.frame.size.height * AppContext.photoDetailHeightRatio)
        
        // 遷移先のVCのViewを操作（遷移中に行き先の画像が見えないようにする、storyboardでもいい）
        photoListView.alpha = 0
        
        let transitionPhotoView = UIImageView(frame: isPresenting ? originFrame : adjustPhotoViewFrame)
        transitionPhotoView.image = image
        container.addSubview(transitionPhotoView)
        
        toView.frame = isPresenting ? CGRect(x: fromView.frame.width,
                                             y: 0,
                                             width: toView.frame.width,
                                             height: toView.frame.height) : toView.frame
        
        toView.alpha = isPresenting ? 0 : 1
        
        // viewの再配置(viewの配置を確定させておく)
        toView.layoutIfNeeded()
        
        // 遷移中に次の画面のviewを見せる時はここもアニメーションさせる
        detailView.frame = self.isPresenting ? fromView.frame : CGRect(x: toView.frame.width,
                                                                       y: 0,
                                                                       width: toView.frame.width,
                                                                       height: toView.frame.height)
        
        UIView.animate(withDuration: duration, animations: {
            transitionPhotoView.frame = self.isPresenting ? adjustPhotoViewFrame : self.originFrame
            detailView.alpha = self.isPresenting ? 1 : 0
        }, completion: { (finished) in
            // 遷移が終わったタイミングと遷移カスタムを使用するタイミングを合わせる
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            transitionPhotoView.removeFromSuperview()
            photoListView.alpha = 1
        })
    }
}
