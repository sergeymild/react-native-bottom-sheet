package com.reactnativebottomsheet

import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.LayoutShadowNode
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.annotations.ReactProp

class BottomSheetViewManager : ViewGroupManager<CustomSheetChildView>() {
  override fun getName(): String = "BottomSheet"
  override fun createViewInstance(reactContext: ThemedReactContext) = CustomSheetChildView(reactContext)

  override fun onDropViewInstance(view: CustomSheetChildView) {
    super.onDropViewInstance(view)
    view.onDropInstance()
  }

  override fun onAfterUpdateTransaction(view: CustomSheetChildView) {
    super.onAfterUpdateTransaction(view)
    view.showOrUpdate()
  }


  override fun getExportedCustomBubblingEventTypeConstants(): Map<String, Any> {
    return MapBuilder.builder<String, Any>()
      .put("onDismiss", MapBuilder.of<String, Any>("phasedRegistrationNames", MapBuilder.of("bubbled", "onDismiss")))
      .build()
  }

  @ReactProp(name = "sheetSize")
  fun sheetSize(view: CustomSheetChildView, size: String) {
    view.setSheetSize(size)
  }

  @ReactProp(name = "useScrollView")
  fun useScrollView(view: CustomSheetChildView, value: Boolean) {
    view.useScrollView(value)
  }

  @ReactProp(name = "cornerRadius")
  fun cornerRadius(view: CustomSheetChildView, value: Float) {
    view.setCornerRadius(value)
  }

  override fun getCommandsMap(): MutableMap<String, Int> {
    return MapBuilder.of("dismissSheet", 1)
  }

  override fun createShadowNodeInstance(): LayoutShadowNode {
    return ModalHostShadowNode()
  }

  override fun getShadowNodeClass(): Class<out LayoutShadowNode> {
    return ModalHostShadowNode::class.java
  }
}
