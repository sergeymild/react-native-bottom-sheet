package com.reactnativebottomsheet

import android.view.ViewGroup
import com.facebook.react.ReactRootView
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.LayoutShadowNode
import com.facebook.react.uimanager.UIImplementation
import com.facebook.react.uimanager.UIManagerModule
import com.facebook.react.uimanager.UIViewOperationQueue
import java.lang.reflect.Method

object ReactUpdateHelper {
    private var _uiManager: UIManagerModule? = null
    private var _uiImplementation: UIImplementation? = null
    private var _operationsQueue: UIViewOperationQueue? = null
    private var _dispatchViewUpdateMethod: Method? = null

    fun getUiManager(c: ReactContext): UIManagerModule {
        _uiManager?.let { return it }
        val manager = c.getNativeModule<UIManagerModule>(UIManagerModule::class.java)
        _uiManager = manager
        return manager
    }

    fun getUiImplementation(c: ReactContext): UIImplementation {
        _uiImplementation?.let { return it }
        val uiManager = getUiManager(c)
        val obj = uiManager::class.java.getDeclaredField("mUIImplementation").let { f ->
            f.isAccessible = true
            f.get(uiManager) as UIImplementation
        }
        _uiImplementation = obj
        return obj
    }

    fun getOperationsQueue(c: ReactContext): UIViewOperationQueue {
        _operationsQueue?.let { return it }
        val uiImplementation = getUiImplementation(c)
        val obj = uiImplementation::class.java.getDeclaredField("mOperationsQueue").let { f ->
            f.isAccessible = true
            f.get(uiImplementation) as UIViewOperationQueue
        }
        _operationsQueue = obj
        return obj
    }

    fun dispatchViewUpdate(c: ReactContext) {
        val uiImplementation = getUiImplementation(c)
        if (_dispatchViewUpdateMethod == null) {
            val obj = uiImplementation::class.java.getDeclaredMethod(
                "dispatchViewUpdates",
                Int::class.java
            )
            obj.isAccessible = true
            _dispatchViewUpdateMethod = obj
        }
        _dispatchViewUpdateMethod?.also {
            c.runOnNativeModulesQueueThread {
                it.invoke(uiImplementation, -1)
            }
        }
    }

    fun getReactRootView(context: ReactContext): ReactRootView {
        val activity = context.currentActivity!!
        val contentView = activity.window.findViewById<ViewGroup>(android.R.id.content)
        return contentView.getChildAt(0) as ReactRootView
    }

    fun getReactRootTag(context: ReactContext) = getReactRootView(context).rootViewTag
}

fun LayoutShadowNode.updateReactLayout(index: Int, height: Int) {
    try {
        // Check view is exists
        ReactUpdateHelper.getUiManager(themedContext).resolveView(reactTag)

        ReactUpdateHelper
            .getOperationsQueue(themedContext)
//            .enqueueUpdateLayout(parent!!.reactTag, reactTag, 0, 0, 0, 0)
            .enqueueUpdateLayout(rootTag, reactTag, 0, 0, 0, height)
        ReactUpdateHelper.dispatchViewUpdate(themedContext)
        println("🔦 ${index} updateReactLayout success")
    } catch (e: Exception) {
        println("🔦 ${index} updateReactLayout ERROR" + e.message)
        /* no-op */
    }
}
