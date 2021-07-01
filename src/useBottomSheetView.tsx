import React, {createRef, PropsWithChildren, PureComponent} from 'react'
import ReactNative, {StyleSheet, UIManager} from 'react-native'

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

  readonly applyBottomSafeArea?: boolean
}

export type PublicBottomSheetProps = PropsWithChildren<BottomSheetProps>

export type UseBottomSheet = UseBottomSheetView

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

  private _onDismiss = () => this.setState({isVisible: false})

  render() {
    if (!this.state.isVisible) return null

    const count = React.Children.count(this.props.children)
    if (React.Children.count(this.props.children) !== 1) {
      throw new Error(`There must be only one child, passed: ${count}`)
    }

    return (
      <BottomSheetViewManager
        //@ts-ignore
        style={[StyleSheet.absoluteFill]}
        sheetSize={this.props.sheetSize?.toString()}
        cornerRadius={this.props.cornerRadius}
        useScrollView={this.props.useScrollView}
        applyBottomSafeArea={this.props.applyBottomSafeArea ?? true}
        ref={this.sheetRef}
        onDismiss={this._onDismiss}
        isVisible={this.state.isVisible}
        children={React.Children.only(this.props.children)}
      />
    )
  }
}
