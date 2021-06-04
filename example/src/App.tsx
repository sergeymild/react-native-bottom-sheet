import * as React from 'react'
import {StyleSheet, Text, TouchableOpacity, View} from 'react-native'

import {useBottomSheetView} from '../../src/useBottomSheetView'

export default function App() {
  const FirstBottomSheet = useBottomSheetView()

  return (
    <>
      <View style={styles.container}>
        <TouchableOpacity
          style={{marginTop: 100, backgroundColor: 'red'}}
          onPress={() => {
            FirstBottomSheet.openBottomSheet()
          }}>
          <Text>Press</Text>
        </TouchableOpacity>
      </View>
      <FirstBottomSheet.BottomSheet sheetSize={'dynamic'}>
        <Text style={{width: 100, height: 300, backgroundColor: 'red'}}>
          Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eius
          incidunt ipsam iste provident sequi sit soluta vero voluptatibus
          voluptatum? Debitis dicta facilis fugit in quibusdam repellendus
          temporibus ullam, vero vitae.
        </Text>
      </FirstBottomSheet.BottomSheet>
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
