import {PortalHost, PortalProvider} from '@gorhom/portal'
import React, {memo} from 'react'

export const BottomSheetModalProvider = memo((props) => {
  return (
    <PortalProvider>
      {props.children}
      <PortalHost name={'bottomSheetPortalHost'} />
    </PortalProvider>
  )
})
