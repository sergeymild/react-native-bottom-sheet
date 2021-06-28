package com.reactnativebottomsheet

import android.content.Context
import android.graphics.Outline
import android.util.TypedValue
import android.view.View
import android.view.ViewOutlineProvider
import com.facebook.react.uimanager.DisplayMetricsHolder
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.google.android.material.card.MaterialCardView

fun createTopLeftCornerRadiusOutlineProvider(radius: Float): ViewOutlineProvider {
  return object: ViewOutlineProvider() {
    override fun getOutline(view: View, outline: Outline) {
      val left = 0
      val top = 0
      val right = view.width
      val bottom = view.height
      val cornerRadius = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, radius, view.resources.displayMetrics).toInt()

      outline.setRoundRect(left, top, right, bottom + cornerRadius, cornerRadius.toFloat())
    }
  }
}

internal class SheetDialog(context: Context, theme: Int) : CustomBottomSheetDialog(context, theme) {

  private var startState: Int = BottomSheetBehavior.STATE_EXPANDED

  var peekHeight: Int = 0
    set(value) {
      field = value
      setup()
    }

  var cornerRadius: Float = 12F
    set(value) {
      field = value
      contentContainer?.outlineProvider = createTopLeftCornerRadiusOutlineProvider(value)
      contentContainer?.clipToOutline = true
    }

  override fun setContentView(view: View) {
    super.setContentView(view)
    setup()
  }

  public override fun onStart() {
    super.onStart()
    behavior.state = startState
  }

  override fun getDialogLayout(): Int = R.layout.dialog_bottom_sheet

  override fun getContentContainerId(): Int = R.id.dialog_bottom_sheet_content_container

  private fun setup() {
    if (peekHeight > 0) {
      behavior.skipCollapsed = false
      behavior.setPeekHeight(peekHeight, true)
      startState = BottomSheetBehavior.STATE_COLLAPSED
    } else {
      behavior.setPeekHeight(10, true)
      behavior.skipCollapsed = true
      startState = BottomSheetBehavior.STATE_EXPANDED
    }
  }
}
