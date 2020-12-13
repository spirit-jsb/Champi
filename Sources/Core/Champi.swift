//
//  Champi.swift
//  Champi
//
//  Created by max on 2020/10/23.
//

#if canImport(Foundation) && canImport(UIKit)

import Foundation
import UIKit

public enum VMBannerViewTransformerType: Int {
  case crossFading
  case zoomOut
  case depth
  case overlap
  case linear
  case coverFlow
  case ferrisWheel
  case invertedFerrisWheel
  case cubic
}

@objc public protocol VMBannerViewItemProtocol where Self: UICollectionViewCell {
  
}

@objc public protocol VMBannerViewDataSource: NSObjectProtocol {
  func numberOfItems(in bannerView: VMBannerView) -> Int
  func bannerView(_ bannerView: VMBannerView, cellForItemAt index: Int) -> VMBannerViewItemProtocol
}

@objc public protocol VMBannerViewDelegate: NSObjectProtocol {
  @objc optional func bannerView(_ bannerView: VMBannerView, shouldHighlightItemAt index: Int) -> Bool
  @objc optional func bannerView(_ bannerView: VMBannerView, didHighlightItemAt index: Int)
  
  @objc optional func bannerView(_ bannerView: VMBannerView, shouldSelectItemAt index: Int) -> Bool
  @objc optional func bannerView(_ bannerView: VMBannerView, didSelectItemAt index: Int)
  
  @objc optional func bannerView(_ bannerView: VMBannerView, willDisplay cell: VMBannerViewItemProtocol, forItemAt index: Int)
  @objc optional func bannerView(_ bannerView: VMBannerView, didEndDisplaying cell: VMBannerViewItemProtocol, forItemAt index: Int)
  
  @objc optional func bannerViewDidScroll(_ bannerView: VMBannerView)
  @objc optional func bannerViewWillBeginDragging(_ bannerView: VMBannerView)
  @objc optional func bannerViewWillEndDragging(_ bannerView: VMBannerView, targetIndex: Int)
  @objc optional func bannerViewDidEndDecelerating(_ bannerView: VMBannerView)
  @objc optional func bannerViewDidEndScrollingAnimation(_ bannerView: VMBannerView)
}

#endif
