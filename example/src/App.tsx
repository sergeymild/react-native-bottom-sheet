import * as React from 'react'
import {useRef, useState} from 'react'
import {StyleSheet, Text, TouchableOpacity, View} from 'react-native'
import {BottomSheetModal, BottomSheetModalType} from 'react-native-bottom-sheet'

export default function App() {
  const first = useRef<BottomSheetModalType>(null)
  const second = useRef<BottomSheetModalType>(null)

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

        <BottomSheetModal
          ref={first}
          onDismiss={() => console.log('ds0-dsa-dsa0ds-dsa-sda')}
          useScrollView={false}
          applyBottomSafeArea={true}>
          <View style={{backgroundColor: 'yellow', padding: 16, paddingTop: 0}} accessibilityLabel={'bottomSheetChild'}>
            <View>
              <Text>
                Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eius
                temporibus ullam, vero vitae.
                Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eius
                temporibus ullam, vero vitae.
                Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eius
                temporibus ullam, vero vitae.
              </Text>
              <Text>Last</Text>
            </View>
          </View>
        </BottomSheetModal>

        <BottomSheetModal ref={second} sheetSize={'dynamic'}>
          <View style={{backgroundColor: 'yellow'}}>
            <Text
              onLayout={(e) => console.log('---', e.nativeEvent.layout.height)}>
              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eius
              incidunt ipsam iste provident sequi sit soluta vero voluptatibus
            </Text>
          </View>
        </BottomSheetModal>
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
