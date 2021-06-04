#import "React/RCTViewManager.h"
#import "React/RCTUIManager.h"
#import "React/RCTLog.h"
#import "React/RCTShadowView.h"

@interface RCT_EXTERN_MODULE(BottomSheetManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(onDismiss, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(sheetSize, NSString *)
RCT_EXPORT_VIEW_PROPERTY(borderRadius, double)
RCT_EXTERN_METHOD(dismissSheet : (nonnull NSNumber *)viewTag)
@end
