import * as React from 'react'
import {useRef, useState} from 'react'
import {StyleSheet, Text, TouchableOpacity, View} from 'react-native'
import {
  BottomSheetModal,
  BottomSheetModalProvider,
} from 'react-native-bottom-sheet'

export default function App() {
  const first = useRef<BottomSheetModal>(null)

  const [text, setText] = useState('dynamic')

  // useEffect(() => {
  //   setTimeout(() => {
  //     SecondBottomSheet.openBottomSheet()
  //     setText('Press2')
  //   }, 3000)
  // }, [])

  return (
    <BottomSheetModalProvider>
      <View style={styles.container}>
        <TouchableOpacity
          style={{marginTop: 100, backgroundColor: 'red'}}
          onPress={() => {
            first.current?.present()
          }}>
          <Text>{text}</Text>
        </TouchableOpacity>

        <View style={styles.box}>
          <BottomSheetModal
            ref={first}
            onDismiss={() => console.log('ds0-dsa-dsa0ds-dsa-sda')}
            useScrollView={true}
            applyBottomSafeArea={true}>
            <View style={{backgroundColor: 'red'}}>
              <Text>
                Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eius
                temporibus ullam, vero vitae. Lorem ipsum dolor sit amet,
                consectetur adipisicing elit. Eius temporibus ullam, vero vitae.
                Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eius
                temporibus ullam, vero vitae.Lorem ipsum dolor sit amet,
                consectetur adipisicing elit. Eius temporibus ullam, vero vitae.
                Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eius
                temporibus ullam, vero vitae. Lorem ipsum dolor sit amet,
                consectetur adipisicing elit. Eius temporibus ullam, vero vitae.
              </Text>
              <Text>{'            '}Last</Text>
            </View>
          </BottomSheetModal>
        </View>
      </View>
    </BottomSheetModalProvider>
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
