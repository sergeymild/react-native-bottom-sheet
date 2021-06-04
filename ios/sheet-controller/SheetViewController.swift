//
//  SheetViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/23/18.
//  Copyright © 2018 Gordon Tucker. All rights reserved.
//

import UIKit
import NotificationCenter
import IQKeyboardManagerSwift

public extension UIViewController {
  func findSheetController() -> SheetViewController? {
    var p = parent
    while p != nil {
      if p is SheetViewController { return (p  as! SheetViewController) }
      p = p?.parent
    }
    return nil
  }
}

//swiftlint:disable all
open class SheetViewController: UIViewController {
  // MARK: - Public Properties
  public private(set) weak var childViewController: UIViewController?
  
  public let containerView = UIView()
  /// The view that can be pulled to resize a sheeet. This includes the background. To change the color of the bar, use `handleView` instead
  public let pullBarView = UIView()
  public let handleView = UIView()
  public static let handleColor: UIColor = UIColor(white: 0, alpha: 0.24)
  public static let handleSize: CGSize = CGSize(width: 50, height: 6)
  public static let handleTopEdgeInset: CGFloat = 9
  public static let handleBottomEdgeInset: CGFloat = 9
  public static let iPadBottomInset: CGFloat = 16
  
  /// If true, tapping on the overlay above the sheet will dismiss the sheet view controller
  public var dismissOnBackgroundTap: Bool = true
  
  /// If true, sheet may be dismissed by panning down
  public var dismissOnPan: Bool = true
  public var showIpadVersion: Bool = false
  public var forceRenderCentered = false
  
  /// If false, the pan gesture to dismiss the sheet will not be recognized when it conflicts with a UIControl
  public var shouldRecognizePanGestureWithUIControls: Bool = false
  
  /// If true, sheet's dismiss view will be generated, otherwise sheet remains fixed and will need to be dismissed programatically
  public var dismissable: Bool = true
  
  public var pullBarBackgroundColor: UIColor = UIColor.white.withAlphaComponent(0.12)
  public var shouldShowHandleView: Bool = true {
    didSet {
      if !shouldShowHandleView { extendBackgroundBehindHandle = false }
    }
  }
  public var extendBackgroundBehindHandle: Bool = true {
    didSet {
      guard isViewLoaded else { return }
      self.pullBarView.backgroundColor = extendBackgroundBehindHandle
        ? childViewController?.view.backgroundColor
        : UIColor.clear
      self.updateRoundedCorners()
    }
  }
  
  private var firstPanPoint: CGPoint = CGPoint.zero
  
  /// If true, the child view controller will be inset to account for the bottom safe area. This must be set before the sheet view controller loads for it to function properly
  public var adjustForBottomSafeArea: Bool = false
  
  /// Adjust corner radius for the top corners. Only available for iOS 11 and above
  public var topCornersRadius: CGFloat = 3 {
    didSet {
      guard isViewLoaded else { return }
      self.updateRoundedCorners()
    }
  }
  
  /// The color of the overlay above the sheet. Default is a transparent black.
  public var overlayColor: UIColor = UIColor(white: 0, alpha: 0.7) {
    didSet {
      if self.isViewLoaded && self.view?.window != nil {
        self.view.backgroundColor = self.overlayColor
      }
    }
  }
  
  public var isBlurNeeded = false
  private var blurView: UIView = {
    let effect = UIBlurEffect(style: .light)
    let view = UIVisualEffectView(effect: effect)
    view.alpha = 0
    
    return view
  }()
  
  public var willDismiss: ((SheetViewController) -> Void)?
  public var didDismiss: ((SheetViewController) -> Void)?
  
  // MARK: - Private properties
  /// The current preferred container size
  private var containerSize: SheetSize = .fixed(300)
  /// The current actual container size
  private var actualContainerSize: SheetSize = .fixed(300) {
    didSet {
      let moreThanHalf: Bool
      switch actualContainerSize {
      case .fullScreen:
        moreThanHalf = true
      case .halfScreen:
        moreThanHalf = false
      case .fixed(let height):
        moreThanHalf = UIScreen.main.bounds.height * 2 / 3 - height < 0
      }
      
      if actualContainerSize == oldValue { return }
      
      if moreThanHalf {
        NotificationCenter.default.post(
          Notification(name: Notification.Name("presentedControllerDidAppear"))
        )
      } else {
        NotificationCenter.default.post(
          Notification(name: Notification.Name("presentedControllerDidDisappear"))
        )
      }
    }
  }
  /// The array of sizes we are trying to pin to when resizing the sheet. To set, use `setSizes` function
  private var orderedSheetSizes: [SheetSize] = [.fixed(300), .fullScreen]
  
  private lazy var panGestureRecognizer: InitialTouchPanGestureRecognizer! = {
    let panGestureRecognizer = InitialTouchPanGestureRecognizer(target: self, action: #selector(panned(_:)))
    containerView.addGestureRecognizer(panGestureRecognizer)
    panGestureRecognizer.delegate = self
    self.panGestureRecognizer = panGestureRecognizer
    return panGestureRecognizer
  }()
  /// The child view controller's scroll view we are watching so we can override the pull down/up to work on the sheet when needed
  private weak var childScrollView: UIScrollView?
  
  private var containerHeightConstraint: NSLayoutConstraint!
  private var containerBottomConstraint: NSLayoutConstraint!
  private var prefferedControllerWidth: CGFloat
  
  var currentHeight: CGFloat {
    return self.containerHeightConstraint.constant
  }
  
  private var safeAreaInsets: UIEdgeInsets {
    var insets = UIEdgeInsets.zero
    if #available(iOS 11.0, *) {
      insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? insets
    }
    insets.top = max(insets.top, 20)
    return insets
  }
  
  // MARK: - Functions
  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("Use the init(controller:, sizes:) initializer")
  }
  
  /// Initialize the sheet view controller with a child. This is the only initializer that will function properly.
  public init(
    controller: UIViewController,
    prefferedControllerWidth: CGFloat = 325,
    sizes: [SheetSize] = [],
    showIpadVersion: Bool
  ) {
    self.showIpadVersion = showIpadVersion
    self.prefferedControllerWidth = prefferedControllerWidth
    super.init(nibName: nil, bundle: nil)
    self.childViewController = controller
    if sizes.count > 0 {
      self.setSizes(sizes, animated: false)
    }
    self.modalPresentationStyle = .overCurrentContext
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    if (self.childViewController == nil) {
      fatalError("SheetViewController requires a child view controller")
    }
    
    self.view.backgroundColor = .clear
    if showIpadVersion {
      view.addSubview(blurView) { view in
        view.edges.pinToSuperview()
      }
    }
    self.setUpContainerView()
    
    if dismissable {
      self.setUpDismissView()
    }
    
    if shouldShowHandleView { self.setUpPullBarView() }
    self.setUpChildViewController()
    self.updateRoundedCorners()
    
    activateKeyboardManager()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardShown(_:)),
      name: UIResponder.keyboardWillChangeFrameNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardDismissed(_:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
  private func activateKeyboardManager() {
    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.enableAutoToolbar = false
    IQKeyboardManager.shared.keyboardDistanceFromTextField = 0
  }
  
  private func deactivateKeyboardManager() {
    IQKeyboardManager.shared.enable = false
  }
  
  public func disableSwipeOnContentView() {
    containerView.removeGestureRecognizer(panGestureRecognizer)
  }
  
  public func addViewForSwipeDismiss(view: UIView?) {
    let p = InitialTouchPanGestureRecognizer(target: self, action: #selector(panned(_:)))
    view?.addGestureRecognizer(p)
    if view is UINavigationBar {
      self.pullBarView.addGestureRecognizer(panGestureRecognizer)
    }
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.view.backgroundColor = .clear
    
    UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: { [weak self] in
      guard let self = self else { return }
      self.containerView.transform = CGAffineTransform.identity
      self.actualContainerSize = .fixed(self.containerView.frame.height)
      
      if self.showIpadVersion, self.isBlurNeeded {
        self.blurView.alpha = 1
      } else if self.overlayColor != .clear {
        self.view.backgroundColor = self.overlayColor
      }
    })
  }
  
  /// Change the sizes the sheet should try to pin to
  public func setSizes(
    _ sizes: [SheetSize],
    animated: Bool = true
  ) {
    guard sizes.count > 0 else {
      return
    }
    self.orderedSheetSizes = sizes.sorted(by: { self.height(for: $0) < self.height(for: $1) })
    
    self.resize(to: sizes[0], animated: animated)
  }
  
  public func resize(to size: SheetSize, animated: Bool = true) {
    if animated {
      UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: { [weak self] in
        guard let self = self, let constraint = self.containerHeightConstraint else { return }
        constraint.constant = self.height(for: size)
        self.view.layoutIfNeeded()
      })
    } else {
      self.containerHeightConstraint?.constant = self.height(for: size)
    }
    self.containerSize = size
    self.actualContainerSize = size
  }
  
  private func setUpContainerView() {
    self.view.addSubview(self.containerView) { (subview) in
      if UIDevice.current.userInterfaceIdiom == .pad {
        subview.width.set(prefferedControllerWidth)
        if showIpadVersion {
          if forceRenderCentered {
            subview.centerX.alignWithSuperview()
          } else {
            subview.right.offsetting(by: 16).pinToSuperview()
          }
          self.containerBottomConstraint = subview.bottom.offsetting(
            by: safeAreaInsets.bottom + Self.iPadBottomInset
          ).pinToSuperview()
        } else {
          subview.centerX.alignWithSuperview()
          subview.bottom.pinToSuperview()
        }
      } else {
        subview.edges(.left, .right).pinToSuperview()
        self.containerBottomConstraint = subview.bottom.pinToSuperview()
      }
      subview.top.pinToSuperview(inset: self.safeAreaInsets.top + 16, relation: .greaterThanOrEqual)
      self.containerHeightConstraint = subview.height.set(self.height(for: self.containerSize))
      self.containerHeightConstraint.priority = UILayoutPriority(900)
    }
    self.containerView.layer.masksToBounds = true
    
    self.containerView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
  }
  
  private func setUpChildViewController() {
    self.childViewController?.willMove(toParent: self)
    self.addChild(self.childViewController!)
    let bottomInset = self.safeAreaInsets.bottom
    
    self.containerView.addSubview(self.childViewController!.view) { (subview) in
      subview.edges(.left, .right).pinToSuperview()
      if self.adjustForBottomSafeArea {
        subview.bottom.pinToSuperview(inset: bottomInset, relation: .equal)
      } else {
        subview.bottom.pinToSuperview()
      }
      subview.top.align(
        with: shouldShowHandleView
          ? self.pullBarView.al.bottom
          : self.containerView.al.top
      )
    }
    
    self.childViewController?.view.layer.masksToBounds = true
    
    self.childViewController?.didMove(toParent: self)
  }
  
  /// Updates which view has rounded corners (only supported on iOS 11)
  private func updateRoundedCorners() {
    if #available(iOS 11.0, *) {
      let controllerWithRoundedCorners = self.containerView
      
      var cornerMasks: CACornerMask = self.topCornersRadius > 0
        ? [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        : []
      
      if showIpadVersion {
        cornerMasks.insert(.layerMinXMaxYCorner)
        cornerMasks.insert(.layerMaxXMaxYCorner)
      }
      controllerWithRoundedCorners.layer.maskedCorners = self.topCornersRadius > 0
        ? cornerMasks
        : []
      controllerWithRoundedCorners.layer.cornerRadius = self.topCornersRadius
    }
  }
  
  private func setUpDismissView() {
    let dismissAreaView = UIView(frame: CGRect.zero)
    view.addSubview(dismissAreaView, containerView) { (dismissAreaView, containerView) in
      dismissAreaView.edges(.top, .left, .right).pinToSuperview()
      dismissAreaView.bottom.align(with: self.showIpadVersion ? containerView.bottom : containerView.top)
    }
    dismissAreaView.backgroundColor = UIColor.clear
    dismissAreaView.isUserInteractionEnabled = true
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissTapped))
    dismissAreaView.addGestureRecognizer(tapGestureRecognizer)
  }
  
  private func setUpPullBarView() {
    self.containerView.addSubview(self.pullBarView) { (subview) in
      subview.edges(.top, .left, .right).pinToSuperview()
    }
    
    self.pullBarView.addSubview(handleView) { (subview) in
      subview.top.pinToSuperview(inset: Self.handleTopEdgeInset, relation: .equal)
      subview.bottom.pinToSuperview(inset: Self.handleBottomEdgeInset, relation: .equal)
      subview.centerX.alignWithSuperview()
      subview.size.set(Self.handleSize)
    }
    pullBarView.layer.masksToBounds = true
    pullBarView.backgroundColor = extendBackgroundBehindHandle
      ? childViewController!.view.backgroundColor
      : UIColor.clear
    
    handleView.layer.cornerRadius = Self.handleSize.height / 2.0
    handleView.layer.masksToBounds = true
    handleView.backgroundColor = Self.handleColor
    pullBarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissTapped)))
  }
  
  @objc func dismissTapped() {
    guard dismissOnBackgroundTap else { return }
    self.closeSheet()
  }
  
  public override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    self.didDismiss?(self)
  }
  
  /// Animates the sheet to the closed state and then dismisses the view controller
  public func closeSheet(completion: (() -> Void)? = nil) {
    UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: { [weak self] in
      self?.containerView.transform = CGAffineTransform(
        translationX: 0,
        y: self?.containerView.frame.height ?? 0
      )
      self?.view.backgroundColor = UIColor.clear
      self?.blurView.alpha = 0
    }, completion: { [weak self] complete in
      self?.dismiss(animated: false, completion: completion)
    })
  }
  
  @objc func panned(_ gesture: UIPanGestureRecognizer) {
    if !dismissable { return }
    let point = gesture.translation(in: gesture.view?.superview)
    if gesture.state == .began {
      self.firstPanPoint = point
      self.actualContainerSize = .fixed(self.containerView.frame.height)
    }
    
    let minHeight = min(self.height(for: self.actualContainerSize), self.height(for: self.orderedSheetSizes.first))
    let maxHeight = max(self.height(for: self.actualContainerSize), self.height(for: self.orderedSheetSizes.last))
    
    var newHeight = max(0, self.height(for: self.actualContainerSize) + (self.firstPanPoint.y - point.y))
    var offset: CGFloat = 0
    if newHeight < minHeight {
      offset = minHeight - newHeight
      newHeight = minHeight
    }
    if newHeight > maxHeight {
      newHeight = maxHeight
    }
    
    if gesture.state == .cancelled || gesture.state == .failed {
      UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
        self.containerView.transform = CGAffineTransform.identity
        self.containerHeightConstraint.constant = self.height(for: self.containerSize)
      }, completion: nil)
    } else if gesture.state == .ended {
      let velocity = (0.2 * gesture.velocity(in: self.view).y)
      var finalHeight = newHeight - offset - velocity
      if velocity > 500 {
        // They swiped hard, always just close the sheet when they do
        finalHeight = -1
      }
      
      let animationDuration = TimeInterval(abs(velocity*0.0002) + 0.2)
      
      guard finalHeight >= (minHeight / 2) || !dismissOnPan || !dismissable else {
        // Dismiss
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseOut], animations: { [weak self] in
          self?.containerView.transform = CGAffineTransform(
            translationX: 0,
            y: self?.containerView.frame.height ?? 0
          )
          self?.view.backgroundColor = UIColor.clear
        }, completion: { [weak self] complete in
          self?.dismiss(animated: false, completion: nil)
        })
        return
      }
      
      var newSize = self.containerSize
      if point.y < 0 {
        // We need to move to the next larger one
        newSize = self.orderedSheetSizes.last ?? self.containerSize
        for size in self.orderedSheetSizes.reversed() {
          if finalHeight < self.height(for: size) {
            newSize = size
          } else {
            break
          }
        }
      } else {
        // We need to move to the next smaller one
        newSize = self.orderedSheetSizes.first ?? self.containerSize
        for size in self.orderedSheetSizes {
          if finalHeight > self.height(for: size) {
            newSize = size
          } else {
            break
          }
        }
      }
      self.containerSize = newSize
      
      UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseOut], animations: {
        self.containerView.transform = .identity
        self.containerHeightConstraint.constant = self.height(for: newSize)
        self.view.layoutIfNeeded()
      }, completion: { [weak self] complete in
        guard let self = self else { return }
        self.actualContainerSize = .fixed(self.containerView.frame.height)
      })
    } else {
      Constraints(for: self.containerView) { (containerView) in
        self.containerHeightConstraint.constant = newHeight
      }
      
      if offset > 0 {
        self.containerView.transform = CGAffineTransform(translationX: 0, y: offset)
      } else {
        self.containerView.transform = .identity
      }
      
    }
  }
  
  /// Handle a scroll view in the child view controller by watching for the offset for the scrollview and taking priority when at the top (so pulling up/down can grow/shrink the sheet instead of bouncing the child's scroll view)
  public func handleScrollView(_ scrollView: UIScrollView) {
    scrollView.panGestureRecognizer.require(toFail: panGestureRecognizer)
    self.childScrollView = scrollView
    scrollView.keyboardDismissMode = .onDrag
  }
  
  private func height(for size: SheetSize?) -> CGFloat {
    guard let size = size else { return 0 }
    switch (size) {
    case .fixed(let height):
      return height
    case .fullScreen:
      let insets = self.safeAreaInsets
      let additionalOffset: CGFloat = showIpadVersion ? 48 + Self.iPadBottomInset + 16 + 16 : 0
      return UIScreen.main.bounds.height - insets.top - 16 - additionalOffset
    case .halfScreen:
      return UIScreen.main.bounds.height / 2 + 24
    }
  }
  
  var keyboardHeight: CGFloat = 0
  
  @objc func keyboardShown(_ notification: Notification) {
      guard let info:[AnyHashable: Any] = notification.userInfo, let keyboardRect:CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
      
      let windowRect = self.view.convert(self.view.bounds, to: nil)
      let actualHeight = windowRect.maxY - keyboardRect.origin.y
      self.adjustForKeyboard(height: actualHeight, from: notification)
  }
  
  @objc func keyboardDismissed(_ notification: Notification) {
      self.adjustForKeyboard(height: 0, from: notification)
  }
  
  private func adjustForKeyboard(height: CGFloat, from notification: Notification) {
      guard let info:[AnyHashable: Any] = notification.userInfo else { return }
      self.keyboardHeight = height
      
      let duration:TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
      let animationCurveRawNSN = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
      let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
      let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
      
      UIView.animate(withDuration: duration, delay: 0, options: animationCurve, animations: {
          self.containerBottomConstraint.constant = min(0, -height + (self.adjustForBottomSafeArea ? self.safeAreaInsets.bottom : 0))
          // Tell our child view it needs to layout again to prevent the navigation bar from moving to the wrong spot if in a UINavigationController
          self.childViewController?.view.setNeedsLayout()
          self.view.layoutIfNeeded()
      }, completion: nil)
  }
  
  deinit {
    deactivateKeyboardManager()
    
    NotificationCenter.default.post(
      Notification(name: Notification.Name("presentedControllerDidDisappear"))
    )
    // Memory leaks fix
    if let nav = childViewController as? UINavigationController {
      nav.popToRootViewController(animated: false)
      nav.viewControllers = []
    }
    debugPrint("----== DEINIT")
  }
}

extension SheetViewController: UIGestureRecognizerDelegate {
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    // Allowing gesture recognition on a UIControl seems to prevent its events from firing properly sometimes
    if !shouldRecognizePanGestureWithUIControls {
      if let view = touch.view {
        return !(view is UIControl)
      }
    }
    return true
  }
  
  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let panGestureRecognizer = gestureRecognizer as? InitialTouchPanGestureRecognizer, let childScrollView = self.childScrollView, let point = panGestureRecognizer.initialTouchLocation else { return true }
    
    let pointInChildScrollView = self.view.convert(point, to: childScrollView).y - childScrollView.contentOffset.y
    
    let velocity = panGestureRecognizer.velocity(in: panGestureRecognizer.view?.superview)
    guard pointInChildScrollView > 0, pointInChildScrollView < childScrollView.bounds.height else {
      childScrollView.endEditing(true)
      return true
    }
    let topInset = childScrollView.contentInset.top
    guard abs(velocity.y) > abs(velocity.x), childScrollView.contentOffset.y == -topInset else { return false }
    
    if velocity.y < 0 {
      let containerHeight = height(for: self.containerSize)
      return height(for: self.orderedSheetSizes.last) > containerHeight && containerHeight < height(for: SheetSize.fullScreen)
    } else {
      return true
    }
  }
}