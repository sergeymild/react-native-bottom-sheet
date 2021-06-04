import * as React from 'react'
import {useEffect, useState} from 'react'
import {StyleSheet, Text, TouchableOpacity, View} from 'react-native'

import {useBottomSheetView} from '../../src/useBottomSheetView'

export default function App() {
  const FirstBottomSheet = useBottomSheetView()
  const SecondBottomSheet = useBottomSheetView()

  const [text, setText] = useState('Press')

  useEffect(() => {
    // setTimeout(() => {
    //   SecondBottomSheet.openBottomSheet()
    //   setText('Press2')
    // }, 7000)
  }, [])

  return (
    <>
      <View style={styles.container}>
        <TouchableOpacity
          style={{marginTop: 100, backgroundColor: 'red'}}
          onPress={() => {
            FirstBottomSheet.openBottomSheet()
          }}>
          <Text>{text}</Text>
        </TouchableOpacity>

        <FirstBottomSheet.BottomSheet sheetSize={'dynamic'}>
          <View style={{backgroundColor: 'red'}}>
            <Text
              onLayout={(e) => console.log('---', e.nativeEvent.layout.height)}>
              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eius
              incidunt ipsam iste provident sequi sit soluta vero voluptatibus
              voluptatum? Debitis dicta facilis fugit in quibusdam repellendus
              temporibus ullam, vero vitae.
            </Text>
          </View>
        </FirstBottomSheet.BottomSheet>

        <SecondBottomSheet.BottomSheet sheetSize={'dynamic'}>
          <View style={{backgroundColor: 'yellow'}}>
            <Text
              onLayout={(e) => console.log('---', e.nativeEvent.layout.height)}>
              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eius
              incidunt ipsam iste provident sequi sit soluta vero voluptatibus
            </Text>
          </View>
        </SecondBottomSheet.BottomSheet>
      </View>
    </>
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
    marginVertical: 20,
  },
})
