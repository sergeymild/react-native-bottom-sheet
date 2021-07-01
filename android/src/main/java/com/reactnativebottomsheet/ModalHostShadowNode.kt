/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
package com.reactnativebottomsheet

import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.LayoutShadowNode

internal class ModalHostShadowNode(private val context: ReactContext) : LayoutShadowNode() {
//    override fun calculateLayoutOnChildren(): MutableIterable<ReactShadowNode<ReactShadowNode<*>>> {
//        val result = super.calculateLayoutOnChildren()
//        setStyleHeight(Resources.getSystem().displayMetrics.heightPixels.toFloat())
//        return result
//    }

//    init {
//        // todo support widescreen
////        setStyleWidth(Resources.getSystem().displayMetrics.widthPixels.toFloat())
//        val reactRootTag = ReactUpdateHelper.getReactRootTag(context)
//        val parentNode: ReactShadowNode<ReactShadowNode<*>> = ReactUpdateHelper.getUiImplementation(context).resolveShadowNode(reactRootTag)!!
//    }

//    override fun getScreenWidth(): Int {
//        println("🔦 Width: ${super.getScreenWidth()}")
//        return super.getScreenWidth()
//    }
//
//    override fun getScreenHeight(): Int {
//        println("🔦 Height: ${super.getScreenHeight()}")
//        return super.getScreenHeight()
//    }
}
