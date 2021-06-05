package com.reactnativebottomsheet

import android.annotation.TargetApi
import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.view.ViewStructure
import android.view.accessibility.AccessibilityEvent
import androidx.appcompat.app.AppCompatActivity
import androidx.core.widget.NestedScrollView
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.UiThreadUtil
import com.facebook.react.uimanager.events.RCTEventEmitter
import java.util.ArrayList

class CustomSheetChildView(context: Context) : ViewGroup(context), LifecycleEventListener {

    private val mHostView = ClickableView(context)
    private var pendingPeekHeight: String? = null
    private var pendingShowHandle: Boolean? = null
    private var pendingHandleRadius: Float? = null

    var sheet: FragmentModalBottomSheet? = null

    init {
        (context as ReactContext).addLifecycleEventListener(this)
    }

    fun setSheetSize(size: String) {
        val fragment = sheet
        if (fragment != null) {
          //throw RuntimeException("can't set peekHeight, bottomSheet already present")
            fragment.peekHeight = size
        } else {
            pendingPeekHeight = size
        }
    }

    fun setShowHandle(value: Boolean) {
        val fragment = sheet
        if (fragment != null) {
            fragment.showHandle = value
        } else {
            pendingShowHandle = value
        }
    }

    fun setCornerRadius(value: Float) {
        val fragment = sheet
        if (fragment != null) {
            fragment.handleRadius = value
        } else {
            pendingHandleRadius = value
        }
    }

    @TargetApi(23)
    override fun dispatchProvideStructure(structure: ViewStructure?) {
        mHostView.dispatchProvideStructure(structure)
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        // Do nothing as we are laid out by UIManager
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        dismiss()
    }

    override fun addView(child: View, index: Int) {
        UiThreadUtil.assertOnUiThread()
        mHostView.addView(child, index)
    }

    override fun getChildCount(): Int {
        return mHostView.childCount
    }

    override fun getChildAt(index: Int): View? {
        return mHostView.getChildAt(index)
    }

    override fun removeView(child: View?) {
        UiThreadUtil.assertOnUiThread()
        mHostView.removeView(child)
    }

    override fun removeViewAt(index: Int) {
        UiThreadUtil.assertOnUiThread()
        val child = getChildAt(index)
        mHostView.removeView(child)
    }

    override fun addChildrenForAccessibility(outChildren: ArrayList<View?>?) {
        // Explicitly override this to prevent accessibility events being passed down to children
        // Those will be handled by the mHostView which lives in the dialog
    }

    override fun dispatchPopulateAccessibilityEvent(event: AccessibilityEvent?): Boolean {
        // Explicitly override this to prevent accessibility events being passed down to children
        // Those will be handled by the mHostView which lives in the dialog
        return false
    }

    fun onDropInstance() {
        (context as ReactContext).removeLifecycleEventListener(this)
        dismiss()
    }

    private fun dismiss() {
        UiThreadUtil.assertOnUiThread()
        if (sheet != null) {
            if (sheet?.isAdded == true) sheet?.dismiss()
            val parent = mHostView.parent as? ViewGroup
            parent?.removeViewAt(0)
        }
        sheet = null
    }

    override fun onHostResume() {
        // We show the dialog again when the host resumes
        showOrUpdate()
    }

    override fun onHostPause() {
        // do nothing
    }

    override fun onHostDestroy() {
        // Drop the instance if the host is destroyed which will dismiss the dialog
        onDropInstance()
    }

    private fun getCurrentActivity(): AppCompatActivity {
        return (context as ReactContext).currentActivity as AppCompatActivity
    }

    fun showOrUpdate() {
        UiThreadUtil.assertOnUiThread()
        if (sheet == null) {
            val fragment = FragmentModalBottomSheet()
            sheet = FragmentModalBottomSheet()
            fragment.createViewCallable = { getContentView() }
            pendingPeekHeight?.also {
                fragment.peekHeight = it
                pendingPeekHeight = null
            }
            pendingShowHandle?.also {
                fragment.showHandle = it
                pendingShowHandle = null
            }
            pendingHandleRadius?.also {
                fragment.handleRadius = it
                pendingHandleRadius = null
            }
            fragment.show(getCurrentActivity().supportFragmentManager, "FragmentBottom ${System.currentTimeMillis()}")
            fragment.onDismiss = Runnable {
                (context as ReactContext).getJSModule(RCTEventEmitter::class.java)
                    .receiveEvent(id, "onDismiss", Arguments.createMap())
            }
        }
    }

    private fun getContentView(): View {
        return NestedScrollView(context as ReactContext).also {
            it.addView(mHostView)
        }
    }
}
