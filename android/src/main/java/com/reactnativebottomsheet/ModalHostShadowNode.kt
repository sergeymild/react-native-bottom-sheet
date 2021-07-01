/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
package com.reactnativebottomsheet

import com.facebook.react.uimanager.LayoutShadowNode
import com.facebook.react.uimanager.PixelUtil
import com.facebook.react.uimanager.ReactShadowNode

internal class ModalHostShadowNode : LayoutShadowNode() {
    override fun calculateLayoutOnChildren(): MutableIterable<ReactShadowNode<ReactShadowNode<*>>> {
        val result = super.calculateLayoutOnChildren()
        setStyleHeight(Resources.getSystem().displayMetrics.heightPixels.toFloat())
        return result
    }

    init {
        // todo support widescreen
        setStyleWidth(Resources.getSystem().displayMetrics.widthPixels.toFloat())
    }
}
