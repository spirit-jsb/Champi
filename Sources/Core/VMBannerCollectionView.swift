//
//  VMBannerCollectionView.swift
//  Champi
//
//  Created by max on 2020/10/24.
//

import UIKit

class VMBannerCollectionView: UICollectionView {

  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)
    self.initialize()
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override var scrollsToTop: Bool {
    set {
      super.scrollsToTop = false
    }
    get {
      return false
    }
  }
  
  override var contentInset: UIEdgeInsets {
    set {
      super.contentInset = .zero
      if newValue.top > 0.0 {
        let contentOffset = CGPoint(x: self.contentOffset.x, y: self.contentOffset.y + newValue.top)
        self.contentOffset = contentOffset
      }
    }
    get {
      return super.contentInset
    }
  }
  
  private func initialize() {
    self.contentInset = .zero
    if #available(iOS 11.0, *) {
      self.contentInsetAdjustmentBehavior = .never
    }
    self.showsHorizontalScrollIndicator = false
    self.showsVerticalScrollIndicator = false
    self.isPagingEnabled = false
    self.decelerationRate = .fast
    self.scrollsToTop = false
    
    if #available(iOS 10.0, *) {
      self.isPrefetchingEnabled = false
    }
  }
}
