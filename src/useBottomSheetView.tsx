import React, {memo, useCallback, useRef, useState} from 'react'
import ReactNative, {UIManager} from 'react-native'

import {BottomSheetView, PublicBottomSheetProps} from './BottomSheet'

export const useBottomSheetView = () => {
  const [isBottomSheetVisible, setBottomSheetVisible] = useState(false)
  const bottomSheetRef = useRef<any>(null)
  const openBottomSheet = useCallback(() => setBottomSheetVisible(true), [])
  const closeBottomSheet = useCallback(() => {
    const sheetRef = bottomSheetRef.current
    if (!sheetRef) return
    //setBottomSheetVisible(false);
    console.log('----', ReactNative.findNodeHandle(sheetRef))
    const node = ReactNative.findNodeHandle(sheetRef)
    const config = UIManager.getViewManagerConfig('BottomSheetView')
    UIManager.dispatchViewManagerCommand(node, config.Commands.dismissSheet, [])
  }, [])

  const bottomSheet = useCallback(
    memo((p: PublicBottomSheetProps) => (
      <BottomSheetView
        sheetSize={p.sheetSize}
        ref={bottomSheetRef}
        onDismiss={() => setBottomSheetVisible(false)}
        isVisible={isBottomSheetVisible}>
        {p.children}
      </BottomSheetView>
    )),
    [bottomSheetRef, isBottomSheetVisible, setBottomSheetVisible],
  )

  return {
    isBottomSheetVisible,
    bottomSheetRef,
    closeBottomSheet: closeBottomSheet,
    openBottomSheet: openBottomSheet,
    BottomSheet: bottomSheet,
  }
}
