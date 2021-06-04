package com.reactnativebottomsheet

import android.content.Context
import android.graphics.Color
import android.view.View
import android.view.ViewGroup
import androidx.core.view.isVisible
import com.facebook.react.uimanager.DisplayMetricsHolder
import com.facebook.react.views.view.ReactViewBackgroundDrawable
import com.facebook.react.views.view.ReactViewGroup
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.google.android.material.card.MaterialCardView

internal class SheetDialog(context: Context, theme: Int) : CustomBottomSheetDialog(context, theme) {

    private val minBarHeightWithHandle = 2 * 28 * DisplayMetricsHolder.getScreenDisplayMetrics().density

    private var startState: Int = BottomSheetBehavior.STATE_EXPANDED
    private lateinit var handleBar: MaterialCardView
    private lateinit var handle: View

    private val showHandleBar: Boolean
        get() = handleRadius > 0
    var peekHeight: Int = 0
        set(value) {
            field = value
            setup()
        }
    var showHandle: Boolean = true
        set(value) {
            field = value
            setupHandle()
        }
    var handleRadius: Float = 12F
        set(value) {
            field = value
            setupHandle()
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
        setupHandle()
    }

    private fun setupHandle() {
        containerView.also {
            handleBar = it.findViewById(R.id.dialog_bottom_sheet_handle_bar)
            handle = it.findViewById(R.id.dialog_bottom_sheet_handle)
        }
        if (showHandleBar) {
            val radius = handleRadius * DisplayMetricsHolder.getScreenDisplayMetrics().density
            val barHeight = if (showHandle) {
                (radius * 2).coerceAtLeast(minBarHeightWithHandle)
            } else {
                radius * 2
            }.toInt()
            contentContainer?.findFirstReactNativeView()?.background?.also {
                if (it is ReactViewBackgroundDrawable) handleBar.setCardBackgroundColor(it.color)
            }
            handleBar.radius = handleRadius * DisplayMetricsHolder.getScreenDisplayMetrics().density
            (handleBar.layoutParams as ViewGroup.MarginLayoutParams).also {
                if (it.height != barHeight) {
                    it.height = barHeight
                    it.bottomMargin = -(barHeight / 2)
                    handleBar.requestLayout()
                }
            }
            handleBar.isVisible = showHandleBar
            handle.isVisible = showHandle
        }
    }

    private fun ViewGroup.findFirstReactNativeView(): View? {
        if (this is ReactViewGroup) return this
        var child: ViewGroup? = this
        do {
            child = child?.getChildAt(0) as? ViewGroup
        } while (child != null && child !is ReactViewGroup)
        return child
    }
}
