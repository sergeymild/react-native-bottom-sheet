//
//  RCTModalHostShadowVie.m
//  BottomSheet
//
//  Created by Sergei Golishnikov on 04/06/2021.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "React/RCTShadowView.h"
#import "React/RCTViewManager.h"
#import "React/RCTUIManager.h"
#import "React/RCTLog.h"
#import "RCTModalHostShadowVie.h"


@implementation RCTModalHostShadowVie

- (void)insertReactSubview:(id<RCTComponent>)subview atIndex:(NSInteger)atIndex
{
  [super insertReactSubview:subview atIndex:atIndex];
}

- (void)layoutSubviewsWithContext:(RCTLayoutContext)layoutContext {
  [super layoutSubviewsWithContext:layoutContext];
  RCTShadowView *first = [self reactSubviews][0];
  CGFloat firstHeight = first.layoutMetrics.frame.size.height;
  NSLog(@"=---- size %f'", firstHeight);
  [self setSize:CGSizeMake(RCTScreenSize().width, 10000000)];
}

@end
