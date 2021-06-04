//
//  SheetDockSize.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/27/18.
//  Copyright © 2018 Gordon Tucker. All rights reserved.
//

import UIKit

//swiftlint:disable all
public enum SheetSize {
    case fixed(CGFloat)
    case halfScreen
    case fullScreen
}

extension SheetSize: Equatable {
    public static func == (lhs: SheetSize, rhs: SheetSize) -> Bool {
        switch lhs {
        case .halfScreen:
            if case .halfScreen = rhs {
                return true
            }
        case .fullScreen:
            if case .fullScreen = rhs {
                return true
            }
        case .fixed(let height):
            if case .fixed(height) = rhs {
                return true
            }
        }
        return false
    }
}
