//
//  BottomSheetScrollView.swift
//  react-native-bottom-sheet
//
//  Created by Sergei Golishnikov on 04/06/2021.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

class BottomSheetScrollView: UIScrollView {
  weak var sheetController: SheetViewController? {
    didSet {
      sheetController?.handleScrollView(self)
      switch sizeType {
      case "dynamic": break
      case "fullScreen": sheetController?.setSizes([.fullScreen])
      case "halfScreen": sheetController?.setSizes([.halfScreen])
      default:
        let parts = sizeType.split(separator: "%")
        sheetController?.setSizes([.fixed(CGFloat(Float(parts[0])!))])
      }
    }
  }
  
  private let sizeType: String
  
  init(child: UIView, sizeType: String) {
    self.sizeType = sizeType
    super.init(frame: .init(origin: .zero, size: child.frame.size))
    child.removeFromSuperview()
    addSubview(child)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private var screenSafeArea: UIEdgeInsets {
      var inserts = UIEdgeInsets.zero
      if #available(iOS 11.0, *) {
          inserts = UIApplication.shared.keyWindow?.safeAreaInsets ?? inserts
      }
      inserts.top = max(inserts.top, 20)
      return inserts
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    backgroundColor = subviews[0].backgroundColor
    sheetController?.containerView.backgroundColor = backgroundColor
    if sizeType == "dynamic" {
      let newContentSize = CGSize(
        width: frame.width,
        height: subviews[0].frame.height
      )
      if contentSize != newContentSize {
        debugPrint("New content size", subviews[0].frame.height)
        contentSize = newContentSize
        IQKeyboardManager.shared.reloadLayoutIfNeeded()
      }
        
      let maxHeight = UIScreen.main.bounds.height - screenSafeArea.top - 20
      let contentHeight = contentSize.height + screenSafeArea.bottom
        + SheetViewController.handleBottomEdgeInset
        + SheetViewController.handleTopEdgeInset
        + SheetViewController.handleSize.height
        
      let adoptedHeight = min(maxHeight, contentHeight)
        
      if sheetController?.currentHeight != adoptedHeight {
        debugPrint("adopted height", adoptedHeight)
        sheetController?.setSizes([.fixed(adoptedHeight)])
      }
    }
//    else if sizeType.starts(with: "fixed:") {
//     let parts = sizeType.split(separator: ":")
//     frame.size.height = CGFloat(Float(parts[1])!)
//     contentSize = .init(width: frame.width, height: CGFloat(Float(parts[0])!))
//   }
  }
  
  deinit {
    subviews[0].removeFromSuperview()
    debugPrint("BottomSheetScrollView deinit")
  }
}
