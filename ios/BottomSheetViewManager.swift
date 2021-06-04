@objc(BottomSheetView)
class BottomSheetView : UIView {

    @objc
    var onDismiss: RCTBubblingEventBlock?
    weak var sheetController: SheetViewController?
    
    private var sizeType: String = "dynamic"
    
    @objc
    func setSheetSize(_ size: NSString) {
      sizeType = size as String
    }
    
    private var borderRadius: Double = 12 {
      didSet {
        sheetController?.topCornersRadius = CGFloat(borderRadius)
      }
    }
    
    @objc
    func setBorderRadius(_ radius: Double) {
      borderRadius = radius
    }
    
    @objc
    func dismissSheet() {
      sheetController?.closeSheet(completion: { [weak self] in
        self?.sheetController = nil
      })
    }
      
    override init(frame: CGRect) {
      super.init(frame: frame)
      alpha = 0
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override func addSubview(_ view: UIView) {
      //super.addSubview(view)
      if sheetController != nil { return }
      self.pres(view)
    }
    
    override func layoutSubviews() {
      super.layoutSubviews()
      frame = .zero
    }
    
    
    func pres(_ view: UIView) {
      let v = view
      let controller = UIViewController()
      let sheetView = BottomSheetScrollView(child: v, sizeType: sizeType)
      controller.view = sheetView

      let sheetController = SheetViewController(
        controller: controller,
        sizes: [.fixed(1)],
        showIpadVersion: false
      )
      
      let touchHandler = RCTTouchHandler(bridge: nil /*RCTBridge needed*/)
      touchHandler?.attach(to: sheetView)
      
      if sheetWeakRefs.isEmpty { sheetController.overlayColor = .clear }
      sheetWeakRefs.append(SheetWeakRef(sheet: sheetController))
      
      sheetController.topCornersRadius = CGFloat(borderRadius)
      sheetController.adjustForBottomSafeArea = true
      sheetController.extendBackgroundBehindHandle = false
      
      sheetView.sheetController = sheetController
      topPresentingController.present(sheetController, animated: false)
      self.sheetController = sheetController
      sheetController.didDismiss = { [weak self] _ in
        self?.removeFromSuperview()
        self?.onDismiss?(nil)
        sheetWeakRefs.removeLast()
      }
    }
    
    deinit {
        debugPrint("BottomSheetViewManager deinit")
        dismissSheet()
    }
}

struct SheetWeakRef {
    weak var sheet: SheetViewController?
}

var sheetWeakRefs: [SheetWeakRef] = []

var topPresentingController: UIViewController {
  return UIApplication.shared.keyWindow!.rootViewController!.topViewController()
}

extension UIViewController {
  
  func topViewController() -> UIViewController {
    topViewController(rootViewController: self)
  }

  func topViewController(rootViewController: UIViewController) -> UIViewController {
    
    guard let pvc = rootViewController.presentedViewController else {
      return rootViewController
    }
    
    if let nvc = pvc as? UINavigationController {
      return topViewController(rootViewController: nvc.topViewController!)
    }
    
    return topViewController(rootViewController: pvc)
  }
}
