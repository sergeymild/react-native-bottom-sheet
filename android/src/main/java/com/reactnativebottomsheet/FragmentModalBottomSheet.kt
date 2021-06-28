package com.reactnativebottomsheet

import android.annotation.SuppressLint
import android.app.Dialog
import android.content.DialogInterface
import android.content.res.Resources
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.google.android.material.bottomsheet.BottomSheetBehavior.BottomSheetCallback
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import kotlin.math.min

private const val DYNAMIC_HEIGHT = "dynamic"

internal fun extractPeekHeight(size: String): Int {
  val screenHeight = Resources.getSystem().displayMetrics.heightPixels
  if (size == DYNAMIC_HEIGHT) return 0
  if (size.contains('%')) {
    val percent = size.trim('%').toIntOrNull() ?: return 0
    return screenHeight / 100 * min(90, percent)
  }

  return min(screenHeight * 0.9f, size.toFloatOrNull() ?: 0f).toInt()
}

class FragmentModalBottomSheet : BottomSheetDialogFragment() {

  var peekHeight: String = DYNAMIC_HEIGHT
    set(value) {
      field = value
      (dialog as SheetDialog?)?.peekHeight = extractPeekHeight(value)
    }
  var handleRadius: Float = 12F
    set(value) {
      field = value
      (dialog as SheetDialog?)?.cornerRadius = value
    }
    get() = (dialog as SheetDialog?)?.cornerRadius ?: field
  var onDismiss: Runnable? = null
  var createViewCallable: (() -> View)? = null

  private val mBottomSheetBehaviorCallback: BottomSheetCallback = object : BottomSheetCallback() {
    @SuppressLint("SwitchIntDef")
    override fun onStateChanged(bottomSheet: View, newState: Int) {
      when (newState) {
        BottomSheetBehavior.STATE_HIDDEN -> {
          dismiss()
        }
      }
    }

    override fun onSlide(bottomSheet: View, slideOffset: Float) {}
  }

  override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
    return createViewCallable!!.invoke()
  }

  override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
    val dialog = SheetDialog(requireContext(), R.style.AppBottomSheetDialog)
    dialog.peekHeight = extractPeekHeight(peekHeight)
    dialog.cornerRadius = handleRadius
    dialog.behavior.addBottomSheetCallback(mBottomSheetBehaviorCallback)
    return dialog
  }

  override fun onDismiss(dialog: DialogInterface) {
    super.onDismiss(dialog)
    onDismiss?.run()
  }
}
