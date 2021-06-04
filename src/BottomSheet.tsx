import React, {forwardRef, PropsWithChildren} from 'react'
import {requireNativeComponent} from 'react-native'

const BottomSheet = requireNativeComponent('BottomSheet')

interface BottomSheetProps {
  readonly sheetSize: string | 'dynamic' | number
  readonly onDismiss?: () => void

  /**
   * To show a swipe handle on a top bar
   *   To see it a [isShowHandleBar] must be true
   * @default true */
  readonly showHandle?: boolean

  /** Corner radius of a top bar
   * @default 0 */
  readonly cornerRadius?: number
}

export type PublicBottomSheetProps = PropsWithChildren<BottomSheetProps>

export const BottomSheetView = forwardRef<
  typeof BottomSheet,
  PropsWithChildren<BottomSheetProps> & {isVisible: boolean}
>((props, ref) => {
  if (!props.isVisible) return null
  return (
    // @ts-ignore
    <BottomSheet {...props} sheetSize={props.sheetSize.toString()} ref={ref} />
  )
})
