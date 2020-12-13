//
//  VMBannerCollectionViewLayout.swift
//  Champi
//
//  Created by max on 2020/10/24.
//

#if canImport(UIKit)

import UIKit

class VMBannerCollectionViewLayout: UICollectionViewLayout {
  
  var contentSize = CGSize.zero
  
  var leadingSpacing = CGFloat.zero
  var itemSpacing = CGFloat.zero
  
  var needsReprepare = true
  
  var scrollDirection = VMBannerView.ScrollDirection.horizontal
  
  private var collectionViewSize = CGSize.zero
  
  private var numberOfSections = 1
  private var numberOfItems = 0
  
  private var actualInterItemSpacing = CGFloat.zero
  private var actualItemSize = CGSize.zero
  
  private var bannerView: VMBannerView? {
    return self.collectionView?.superview?.superview as? VMBannerView
  }
  
  override init() {
    super.init()
    self.addObserver()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    self.removeObserver()
  }
  
  override class var layoutAttributesClass: AnyClass {
    return VMBannerCollectionViewLayoutAttributes.self
  }
  
  override var collectionViewContentSize: CGSize {
    return self.contentSize
  }
  
  override func prepare() {
    
  }
  
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return true
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return nil
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    let attributes = VMBannerCollectionViewLayoutAttributes(forCellWith: indexPath)
    attributes.indexPath = indexPath
    
    let frame = self.frame(for: indexPath)
    let center = CGPoint(x: frame.midX, y: frame.midY)
    
    attributes.center = center
    attributes.size = self.actualItemSize
    
    return attributes
  }
  
  internal func forceInvalidate() {
    self.needsReprepare = true
    self.invalidateLayout()
  }
  
  internal func contentOffset(for indexPath: IndexPath) -> CGPoint {
    return .zero
  }
  
  internal func frame(for indexPath: IndexPath) -> CGRect {
    return .zero
  }
  
  private func addObserver() {
    NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
  }
  
  private func removeObserver() {
    NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
  }
  
  @objc private func orientationDidChange(_ notification: Notification) {
    
  }
}

#endif
