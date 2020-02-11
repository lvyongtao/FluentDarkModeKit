//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

#import "UIView+DarkModeKit.h"
#import "DMDynamicColor.h"

@import ObjectiveC;

@implementation UIView (DarkModeKit)

static void (*dm_original_setBackgroundColor)(UIView *, SEL, UIColor *);

static void dm_setBackgroundColor(UIView *self, SEL _cmd, UIColor *color) {
  if ([color isKindOfClass:[DMDynamicColor class]]) {
    self.dm_dynamicBackgroundColor = (DMDynamicColor *)color;
  } else {
    self.dm_dynamicBackgroundColor = nil;
  }
  dm_original_setBackgroundColor(self, _cmd, color);
}

// https://stackoverflow.com/questions/42677534/swizzling-on-properties-that-conform-to-ui-appearance-selector
+ (void)dm_swizzleSetBackgroundColor {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Method method = class_getInstanceMethod(self, @selector(setBackgroundColor:));
    dm_original_setBackgroundColor = (void *)method_getImplementation(method);
    method_setImplementation(method, (IMP)dm_setBackgroundColor);
  });
}

#pragma mark -

- (DMDynamicColor *)dm_dynamicBackgroundColor {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setDm_dynamicBackgroundColor:(DMDynamicColor *)dm_dynamicBackgroundColor {
  objc_setAssociatedObject(self,
                           @selector(dm_dynamicBackgroundColor),
                           dm_dynamicBackgroundColor,
                           OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark -

- (DMDynamicColor *)dm_dynamicTintColor {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setDm_dynamicTintColor:(DMDynamicColor *)dm_dynamicTintColor {
  objc_setAssociatedObject(self,
                           @selector(dm_dynamicTintColor),
                           dm_dynamicTintColor,
                           OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark -

- (void)dmTraitCollectionDidChange:(DMTraitCollection *)previousTraitCollection {
  for (UIView *subview in self.subviews) {
    [subview dmTraitCollectionDidChange:previousTraitCollection];
  }
  [self setNeedsLayout];
  [self setNeedsDisplay];
  [self dm_updateDynamicColors];
  [self dm_updateDynamicImages];
}

- (void)dm_updateDynamicColors {
  if (self.dm_dynamicBackgroundColor) {
    self.backgroundColor = self.dm_dynamicBackgroundColor;
  }
  if (self.dm_dynamicTintColor) {
    self.tintColor = self.dm_dynamicTintColor;
  }
}

- (void)dm_updateDynamicImages {
  // For subclasses to override.
}

@end
