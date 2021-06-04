import React, {forwardRef, PropsWithChildren} from 'react'
import {requireNativeComponent} from 'react-native'

const BottomSheet = requireNativeComponent('BottomSheet')

interface BottomSheetProps {
  readonly sheetSize: string | 'dynamic' | number
  readonly onDismiss?: () => void
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
