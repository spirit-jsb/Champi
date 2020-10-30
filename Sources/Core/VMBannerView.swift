//
//  VMBannerView.swift
//  Champi
//
//  Created by max on 2020/10/23.
//

import UIKit

public class VMBannerView: UIView {
    
  public var bounces: Bool {
    set {
      self.collectionView.bounces = newValue
    }
    get {
      return self.collectionView.bounces
    }
  }
  
  public var alwaysBounceVertical: Bool {
    set {
      self.collectionView.alwaysBounceVertical = newValue
    }
    get {
      return self.collectionView.alwaysBounceVertical
    }
  }
  
  public var alwaysBounceHorizontal: Bool {
    set {
      self.collectionView.alwaysBounceHorizontal = newValue
    }
    get {
      return self.collectionView.alwaysBounceHorizontal
    }
  }
  
  public var isScrollEnabled: Bool {
    set {
      self.collectionView.isScrollEnabled = newValue
    }
    get {
      return self.collectionView.isScrollEnabled
    }
  }
  
  public var scrollDirection: VMBannerView.ScrollDirection = .horizontal
  
  public var automaticSlidingInterval: TimeInterval = .zero {
    didSet {
      self.cancelTimer()
      if self.automaticSlidingInterval > 0.0 {
        self.startTimer()
      }
    }
  }
  
  private weak var contentView: UIView!
  private weak var collectionViewLayout: VMBannerCollectionViewLayout!
  private weak var collectionView: VMBannerCollectionView!
  
  private var dequeueSection = 0
  
  private var timer: Timer?
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.initialize()
  }
  
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.initialize()
  }
  
  deinit {
    self.collectionView.dataSource = nil
    self.collectionView.delegate = nil
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    self.contentView.frame = self.bounds
    self.collectionView.frame = self.bounds
  }
  
  public override func willMove(toSuperview newSuperview: UIView?) {
    super.willMove(toSuperview: newSuperview)
    newSuperview != nil ? self.startTimer() : self.cancelTimer()
  }
  
  public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
    self.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
  }
  
  public func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
    self.collectionView.register(nib, forCellWithReuseIdentifier: identifier)
  }
  
  public func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> VMBannerViewItemProtocol {
    let indexPath = IndexPath(item: index, section: self.dequeueSection)
    guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? VMBannerViewItemProtocol else {
      fatalError("Cell class must be based on the VMBannerViewItemProtocol protocal")
    }
    return cell
  }
  
  public func reloadData() {
    self.collectionViewLayout.needsReprepare = true
    self.collectionView.reloadData()
  }
  
  public func selectItem(at index: Int, animated: Bool) {
    let indexPath = self.nearbyIndexPath(index)
    let scrollPosition: UICollectionView.ScrollPosition = self.scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
    self.collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
  }
  
  public func deselectItem(at index: Int, animated: Bool) {
    let indexPath = self.nearbyIndexPath(index)
    self.collectionView.deselectItem(at: indexPath, animated: animated)
  }
  
  public func index(for cell: VMBannerViewItemProtocol) -> Int? {
    guard let indexPath = self.collectionView.indexPath(for: cell) else {
      return nil
    }
    return indexPath.item
  }
  
  public func cellForItem(at index: Int) -> VMBannerViewItemProtocol? {
    let indexPath = self.nearbyIndexPath(index)
    return self.collectionView.cellForItem(at: indexPath) as? VMBannerViewItemProtocol
  }
  
  private func initialize() {
    let contentView = UIView(frame: .zero)
    contentView.backgroundColor = UIColor.clear
    self.addSubview(contentView)
    
    self.contentView = contentView
    
    let collectionViewLayout = VMBannerCollectionViewLayout()
    let collectionView = VMBannerCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    collectionView.backgroundColor = UIColor.clear
    collectionView.dataSource = self
    collectionView.delegate = self
    self.contentView.addSubview(collectionView)
    
    self.collectionViewLayout = collectionViewLayout
    self.collectionView = collectionView
  }
  
  private func startTimer() {
    guard self.automaticSlidingInterval > 0.0 && self.timer == nil else {
      return
    }
    self.timer = Timer(timeInterval: self.automaticSlidingInterval, target: self, selector: #selector(slidingNext(_:)), userInfo: nil, repeats: true)
    RunLoop.current.add(self.timer!, forMode: .common)
  }
  
  private func cancelTimer() {
    guard self.timer != nil else {
      return
    }
    self.timer!.invalidate()
    self.timer = nil
  }
  
  private func nearbyIndexPath(_ index: Int) -> IndexPath {
    return nil
  }
  
  @objc private func slidingNext(_ timer: Timer?) {
    
  }
}

extension VMBannerView: UICollectionViewDataSource {
  
}

extension VMBannerView: UICollectionViewDelegate {
  
}

extension VMBannerView {
  
  public enum ScrollDirection {
    case horizontal
    case vertical
  }
  
  public static let automaticDistance: UInt = 0
  public static let automaticSize = CGSize.zero
}


