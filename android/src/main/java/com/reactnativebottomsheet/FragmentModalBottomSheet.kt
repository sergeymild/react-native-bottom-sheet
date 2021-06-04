package com.reactnativebottomsheet

import android.annotation.SuppressLint
import android.app.Dialog
import android.content.DialogInterface
import android.content.res.Resources
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.google.android.material.bottomsheet.BottomSheetBehavior.BottomSheetCallback
import com.google.android.material.bottomsheet.BottomSheetDialogFragment

private const val DYNAMIC_HEIGHT = "dynamic"

private fun extractPeekHeight(size: String): Int {
    if (size == DYNAMIC_HEIGHT) return 0
    if (size.contains('%')) {
        val percent = size.trim('%').toIntOrNull() ?: return 0
        return Resources.getSystem().displayMetrics.heightPixels / 100 * percent
    }
    return size.toIntOrNull() ?: 0
}

class FragmentModalBottomSheet : BottomSheetDialogFragment() {
    var showHandle: Boolean = true
        set(value) {
            field = value
            (dialog as SheetDialog?)?.showHandle = value
        }
        get() = (dialog as SheetDialog?)?.showHandle ?: field
    var peekHeight: String = DYNAMIC_HEIGHT
        set(value) {
            field = value
            (dialog as SheetDialog?)?.peekHeight = extractPeekHeight(value)
        }
    var handleRadius: Float = 0F
        set(value) {
            field = value
            (dialog as SheetDialog?)?.handleRadius = value
        }
        get() = (dialog as SheetDialog?)?.handleRadius ?: field
    var onDismiss: Runnable? = null
    var createViewCallable: (() -> View)? = null

    private val mBottomSheetBehaviorCallback: BottomSheetCallback = object : BottomSheetCallback() {
        @SuppressLint("SwitchIntDef")
        override fun onStateChanged(bottomSheet: View, newState: Int) {
            when (newState) {
                BottomSheetBehavior.STATE_HIDDEN -> {
                    Log.d("BSB", "hidden")
                    dismiss()
                }
            }
        }

        override fun onSlide(bottomSheet: View, slideOffset: Float) {
            Log.d("BSB", "sliding $slideOffset")
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return try {
            createViewCallable!!.invoke()
        } catch (e: Exception) {
            throw RuntimeException()
        }
    }

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val dialog = SheetDialog(requireContext(), R.style.AppBottomSheetDialog)
        dialog.peekHeight = extractPeekHeight(peekHeight)
        dialog.showHandle = showHandle
        dialog.handleRadius = handleRadius
        dialog.behavior.addBottomSheetCallback(mBottomSheetBehaviorCallback)
        return dialog
    }

    override fun onDismiss(dialog: DialogInterface) {
        super.onDismiss(dialog)
        if (onDismiss != null) onDismiss!!.run()
    }
}
