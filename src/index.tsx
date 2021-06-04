import {requireNativeComponent, ViewStyle} from 'react-native'

type BottomSheetProps = {
  color: string
  style: ViewStyle
}

export const BottomSheetViewManager =
  requireNativeComponent<BottomSheetProps>('BottomSheetView')

export default BottomSheetViewManager
