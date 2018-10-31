/**
 * Titanium-SDK
 *
 * Created by Federico Boschini
 * Copyright (c) 2018 NearIT. All rights reserved.
 */


#import "NearITSDK.h"
#import "ComNearitConsts.h"


@interface ComNearitUtils

- (NITCoupon*)unbundleNITCoupon:(NSDictionary* _Nonnull)bundledCoupon;
- (NSDictionary*)bundleNITCoupon:(NITCoupon* _Nonnull)coupon;
- (NSDictionary*)bundleNITHistoryItem:(NITHistoryItem* _Nonnull)item;
- (NSDictionary*)bundleNITSimple:(NITSimpleNotification * _Nonnull)simple;
- (NITContent*)unbundleNITContent:(NSDictionary * _Nonnull)bundledContent;
- (NSDictionary*)bundleNITContent:(NITContent * _Nonnull)content;
- (NITFeedback*)unbundleNITFeedback:(NSDictionary * _Nonnull)bundledFeedback;
- (NSDictionary*)bundleNITFeedback:(NITFeedback * _Nonnull)feedback;
- (NSDictionary*)bundleNITCustomJSON:(NITCustomJSON* _Nonnull)custom;
- (NITImage*)unbundleNITImage:(NSDictionary* _Nonnull)bundledImage;
- (NSDictionary*)bundleNITImage:(NITImage* _Nonnull)image;
- (NSDictionary*)bundleNITContentLink:(NITContentLink* _Nonnull)cta;
- (NITTrackingInfo*)unbundleTrackingInfo:(NSString * _Nullable)bundledTrackingInfo;
- (NSString*)bundleTrackingInfo:(NITTrackingInfo* _Nullable)trackingInfo;

@end
