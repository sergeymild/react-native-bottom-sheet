import React, {Component, useEffect} from 'react'
import {Image, Text, TouchableOpacity, View} from 'react-native'

import {Model} from './App'

interface Props {
  readonly item: Model
  readonly index: number
}

const I: React.FC<{url: string; index: number}> = (props) => {
  useEffect(() => {
    return () => {
      console.log('⚡️ unmount', props.index)
    }
  }, [])

  return (
    <Image
      source={{uri: props.url, cache: 'reload'}}
      resizeMode={'cover'}
      resizeMethod={'resize'}
      style={{
        resizeMode: 'cover',
        width: '100%',
        height: 100,
      }}
    />
  )
}

export class Item extends Component<Props, {text: string}> {
  constructor(props: Props) {
    super(props)
    const {item} = this.props
    this.state = {text: `some title ${item.title} `}
  }

  render() {
    const {item} = this.props

    return (
      <View
        style={{
          overflow: 'hidden',
          backgroundColor: 'orange',
        }}>
        <TouchableOpacity
          style={{flexDirection: 'column'}}
          onPress={() => {
            console.log('press', item.id)
          }}>
          <View style={{height: 1, backgroundColor: 'aqua'}} />
          <I
            url={`http://loremflickr.com/320/240?t=${item.id}`}
            index={item.id}
          />
        </TouchableOpacity>

        <Text
          style={{
            // width: '100%',
            color: 'rgba(18, 18, 18, 1)',
            fontSize: 14,
            marginTop: 8,
            textAlign: 'right',
          }}>
          {/*some title {item.title}*/}
          {/*some title {item.title}{' '}*/}
          {this.state.text}
          {(this.props.index % 2 === 0 &&
            '\n\n\n\n\n\n\n123 asdadadadadadadadadadasdasdad') ||
            's'}
        </Text>

        <Text
          style={{
            color: 'rgba(18, 18, 18, 1)',
            fontSize: 14,
            position: 'absolute',
            bottom: 0,
          }}>
          400#
        </Text>
      </View>
    )
  }
}
