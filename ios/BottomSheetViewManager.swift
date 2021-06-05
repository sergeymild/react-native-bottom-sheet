import UIKit
import React

@objc(BottomSheetView)
class BottomSheetView : UIView {
    
    private let touchHandler: RCTTouchHandler
    private weak var sheetView: BottomSheetScrollView?
    private weak var _reactSubview: RCTView?
    
    @objc
    private var sheetSize: String = "dynamic"
    
    @objc
    var onDismiss: RCTBubblingEventBlock?
    private weak var sheetController: SheetViewController?
    
    init(frame: CGRect, bridge: RCTBridge) {
        touchHandler = RCTTouchHandler(bridge: bridge)
        super.init(frame: frame)
        debugPrint("init", self)
        alpha = 0
    }

    @objc
    private var cornerRadius: Double = 12 {
      didSet {
        sheetController?.topCornersRadius = CGFloat(cornerRadius)
      }
    }
    
    @objc
    func dismissSheet() {
      sheetController?.closeSheet(completion: { [weak self] in
        self?.sheetController = nil
      })
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override func addSubview(_ view: UIView) {
      //super.addSubview(view)
        debugPrint("addSubview", _reactSubview, view, sheetView, sheetController)
        
      if _reactSubview != nil { fatalError("Modal view can only have one subview") }
      _reactSubview = view as? RCTView
        
      if sheetController == nil, let v = _reactSubview {
          self.present(v)
      }
        debugPrint("addSubview", self, sheetView)
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        if let v = sheetView {
            debugPrint("removeFromSuperview", self, v)
            touchHandler.detach(from: v)
            dismissSheet()
        }
    }
    
    override func layoutSubviews() {
      super.layoutSubviews()
      frame = .zero
    }
    
    
    func present(_ view: UIView) {
      let v = view
      let controller = UIViewController()
      let sheetView = BottomSheetScrollView(child: v, sizeType: sheetSize)
      controller.view = sheetView
      self.sheetView = sheetView

      let sheetController = SheetViewController(
        controller: controller,
        sizes: [.fixed(1)],
        showIpadVersion: false
      )

      touchHandler.attach(to: sheetView)
      
      sheetWeakRefs.last?.sheet?.overlayColor = .clear
      sheetWeakRefs.append(SheetWeakRef(sheet: sheetController))
      
      sheetController.topCornersRadius = CGFloat(cornerRadius)
      sheetController.adjustForBottomSafeArea = true
      sheetController.extendBackgroundBehindHandle = false
      
      sheetView.sheetController = sheetController
      topPresentingController.present(sheetController, animated: false)
      self.sheetController = sheetController
      sheetController.didDismiss = { [weak self] _ in
        debugPrint("didDismiss")
        self?.onDismiss?(nil)
        sheetWeakRefs.removeLast()
        sheetWeakRefs.last?.sheet?.overlayColor = SheetViewController.baseOverlayColor
      }
    }
    
    deinit {
        debugPrint("BottomSheetViewManager deinit")
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
