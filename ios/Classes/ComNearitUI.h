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

@interface ComNearitUI: NSObject

+ (ComNearitUI*)sharedInstance;

- (void)showContentDialogWithContent:(NITContent * _Nonnull)content trackingInfo:(NITTrackingInfo * _Nonnull)trackingInfo;
- (void)showFeedbackDialogWithFeedback:(NITFeedback * _Nonnull)feedback;
- (void)showCouponDialogWithCoupon:(NITCoupon * _Nonnull)coupon;
- (void)showNotificationHistory;
- (void)showCouponList;
- (void)showPermissionsDialogWithExplanation:(NSString * _Nullable)explanation delegate:(id<NITPermissionsViewControllerDelegate> _Nonnull)delegate;
- (void)showNotificationsPermissionDialogWithExplanation:(NSString * _Nullable)explanation delegate:(id<NITPermissionsViewControllerDelegate> _Nonnull)delegate;
- (void)showLocationPermissionDialogWithExplanation:(NSString * _Nullable)explanation delegate:(id<NITPermissionsViewControllerDelegate> _Nonnull)delegate;

@end
