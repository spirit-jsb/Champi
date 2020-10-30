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

}

@objc public protocol VMBannerViewDelegate: NSObjectProtocol {
  
}

#endif
