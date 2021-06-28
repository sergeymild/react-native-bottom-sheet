import {requireNativeComponent, UIManager} from 'react-native'

const VIEW_MANAGER_NAME = 'BottomSheet'

export const BottomSheetViewManager = requireNativeComponent(VIEW_MANAGER_NAME)

export function getViewManagerConfig(viewManagerName = VIEW_MANAGER_NAME) {
  return UIManager.getViewManagerConfig(viewManagerName)
}
