import React, {createRef, PropsWithChildren, PureComponent} from 'react'
import ReactNative, { Dimensions, StyleSheet, UIManager, View } from 'react-native';

import {BottomSheetViewManager, getViewManagerConfig} from './BottomSheetNative'

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


export const getHeightFromPercent = (percent?: string | number) => {
  if (!percent) return percent
  if (typeof percent !== 'string') return percent
  if (!percent.endsWith('%')) return parseInt(percent, 10)
  const percentInt = parseInt(percent.replace('%', ''), 10)
  const height = Dimensions.get('window').height
  return height - height * ((100 - percentInt) / 100.0)
}

export class UseBottomSheetView extends PureComponent<
  PublicBottomSheetProps,
  State
> {
  private dismissSheetCommand = getViewManagerConfig().Commands.dismissSheet
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
    UIManager.dispatchViewManagerCommand(node, this.dismissSheetCommand, [])
  }

  componentDidUpdate(
    _prevProps: Readonly<PublicBottomSheetProps>,
    prevState: Readonly<State>,
  ) {
    if (prevState.isVisible && !this.state.isVisible) this.props.onDismiss?.()
  }

  render() {
    if (!this.state.isVisible) return null

    if (React.Children.count(this.props.children) !== 1) {
      throw new Error(`Only one child must be specified`)
    }

    let children = React.Children.only(this.props.children)
    if (this.props.sheetSize !== 'dynamic') {
      children = <View style={{height: getHeightFromPercent(this.props.sheetSize)}}>
        {React.Children.only(this.props.children)}
      </View>
    }

    return (
      <BottomSheetViewManager
        //@ts-ignore
        style={[StyleSheet.absoluteFill]}
        sheetSize={this.props.sheetSize?.toString()}
        cornerRadius={this.props.cornerRadius}
        useScrollView={this.props.useScrollView}
        ref={this.sheetRef}
        onDismiss={() => this.setState({isVisible: false})}
        isVisible={this.state.isVisible}
        children={children}
      />
    )
  }
}
