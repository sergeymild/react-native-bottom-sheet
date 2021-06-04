//
//  BottomSheetViewManager.swift
//  BottomSheet
//
//  Created by Sergei Golishnikov on 04/06/2021.
//  Copyright © 2021 Facebook. All rights reserved.
//

import Foundation
import React

class RCTModalHostShadowVie: RCTShadowView {
    override func layoutSubviews(with layoutContext: RCTLayoutContext) {
        let first = self.reactSubviews()!.first!
        let firstWidth = first.layoutMetrics.frame.width
        let firstHeight = first.layoutMetrics.frame.height
        debugPrint(firstWidth, firstHeight)
        self.size = CGSize(width: RCTScreenSize().width, height: 10_000_000)
    }
}

@objc(BottomSheetManager)
class BottomSheetManager: RCTViewManager {
    override class func requiresMainQueueSetup() -> Bool {
        return true
    }

    override func shadowView() -> RCTShadowView! {
        return RCTModalHostShadowVie()
    }
    
    override func view() -> UIView! {
        return BottomSheetView()
    }
    
    @objc
    func dismissSheet(_ viewTag: NSNumber) {
        self.bridge.uiManager.addUIBlock { (uiManager, viewRegistry) in
            let view = viewRegistry?[viewTag]
            if view is BottomSheetView {
                (view as! BottomSheetView).dismissSheet()
            }
        }
    }
}
