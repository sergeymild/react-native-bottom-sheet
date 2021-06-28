import React, {createRef, PropsWithChildren, PureComponent} from 'react'
import ReactNative, {
  requireNativeComponent,
  StyleSheet,
  UIManager,
} from 'react-native'

export const BottomSheet = requireNativeComponent('BottomSheet')
const config = UIManager.getViewManagerConfig('BottomSheet')
const dismissSheetCommand = config.Commands.dismissSheet

interface State {
  readonly isVisible: boolean
}

interface BottomSheetProps {
  readonly sheetSize?: string | 'dynamic' | number
  readonly onDismiss?: () => void
  /**
   * Whenever use or not nested scrollView
   * @default true */
  readonly useScrollView?: boolean

  /** Corner radius of a top bar
   * @default 0 */
  readonly cornerRadius?: number
}

export type PublicBottomSheetProps = PropsWithChildren<BottomSheetProps>

export type UseBottomSheet = UseBottomSheetView
export class UseBottomSheetView extends PureComponent<
  PublicBottomSheetProps,
  State
> {
  private sheetRef = createRef<any>()
  constructor(props: PublicBottomSheetProps) {
    super(props)
    this.state = {
      isVisible: false,
    }
  }

  get isBottomSheetVisible(): boolean {
    return this.state.isVisible
  }

  present = () => this.setState({isVisible: true})
  dismiss = () => {
    const sheetRef = this.sheetRef.current
    if (!sheetRef) return
    //setBottomSheetVisible(false);
    const node = ReactNative.findNodeHandle(sheetRef)
    UIManager.dispatchViewManagerCommand(node, dismissSheetCommand, [])
  }

  render() {
    if (!this.state.isVisible) return null
    return (
      <BottomSheet
        //@ts-ignore
        style={[StyleSheet.absoluteFill]}
        sheetSize={this.props.sheetSize?.toString()}
        cornerRadius={this.props.cornerRadius}
        useScrollView={this.props.useScrollView}
        ref={this.sheetRef}
        onDismiss={() => this.setState({isVisible: false})}
        isVisible={this.state.isVisible}
        children={React.Children.only(this.props.children)}
      />
    )
  }
}
