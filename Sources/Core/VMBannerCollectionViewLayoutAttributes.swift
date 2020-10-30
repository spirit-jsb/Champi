//
//  VMBannerCollectionViewLayoutAttributes.swift
//  Champi
//
//  Created by max on 2020/10/24.
//

import UIKit

public class VMBannerCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
  
  public var position: CGFloat = 0.0

  public override func isEqual(_ object: Any?) -> Bool {
    guard let object = object as? VMBannerCollectionViewLayoutAttributes else {
      return false
    }
    
    var isEqual = super.isEqual(object)
    isEqual = isEqual && self.position == object.position
    return isEqual
  }
  
  public override func copy(with zone: NSZone? = nil) -> Any {
    guard let copy = super.copy(with: zone) as? VMBannerCollectionViewLayoutAttributes else {
      fatalError("")
    }
    
    copy.position = self.position
    return copy
  }
}
