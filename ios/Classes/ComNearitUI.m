/**
 * Titanium-SDK
 *
 * Created by Federico Boschini
 * Copyright (c) 2018 NearIT. All rights reserved.
 */

#import "ComNearitUI"

#define TAG @"NearItTitaniumUI"

@implementation ComNearitUI

- (void)showContentDialogWithContent:(NITContent * _Nonnull)content trackingInfo:(NITTrackingInfo * _Nonnull)trackingInfo
{
    NITContentViewController *vc = [[NITContentViewController alloc] initWithContent:content trackingInfo:trackingInfo];
    [vc show];
}

- (void)showFeedbackDialogWithFeedback:(NITFeedback * _Nonnull)feedback
{
    NITFeedbackViewController *vc = [[NITFeedbackViewController alloc] initWithFeedback:feedback];
    [vc show];
}

- (void)showCouponDialogWithCoupon:(NITCoupon * _Nonnull)coupon
{
    NITCouponViewController *vc = [[NITCouponViewController alloc] initWithCoupon:coupon];
    [vc show];
}

- (void)showNotificationHistory
{
    NITNotificationHistoryViewController *historyVC = [[NITNotificationHistoryViewController alloc] init];
    [historyVC show];
}

- (void)showCouponList
{
    NITCouponListViewController *couponsVC = [[NITCouponListViewController alloc] init];
    [couponsVC show];
}

@end
