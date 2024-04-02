/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RNDateTimePicker.h"

#import <React/RCTUtils.h>
#import <React/UIView+React.h>

@interface RNDateTimePicker ()

@property (nonatomic, copy) RCTBubblingEventBlock onChange;
@property (nonatomic, copy) RCTBubblingEventBlock onPickerDismiss;
@property (nonatomic, assign) NSInteger reactMinuteInterval;
@end

@implementation RNDateTimePicker

- (instancetype)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    #ifndef RCT_NEW_ARCH_ENABLED
      // somehow, with Fabric, the callbacks are executed here as well as in RNDateTimePickerComponentView
      // so do not register it with Fabric, to avoid potential problems
      [self addTarget:self action:@selector(didChange)
               forControlEvents:UIControlEventValueChanged];
      [self addTarget:self action:@selector(onDismiss:) forControlEvents:UIControlEventEditingDidEnd];
    #endif

    _reactMinuteInterval = 1;
  }
  return self;
}

RCT_NOT_IMPLEMENTED(- (instancetype)initWithCoder:(NSCoder *)aDecoder)

- (void)didChange
{
  if (_onChange) {
    _onChange(@{ @"timestamp": @(self.date.timeIntervalSince1970 * 1000.0), @"utcOffset": @([self.timeZone secondsFromGMTForDate:self.date] / 60 )});
  }
}

- (void)onDismiss:(RNDateTimePicker *)sender
{
  if (_onPickerDismiss) {
    _onPickerDismiss(@{});
  }
}
- (UILabel *)valueLabel {
    return [self recursiveFindLabelInView:self];
}

- (UILabel *)recursiveFindLabelInView:(UIView *)view {
    if ([view isKindOfClass:[UILabel class]]) {
        return (UILabel *)view;
    }
    
    for (UIView *subview in view.subviews) {
        UILabel *label = [self recursiveFindLabelInView:subview];
        if (label) {
            return label;
        }
    }
    
    return nil;
}
- (void)setDatePickerMode:(UIDatePickerMode)datePickerMode
{
  [super setDatePickerMode:datePickerMode];
  // We need to set minuteInterval after setting datePickerMode, otherwise minuteInterval is invalid in time mode.
  self.minuteInterval = _reactMinuteInterval;
}

- (void)setMinuteInterval:(NSInteger)minuteInterval
{
  [super setMinuteInterval:minuteInterval];
  _reactMinuteInterval = minuteInterval;
}

- (void)setDate:(NSDate *)date {
    // Need to avoid the case where values coming back through the bridge trigger a new valueChanged event
    if (![self.date isEqualToDate:date]) {
        [super setDate:date animated:NO];
    }
}

- (void)setCustomFont:(UIFont *)customFont
{
    _customFont = customFont;
    [self updateLabelsFont];
}

- (void)setCustomFontSize:(CGFloat)customFontSize
{
    _customFontSize = customFontSize;
    [self updateLabelsFont];
}

- (void)updateLabelsFont
{
    if (self.customFont) {
        UIFont *fontWithSize = [self.customFont fontWithSize:self.customFontSize ?: self.customFont.pointSize];
        [self recursivelySetFont:self toFont:fontWithSize];
    }
}

- (void)recursivelySetFont:(UIView *)view toFont:(UIFont *)font
{
    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        label.font = font;
    }

    for (UIView *subview in view.subviews) {
        [self recursivelySetFont:subview toFont:font];
    }
}

@end
