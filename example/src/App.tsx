import * as React from 'react'
import {useCallback, useMemo, useRef, useState} from 'react'
import {
  Dimensions,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native'
import {DataSource, RecyclerView} from 'react-native-recycler'

import {BottomSheetModal, BottomSheetModalProvider} from '../../src'
import {calculateItemWidth} from './layout.utils'
import { Item } from "./Item";

export interface Model {
  id: number
  title: string
}

function newItem(i: number): Model {
  return {
    id: i,
    title: `title: ${i}`,
  }
}

const data = Array(15)
  .fill('')
  .map((_, i) => newItem(i))

export default function App() {
  const first = useRef<BottomSheetModal>(null)
  const [text, setText] = useState('dynamic')
  const [loadingMore, setLoadingMore] = useState(false)
  const [dataSource] = useState(
    () => new DataSource<Model>(data, (item) => item.id.toString()),
  )

  const header = useMemo(() => {
    console.log('------ memo header')
    return (
      <View style={{backgroundColor: 'orange', height: 140, width: '100%'}}>
        <Text>Header</Text>
      </View>
    )
  }, [])

  const footer = useMemo(
    () => (
      <View style={{backgroundColor: 'orange', height: 140, width: '100%'}}>
        <Text>Footer</Text>
      </View>
    ),
    [],
  )

  let isHorizontal = false
  const result = calculateItemWidth(
    isHorizontal ? 1 : 2,
    8,
    Dimensions.get('window').width,
  )
  const onEndReachedThreshold = 300
  const inBottomSheet = true
  const configs = {
    horizontal: {
      isHorizontal: isHorizontal,
      recyclerHeight: 200 + result.spacing * 2,
      itemStyle: {
        width: 200,
        height: 100,
        overflow: 'hidden',
        maxHeight: 100,
        backgroundColor: 'purple',
      },
      header: undefined,
      footer: undefined,
    },
    vertical: {
      isHorizontal: isHorizontal,
      recyclerHeight: undefined,
      itemStyle: {
        width: result.itemWidth,
        height: undefined,
        backgroundColor: 'orange',
      },
      header: inBottomSheet ? undefined : header,
      footer: inBottomSheet ? undefined : loadingMore ? footer : undefined,
    },
  }
  const config = isHorizontal ? configs.horizontal : configs.vertical
  const showRefresh = true
  // const config = configs.horizontal;

  const renderItem = useCallback(
    (item: Model, index: number): React.ReactElement => {
      return <Item item={item} index={index} />
    },
    [],
  )

  const list = (
    <RecyclerView<Model>
      height={config.recyclerHeight}
      // @ts-ignore
      listItemStyle={(_model) => {
        return config.itemStyle
      }}
      initialProps={{
        spacing: result.spacing,
        onEndReachedThreshold: onEndReachedThreshold,
        horizontal: config.isHorizontal,
      }}
      header={config.header}
      footer={config.footer}
      dataSource={dataSource}
      renderItem={renderItem}
      onRefreshCall={undefined}
      refreshing={false}
    />
  )

  return (
    // <BottomSheetModalProvider>
    //   <View style={styles.container}>
    //     <TouchableOpacity
    //       style={{marginTop: 100, backgroundColor: 'red'}}
    //       onPress={() => {
    //         first.current?.present()
    //       }}>
    //       <Text>{text}</Text>
    //     </TouchableOpacity>
    //
    //     <View style={styles.box}>
    //       <BottomSheetModal
    //         ref={first}
    //         onDismiss={() => console.log('ds0-dsa-dsa0ds-dsa-sda')}
    //         useScrollView={true}
    //         applyBottomSafeArea={true}>
    //         {list}
    //       </BottomSheetModal>
    //     </View>
    //   </View>
    // </BottomSheetModalProvider>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    borderRadius: 20,
    marginVertical: 20,
  },
})
