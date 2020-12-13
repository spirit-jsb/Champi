//
//  VMBannerView.swift
//  Champi
//
//  Created by max on 2020/10/23.
//

#if canImport(UIKit)

import UIKit

@IBDesignable
public class VMBannerView: UIView {
  
  @IBOutlet public weak var dataSource: VMBannerViewDataSource?
  @IBOutlet public weak var delegate: VMBannerViewDelegate?
  
  @IBInspectable
  public var interitemSpacing: CGFloat = 0 {
    didSet {
      self.collectionViewLayout.forceInvalidate()
    }
  }
  
  @IBInspectable
  public var itemSize: CGSize = VMBannerView.automaticSize {
    didSet {
      self.collectionViewLayout.forceInvalidate()
    }
  }
  
  @IBInspectable
  public var decelerationDistance: UInt = 1
  
  @IBInspectable
  public var backgroundView: UIView? {
    didSet {
      if let backgroundView = self.backgroundView {
        if backgroundView.superview != nil {
          backgroundView.removeFromSuperview()
        }
        self.insertSubview(backgroundView, at: 0)
        self.setNeedsLayout()
      }
    }
  }
  
  @IBInspectable
  public var bounces: Bool {
    get {
      return self.collectionView.bounces
    }
    set {
      self.collectionView.bounces = newValue
    }
  }
  
  @IBInspectable
  public var alwaysBounceVertical: Bool {
    get {
      return self.collectionView.alwaysBounceVertical
    }
    set {
      self.collectionView.alwaysBounceVertical = newValue
    }
  }
  
  @IBInspectable
  public var alwaysBounceHorizontal: Bool {
    get {
      return self.collectionView.alwaysBounceHorizontal
    }
    set {
      self.collectionView.alwaysBounceHorizontal = newValue
    }
  }
  
  @IBInspectable
  public var isScrollEnabled: Bool {
    set {
      self.collectionView.isScrollEnabled = newValue
    }
    get {
      return self.collectionView.isScrollEnabled
    }
  }
  
  @IBInspectable
  public var automaticSlidingInterval: TimeInterval = .zero {
    didSet {
      self.cancelTimer()
      if self.automaticSlidingInterval > 0.0 {
        self.startTimer()
      }
    }
  }
  
  @IBInspectable
  public var removeInfiniteLoopForSingleItem: Bool = false {
    didSet {
      self.reloadData()
    }
  }
  
  @IBInspectable
  public var isInfinite: Bool = false {
    didSet {
      self.collectionViewLayout.needsReprepare = true
      self.collectionView.reloadData()
    }
  }
  
  public var scrollDirection: VMBannerView.ScrollDirection = .horizontal {
    didSet {
      self.collectionViewLayout.forceInvalidate()
    }
  }
  
  public var transformer: VMBannerViewTransformer? {
    didSet {
      self.transformer?.bannerView = self
      self.collectionViewLayout.forceInvalidate()
    }
  }
  
  public var isTracking: Bool {
    return self.collectionView.isTracking
  }
  
  public var scrollOffset: CGFloat {
    let contentOffset = max(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y)
    let scrollOffset = CGFloat(contentOffset / self.collectionViewLayout.itemSpacing)
    return fmod(scrollOffset, CGFloat(self.numberOfItems))
  }
  
  public var panGestureRecognizer: UIPanGestureRecognizer {
    return self.collectionView.panGestureRecognizer
  }
  
  public private(set) var currentIndex = 0
  
  internal weak var contentView: UIView!
  internal weak var collectionViewLayout: VMBannerCollectionViewLayout!
  internal weak var collectionView: VMBannerCollectionView!
  
  internal var timer: Timer?
  
  internal var numberOfItems: Int = 0
  internal var numberOfSections: Int = 0
  
  private var dequeueSection = 0
  private var centermostIndexPath: IndexPath {
    guard self.numberOfItems > 0, self.collectionView.contentSize != .zero else {
      return IndexPath(item: 0, section: 0)
    }
    
    let sortedIndexPaths = self.collectionView.indexPathsForVisibleItems.sorted(by: { (lhs, rhs) -> Bool in
      let leftFrame = self.collectionViewLayout.frame(for: lhs)
      let rightFrame = self.collectionViewLayout.frame(for: rhs)
      
      var leftCenter: CGFloat
      var rightCenter: CGFloat
      var ruler: CGFloat
      
      switch self.scrollDirection {
      case .horizontal:
        leftCenter = leftFrame.midX
        rightCenter = rightFrame.midX
        ruler = self.collectionView.bounds.midX
      case .vertical:
        leftCenter = leftFrame.midY
        rightCenter = rightFrame.midY
        ruler = self.collectionView.bounds.midY
      }
      
      return abs(ruler - leftCenter) < abs(ruler - rightCenter)
    })
    
    guard let indexPath = sortedIndexPaths.first else {
      return IndexPath(item: 0, section: 0)
    }
    
    return indexPath
  }
  
  private var isPossibleRotating: Bool {
    guard let animationKeys = self.contentView.layer.animationKeys() else {
      return false
    }
    
    return animationKeys.contains(where: { ["position", "bounds.origin", "bounds.size"].contains($0) })
  }
  private var possibleTargetIndexPath: IndexPath?
  
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
    
    self.backgroundView?.frame = self.bounds
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
    let indexPath = self.nearbyIndexPath(for: index)
    let scrollPosition: UICollectionView.ScrollPosition = self.scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
    self.collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
  }
  
  public func deselectItem(at index: Int, animated: Bool) {
    let indexPath = self.nearbyIndexPath(for: index)
    self.collectionView.deselectItem(at: indexPath, animated: animated)
  }
  
  public func index(for cell: VMBannerViewItemProtocol) -> Int? {
    guard let indexPath = self.collectionView.indexPath(for: cell) else {
      return nil
    }
    return indexPath.item
  }
  
  public func cellForItem(at index: Int) -> VMBannerViewItemProtocol? {
    let indexPath = self.nearbyIndexPath(for: index)
    return self.collectionView.cellForItem(at: indexPath) as? VMBannerViewItemProtocol
  }
  
  public func scrollToItem(at index: Int, animated: Bool) {
    guard index < self.numberOfItems else {
      fatalError("index \(index) is out of range [0...\(self.numberOfItems - 1)]")
    }
    
    let indexPath: IndexPath = {
      if let indexPath = self.possibleTargetIndexPath, indexPath.item == index {
        defer {
          self.possibleTargetIndexPath = nil
        }
        return indexPath
      }
      return self.numberOfSections > 1 ? self.nearbyIndexPath(for: index) : IndexPath(item: index, section: 0)
    }()
    
    let contentOffset = self.collectionViewLayout.contentOffset(for: indexPath)
    self.collectionView.setContentOffset(contentOffset, animated: animated)
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
  
  private func nearbyIndexPath(for index: Int) -> IndexPath {
    let currentIndex = self.currentIndex
    let currentSection = self.centermostIndexPath.section
    
    if abs(currentIndex - index) <= self.numberOfItems / 2 {
      return IndexPath(item: index, section: currentSection)
    }
    else if index - currentIndex >= 0 {
      return IndexPath(item: index, section: currentSection - 1)
    }
    else {
      return IndexPath(item: index, section: currentSection + 1)
    }
  }
  
  @objc private func slidingNext(_ timer: Timer?) {
    guard let _ = self.superview, let _ = self.window, self.numberOfItems > 0, !self.isTracking else {
      return
    }
    
    let contentOffset: CGPoint = {
      let indexPath = self.centermostIndexPath
      let section = self.numberOfSections > 1 ? indexPath.section + (indexPath.item + 1) / self.numberOfItems : 0
      let item = (indexPath.item + 1) % self.numberOfItems
      return self.collectionViewLayout.contentOffset(for: IndexPath(item: item, section: section))
    }()
    
    self.collectionView.setContentOffset(contentOffset, animated: true)
  }
}

extension VMBannerView: UICollectionViewDataSource {
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.numberOfItems
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let dataSource = self.dataSource else {
      fatalError("Please implement VMBannerViewDataSource protocol method")
    }
    
    let index = indexPath.item
    
    self.dequeueSection = indexPath.section
    
    let cell = dataSource.bannerView(self, cellForItemAt: index)
    
    return cell
  }
  
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    guard let dataSource = self.dataSource else {
      fatalError("Please implement VMBannerViewDataSource protocol method")
    }
    
    self.numberOfItems = dataSource.numberOfItems(in: self)
    guard self.numberOfItems > 0 else {
      return 0
    }
    
    self.numberOfSections = self.isInfinite && (self.numberOfItems > 1 || !self.removeInfiniteLoopForSingleItem) ? Int(Int16.max) / self.numberOfItems : 1
    
    return self.numberOfSections
  }
}

extension VMBannerView: UICollectionViewDelegate {
  
  public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
    guard let function = self.delegate?.bannerView(_:shouldHighlightItemAt:) else {
      return true
    }
    
    let index = indexPath.item % self.numberOfItems
    return function(self, index)
  }
  
  public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    guard let function = self.delegate?.bannerView(_:didHighlightItemAt:) else {
      return
    }
    let index = indexPath.item % self.numberOfItems
    function(self,index)
  }
  
  public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    guard let function = self.delegate?.bannerView(_:shouldSelectItemAt:) else {
      return true
    }
    
    let index = indexPath.item % self.numberOfItems
    return function(self, index)
  }
  
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let function = self.delegate?.bannerView(_:didSelectItemAt:) else {
      return
    }
    
    self.possibleTargetIndexPath = indexPath
    defer {
      self.possibleTargetIndexPath = nil
    }
    
    let index = indexPath.item % self.numberOfItems
    function(self,index)
  }
  
  public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    guard let function = self.delegate?.bannerView(_:willDisplay:forItemAt:) else {
      return
    }
    
    let index = indexPath.item % self.numberOfItems
    function(self, cell as! VMBannerViewItemProtocol , index)
  }
  
  public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    guard let function = self.delegate?.bannerView(_:didEndDisplaying:forItemAt:) else {
      return
    }
    
    let index = indexPath.item % self.numberOfItems
    function(self, cell as! VMBannerViewItemProtocol , index)
  }
}

extension VMBannerView: UIScrollViewDelegate {
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if !self.isPossibleRotating && self.numberOfItems > 0 {
      // In case someone is using KVO
      let currentIndex = lround(Double(self.scrollOffset)) % self.numberOfItems
      if currentIndex != self.currentIndex {
        self.currentIndex = currentIndex
      }
    }
    
    guard let function = self.delegate?.bannerViewDidScroll(_:) else {
      return
    }
    function(self)
  }
  
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    if let function = self.delegate?.bannerViewWillBeginDragging(_:) {
      function(self)
    }
    if self.automaticSlidingInterval > 0 {
      self.cancelTimer()
    }
  }
  
  public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    if let function = self.delegate?.bannerViewWillEndDragging(_:targetIndex:) {
      let contentOffset = self.scrollDirection == .horizontal ? targetContentOffset.pointee.x : targetContentOffset.pointee.y
      let targetIndex = lround(Double(contentOffset / self.collectionViewLayout.itemSpacing)) % self.numberOfItems
      function(self, targetIndex)
    }
    
    if self.automaticSlidingInterval > 0 {
      self.startTimer()
    }
  }
  
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if let function = self.delegate?.bannerViewDidEndDecelerating(_:) {
      function(self)
    }
  }
  
  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    if let function = self.delegate?.bannerViewDidEndScrollingAnimation(_:) {
      function(self)
    }
  }
}

extension VMBannerView {
  
  public enum ScrollDirection {
    case horizontal
    case vertical
  }
  
  public static let automaticDistance: UInt = 0
  public static let automaticSize = CGSize.zero
}

#endif
