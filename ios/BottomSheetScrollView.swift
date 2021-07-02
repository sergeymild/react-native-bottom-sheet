//
//  BottomSheetScrollView.swift
//  react-native-bottom-sheet
//
//  Created by Sergei Golishnikov on 04/06/2021.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

func calculateSheetSize(sizeType: String) -> [SheetSize] {
    switch sizeType {
    case "dynamic": return []
    case "fullScreen": return [.fullScreen]
    case "halfScreen": return [.halfScreen]
    default:
        
        if let fixedHeight = Int(sizeType) {
            return [.fixed(CGFloat(fixedHeight))]
        }
        
        guard sizeType.hasSuffix("%") else { fatalError("Incorrect sizeType format") }
        let percentage = Int(String(sizeType.dropLast()))!
        let height = UIScreen.main.bounds.height * CGFloat(percentage) / 100
        return [.fixed(height)]
    }
    fatalError("Passed unsupported sizeType: \(sizeType)")
}

private var screenSafeArea: UIEdgeInsets {
    var insets = UIEdgeInsets.zero
    if #available(iOS 11.0, *) {
        insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? insets
    }
    insets.top = max(insets.top, 20)
    return insets
}

class BottomSheetScrollView: UIView {
    private let sizeType: String
    private let shouldApplyBottomSafeArea: Bool
    private let useScrollView: Bool
    
    weak var sheetController: SheetViewController? {
        didSet {
            let size = calculateSheetSize(sizeType: sizeType)
            if !size.isEmpty { sheetController?.setSizes(size) }
            if useScrollView {
                sheetController?.handleScrollView(scrollView!)
            } else {
                
                if let scrollView = bottomSheetChild as? UIScrollView {
                    sheetController?.handleScrollView(scrollView)
                }
            }
        }
    }
    
    private var bottomSheetChild: UIView {
        if useScrollView { return subviews[0].subviews[0] }
        else { return subviews[0] }
    }
    
    private var scrollView: UIScrollView? {
        if useScrollView { return subviews[0] as! UIScrollView }
        return nil
    }
    
    init(
        child: UIView,
        sizeType: String,
        useScrollView: Bool,
        shouldApplyBottomSafeArea: Bool
    ) {
        self.useScrollView = useScrollView
        self.sizeType = sizeType
        self.shouldApplyBottomSafeArea = shouldApplyBottomSafeArea
        super.init(frame: .init(origin: .zero, size: child.frame.size))
        child.removeFromSuperview()
        if useScrollView {
            let scrollView = UIScrollView()
            scrollView.addSubview(child)
            addSubview(scrollView)
        } else {
            addSubview(child)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        assert(subviews.count == 1, "BottomSheet can't have more that one subview")
        backgroundColor = bottomSheetChild.backgroundColor
        
        if sizeType != "dynamic" {
            let subview = bottomSheetChild
            subview.accessibilityLabel = "primaryParent"
            subview.frame.size = self.frame.size
            subview.setNeedsLayout()
            subview.layoutIfNeeded()
            return
        }
        
        let newContentSize = CGSize(
            width: frame.width,
            height: bottomSheetChild.frame.height
        )
        if scrollView?.contentSize != newContentSize {
            debugPrint("New content size", bottomSheetChild.frame.height)
            scrollView?.contentSize = newContentSize
            IQKeyboardManager.shared.reloadLayoutIfNeeded()
        }
        
        let maxHeight = UIScreen.main.bounds.height - screenSafeArea.top - 20
        let contentHeight = bottomSheetChild.frame.height
        
        let adoptedHeight = min(maxHeight, contentHeight)
        if shouldApplyBottomSafeArea {
            frame.size.height = bottomSheetChild.frame.height + screenSafeArea.bottom
        }
        
        if sheetController?.currentHeight != adoptedHeight {
            debugPrint("adopted height", adoptedHeight)
            sheetController?.setSizes([.fixed(adoptedHeight)])
        }
    }
    
    deinit {
        subviews[0].removeFromSuperview()
        debugPrint("BottomSheetScrollView deinit")
    }
}
