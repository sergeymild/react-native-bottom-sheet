package com.reactnativebottomsheet

import android.content.Context
import android.view.MotionEvent
import android.view.ViewGroup
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.JSTouchDispatcher
import com.facebook.react.uimanager.RootView
import com.facebook.react.uimanager.UIManagerModule
import com.facebook.react.uimanager.events.EventDispatcher

class ClickableView(context: Context) : ViewGroup(context), RootView {

    private var mLastMeasuredWidth = 10
    private var mLastMeasuredHeight = 10
    private val mJSTouchDispatcher = JSTouchDispatcher(this)
    override fun onLayout(p0: Boolean, p1: Int, p2: Int, p3: Int, p4: Int) {}

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        // We override measure spec and use dimensions of the children. Children is a view added
        // from the adapter and always have a correct dimensions specified as they are calculated
        // and set with NativeViewHierarchyManager.
        // In case there is no view attached, we use the last measured dimensions.
        if (childCount > 0) {
            val child = getChildAt(0)
            mLastMeasuredWidth = child.measuredWidth
            mLastMeasuredHeight = child.measuredHeight
            println("||== measure " + child.measuredHeight)
            setMeasuredDimension(mLastMeasuredWidth, mLastMeasuredHeight)
        } else {
            setMeasuredDimension(mLastMeasuredWidth, mLastMeasuredHeight)
        }
    }

    override fun handleException(t: Throwable?) {
        getReactContext().handleException(RuntimeException(t))
    }

    private fun getReactContext(): ReactContext {
        return context as ReactContext
    }

    override fun onInterceptTouchEvent(event: MotionEvent?): Boolean {
        mJSTouchDispatcher.handleTouchEvent(event, getEventDispatcher())
        return super.onInterceptTouchEvent(event)
    }

    override fun onTouchEvent(event: MotionEvent?): Boolean {
        mJSTouchDispatcher.handleTouchEvent(event, getEventDispatcher())
        super.onTouchEvent(event)
        // In case when there is no children interested in handling touch event, we return true from
        // the root view in order to receive subsequent events related to that gesture
        return true
    }

    override fun onChildStartedNativeGesture(androidEvent: MotionEvent?) {
        mJSTouchDispatcher.onChildStartedNativeGesture(androidEvent, getEventDispatcher())
    }

    override fun requestDisallowInterceptTouchEvent(disallowIntercept: Boolean) {
        // No-op - override in order to still receive events to onInterceptTouchEvent
        // even when some other view disallow that
    }

    private fun getEventDispatcher(): EventDispatcher? {
        val reactContext = getReactContext()
        return reactContext.getNativeModule(UIManagerModule::class.java)!!.eventDispatcher
    }
}
