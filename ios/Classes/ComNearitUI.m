/**
 * Titanium-SDK
 *
 * Created by Federico Boschini
 * Copyright (c) 2018 NearIT. All rights reserved.
 */

#import "ComNearitUI.h"

#define TAG @"NearItTitaniumUI"

@implementation ComNearitUI

+ (ComNearitUI*)sharedInstance
{
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

- (void)showContentDialogWithContent:(NITContent *)content trackingInfo:(NITTrackingInfo *)trackingInfo
{
    NITContentViewController *vc = [[NITContentViewController alloc] initWithContent:content trackingInfo:trackingInfo];
    [vc show];
}

- (void)showFeedbackDialogWithFeedback:(NITFeedback *)feedback
{
    NITFeedbackViewController *vc = [[NITFeedbackViewController alloc] initWithFeedback:feedback];
    [vc show];
}

- (void)showCouponDialogWithCoupon:(NITCoupon *)coupon
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

- (void)showPermissionsDialogWithExplanation:(NSString*)explanation delegate:(id<NITPermissionsViewControllerDelegate>)delegate
{
	NITPermissionsViewController *controller = [[NITPermissionsViewController alloc] init];
	controller.delegate = delegate;
    controller.explainText = explanation;
    controller.closeText = @"Close";
	[controller show];
}

- (void)showNotificationsPermissionDialogWithExplanation:(NSString * _Nullable)explanation delegate:(id<NITPermissionsViewControllerDelegate> _Nonnull)delegate
{
    NITPermissionsViewController *controller = [[NITPermissionsViewController alloc] init];
    controller.delegate = delegate;
    controller.type = NITPermissionsTypeNotificationsOnly;
    controller.explainText = explanation;
    controller.closeText = @"Close";
    [controller show];
}

- (void)showLocationPermissionDialogWithExplanation:(NSString * _Nullable)explanation delegate:(id<NITPermissionsViewControllerDelegate> _Nonnull)delegate
{
    NITPermissionsViewController *controller = [[NITPermissionsViewController alloc] init];
    controller.delegate = delegate;
    controller.type = NITPermissionsTypeLocationOnly;
    controller.explainText = explanation;
    controller.closeText = @"Close";
    [controller show];
}

@end
