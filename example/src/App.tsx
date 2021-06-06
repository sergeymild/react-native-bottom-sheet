import * as React from 'react'
import {useRef, useState} from 'react'
import {StyleSheet, Text, TouchableOpacity, View} from 'react-native'
import type {UseBottomSheet} from 'react-native-bottom-sheet'
import {UseBottomSheetView} from 'react-native-bottom-sheet'

export default function App() {
  const first = useRef<UseBottomSheet>(null)
  const second = useRef<UseBottomSheet>(null)

  const [text, setText] = useState('dynamic')

  // useEffect(() => {
  //   setTimeout(() => {
  //     SecondBottomSheet.openBottomSheet()
  //     setText('Press2')
  //   }, 3000)
  // }, [])

  return (
    <>
      <View style={styles.container}>
        <TouchableOpacity
          style={{marginTop: 100, backgroundColor: 'red'}}
          onPress={() => {
            first.current?.present()
          }}>
          <Text>{text}</Text>
        </TouchableOpacity>

        <UseBottomSheetView ref={first} sheetSize={'dynamic'} cornerRadius={20}>
          <View style={{backgroundColor: 'yellow', padding: 16, paddingTop: 0}}>
            <TouchableOpacity onPress={() => setText('20%')}>
              <Text>
                Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eius
                incidunt ipsam iste provident sequi sit soluta vero voluptatibus
                voluptatum? Debitis dicta facilis fugit in quibusdam repellendus
                temporibus ullam, vero vitae.
              </Text>
              <Text>
                Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eius
                incidunt ipsam iste provident sequi sit soluta vero voluptatibus
                voluptatum? Debitis dicta facilis fugit in quibusdam repellendus
                temporibus ullam, vero vitae.
              </Text>
              <Text>
                Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eius
                incidunt ipsam iste provident sequi sit soluta vero voluptatibus
                voluptatum? Debitis dicta facilis fugit in quibusdam repellendus
                temporibus ullam, vero vitae.
              </Text>
              <Text>
                Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eius
                incidunt ipsam iste provident sequi sit soluta vero voluptatibus
                voluptatum? Debitis dicta facilis fugit in quibusdam repellendus
                temporibus ullam, vero vitae.
              </Text>
              <Text>
                Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eius
                incidunt ipsam iste provident sequi sit soluta vero voluptatibus
                voluptatum? Debitis dicta facilis fugit in quibusdam repellendus
                temporibus ullam, vero vitae.
              </Text>
              <Text>Last</Text>
            </TouchableOpacity>
          </View>
        </UseBottomSheetView>

        <UseBottomSheetView ref={second} sheetSize={'dynamic'}>
          <View style={{backgroundColor: 'yellow'}}>
            <Text
              onLayout={(e) => console.log('---', e.nativeEvent.layout.height)}>
              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eius
              incidunt ipsam iste provident sequi sit soluta vero voluptatibus
            </Text>
          </View>
        </UseBottomSheetView>
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
