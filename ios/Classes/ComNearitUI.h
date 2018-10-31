/**
 * Titanium-SDK
 *
 * Created by Federico Boschini
 * Copyright (c) 2018 NearIT. All rights reserved.
 */


#import "NearITSDK.h"

#import <WebKit/WebKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import <NearUIBinding/NearUIBinding-Swift.h>


@interface ComNearitUI

- (void)showContentDialogWithContent:(NITContent * _Nonnull)content trackingInfo:(NITTrackingInfo * _Nonnull)trackingInfo;
- (void)showFeedbackDialogWithFeedback:(NITFeedback * _Nonnull)feedback;
- (void)showCouponDialogWithCoupon:(NITCoupon * _Nonnull)coupon;
- (void)showNotificationHistory;
- (void)showCouponList;

@end
