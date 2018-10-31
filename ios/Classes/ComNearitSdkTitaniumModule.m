/**
 * Titanium-SDK
 *
 * Created by Federico Boschini
 * Copyright (c) 2018 NearIT. All rights reserved.
 */

#import "ComNearitSdkTitaniumModule.h"
#import "TiApp.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

#define TAG @"NearItTitanium"

#define IS_EMPTY(v) (v == nil || [v length] <= 0)

@implementation ComNearitSdkTitaniumModule {
    KrollCallback* permissionDialogClosedCallback;
    KrollCallback* locationGrantedCallback;
    KrollCallback* notificationGrantedCallback;
}

// Define Titanium constants
MAKE_SYSTEM_STR(NEARIT_EVENTS, NEARIT_NATIVE_EVENTS_TOPIC)

MAKE_SYSTEM_STR(SIMPLE, EVENT_TYPE_SIMPLE)
MAKE_SYSTEM_STR(CONTENT_NOTIFICATION, EVENT_TYPE_CONTENT)
MAKE_SYSTEM_STR(COUPON, EVENT_TYPE_COUPON)
MAKE_SYSTEM_STR(FEEDBACK, EVENT_TYPE_FEEDBACK)
MAKE_SYSTEM_STR(CUSTOM_JSON, EVENT_TYPE_CUSTOM_JSON)

MAKE_SYSTEM_STR(RECIPE_RECEIVED, NITRecipeReceived)
MAKE_SYSTEM_STR(RECIPE_OPENED, NITRecipeOpened)
MAKE_SYSTEM_STR(RECIPE_CTA_TAPPED, NITRecipeCtaTapped)

#pragma mark Internal

// This is generated for your module, please do not change it
- (id)moduleGUID
{
    return @"2945aa85-2637-42c5-98db-adf07ff203c2";
}

// This is generated for your module, please do not change it
- (NSString *)moduleId
{
    return @"com.nearit.sdk.titanium";
}

- (void)_configure
{
    [super _configure];
    @try {
        [[TiApp app] registerApplicationDelegate:self];
    }
    @catch (NSException *exception) {
        NSLog(@"!!!!!!!!![ERROR]: Your Titanium SDK version is not > 7.3.0.GA, some features won't work");
    }
}

#pragma mark Lifecycle

- (void)startup
{
    // This method is called when the module is first loaded
    // You *must* call the superclass
    [super startup];
    
    if (self != nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
        NSString* NITApiKey = [dict objectForKey:@"NearIT API Key"];

        // Pass API Key to NITManager
        if (NITApiKey) {
            [NITManager setupWithApiKey:NITApiKey];
        } else {
            NSLog(@"Could not find 'NearIT API Key' field inside of tiapp.xml. NearIT won't work!");
        }
        
        [NITManager defaultManager].delegate = self;
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        [NITManager setFrameworkName:@"titanium"];
    }
    
    DebugLog(@"[DEBUG] %@ loaded", self);
}


// MARK: INTERNAL NearIT Recipes handling

- (BOOL)handleNearITContent: (NITReactionBundle* _Nonnull) content trackingInfo: (NITTrackingInfo* _Nullable) trackingInfo
{
    NSLog(NSStringFromClass([content class]))
    if ([content isKindOfClass:[NITSimpleNotification class]]) {
        // Simple notification
        NITSimpleNotification *simple = (NITSimpleNotification*)content;
        
        [self sendEventWithContent:[ComNearitUtils bundleNITSimple:simple]
                      NITEventType:EVENT_TYPE_SIMPLE
                      trackingInfo:trackingInfo];
        
        return YES;
    } else if ([content isKindOfClass:[NITContent class]]) {
        // Notification with Content
        NITContent *nearContent = (NITContent*)content;
        
        [self sendEventWithContent:[ComNearitUtils bundleNITContent:nearContent]
                      NITEventType:EVENT_TYPE_CONTENT
                      trackingInfo:trackingInfo];
        
        return YES;
        
    } else if ([content isKindOfClass:[NITFeedback class]]) {
        // Feedback
        NITFeedback* feedback = (NITFeedback*)content;
        
        [self sendEventWithContent:[ComNearitUtils bundleNITFeedback:feedback]
                      NITEventType:EVENT_TYPE_FEEDBACK
                      trackingInfo:trackingInfo];
        
        return YES;
        
    } else if ([content isKindOfClass:[NITCoupon class]]) {
        // Coupon notification
        NITCoupon *coupon = (NITCoupon*)content;
        
        NSString* message = [coupon notificationMessage];
        if (!message) {
            message = @"";
        }
        
        NSDictionary* eventContent = @{
                                       EVENT_CONTENT_MESSAGE: message,
                                       EVENT_CONTENT_COUPON: [ComNearitUtils bundleNITCoupon:coupon]
                                       };
        
        [self sendEventWithContent:eventContent
                      NITEventType:EVENT_TYPE_COUPON
                      trackingInfo:trackingInfo];
        
        return YES;
        
    } else if ([content isKindOfClass:[NITCustomJSON class]]) {
        // Custom JSON notification
        NITCustomJSON *custom = (NITCustomJSON*)content;
        
        [self sendEventWithContent:[ComNearitUtils bundleNITCustomJSON:custom]
                      NITEventType:EVENT_TYPE_CUSTOM_JSON
                      trackingInfo:trackingInfo];
        
        return YES;
    } else {
        // unhandled content type
        NSString* message = [NSString stringWithFormat:@"unknown content type %@ trackingInfo %@", content, trackingInfo];
        NITLogW(TAG, message);
        
        return NO;
    }
}


// MARK: INTERNAL NearIT content delivered through events

- (void) sendEventWithContent:(NSDictionary* _Nonnull) content NITEventType:(NSString* _Nonnull) eventType trackingInfo:(NITTrackingInfo* _Nullable) trackingInfo
{
    
    NSString* bundledTrackingInfo = [ComNearitUtils bundleTrackingInfo:trackingInfo];
    
    NSDictionary* event = @{
                            EVENT_TYPE: eventType,
                            EVENT_CONTENT: content,
                            EVENT_TRACKING_INFO: (bundledTrackingInfo ? bundledTrackingInfo : [NSNull null])
                            };
    
    if ([self _hasListeners:NEARIT_NATIVE_EVENTS_TOPIC]) {
        NSLog(@"firing event from native..");
        [self fireEvent:NEARIT_NATIVE_EVENTS_TOPIC withObject:event];
    } else {
        NSLog(@"no listeners")
    }
}


#pragma Public APIs

// MARK: Request Permissions

- (void)requestPermissions:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
	ENSURE_UI_THREAD(requestPermissions, args);
    permissionDialogClosedCallback = [args objectForKey:@"dialogClosed"];
    NSString * explanation = [args objectForKey:@"explanation"];
    //locationGrantedCallback = [args objectForKey:@"locationGranted"];
    //notificationGrantedCallback = [args objectForKey:@"notificationGranted"];
    [[ComNearitUI sharedInstance] showPermissionsDialogWithExplanation:explanation ? explanation : nil delegate:self];
}

- (void)requestNotificationPermission:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary)
    ENSURE_UI_THREAD(requestNotificationPermission, args)
    permissionDialogClosedCallback = [args objectForKey:@"dialogClosed"];
    NSString * explanation = [args objectForKey:@"explanation"];
    [[ComNearitUI sharedInstance] showNotificationsPermissionDialogWithExplanation:explanation ? explanation : nil delegate:self];
}

- (void)requestLocationPermission:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary)
    ENSURE_UI_THREAD(requestLocationPermission, args)
    permissionDialogClosedCallback = [args objectForKey:@"dialogClosed"];
    NSString * explanation = [args objectForKey:@"explanation"];
    [[ComNearitUI sharedInstance] showLocationPermissionDialogWithExplanation:explanation ? explanation : nil delegate:self];
}

// MARK: NearIT Radar

- (void)startRadar:(id)unused
{
    [[NITManager defaultManager] start];
}

- (void)stopRadar:(id)unused
{
    [[NITManager defaultManager] stop];
}

// MARK: NearIT Coupon history

- (void)getCoupons:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    KrollCallback* errorCallback = [args objectForKey:@"error"];
    KrollCallback* successCallback = [args objectForKey:@"success"];
    
    NSMutableArray *bundledCoupons = [[NSMutableArray alloc] init];
    
    [[NITManager defaultManager] couponsWithCompletionHandler:^(NSArray<NITCoupon *> * _Nullable coupons, NSError * _Nullable error) {
        if (!error) {
            if (successCallback) {
                for(NITCoupon *c in coupons) {
                    [bundledCoupons addObject:[ComNearitUtils bundleNITCoupon:c]];
                }
                [successCallback call: @[@{ @"coupons" : bundledCoupons }] thisObject:nil];
            }
        } else {
            if (errorCallback) {
                [errorCallback call:@[@{ @"error" : error.localizedDescription }] thisObject:nil];
            }
        }
    }];
}


// MARK: NearIT Notification history

- (void)getNotificationHistory:(id)args
{
	ENSURE_SINGLE_ARG(args,NSDictionary);
	KrollCallback* errorCallback = [args objectForKey:@"error"];
    KrollCallback* successCallback = [args objectForKey:@"success"];
    
    NSMutableArray *bundledNotificationHistory = [[NSMutableArray alloc] init];
    
    [[NITManager defaultManager] historyWithCompletion:^(NSArray<NITHistoryItem *> * _Nullable items, NSError * _Nullable error) {
    		if (!error) {
    			if (successCallback) {
    				for (NITHistoryItem *item in items) {
    					[bundledNotificationHistory addObject:[ComNearitUtils bundleNITHistoryItem:item]];
    				}
    				[successCallback call: @[@{ @"items" : bundledNotificationHistory }] thisObject:nil];
    			}
    		} else {
    			if (errorCallback) {
    				[errorCallback call:@[@{ @"error" : error.localizedDescription }] thisObject:nil];
    			}
    		}
    }];
}


// MARK: Trackings

- (void)sendTracking:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    NSString* trackingInfo = [args objectForKey:@"trackingInfo"];
    NSString* status = [args objectForKey:@"status"];
    KrollCallback* errorCallback = [args objectForKey:@"error"];
    KrollCallback* successCallback = [args objectForKey:@"success"];
    
    if (IS_EMPTY(trackingInfo)) {
        if (errorCallback) {
            [errorCallback call:@[@{ @"error" : @"missing trackingInfo" }] thisObject:nil];
        }
    } else {
        NSData* trackingInfoData = [[NSData alloc] initWithBase64EncodedString:trackingInfo
                                                                       options:NSDataBase64DecodingIgnoreUnknownCharacters];
        
        NITTrackingInfo *unBundledTrackingInfo = [NSKeyedUnarchiver unarchiveObjectWithData:trackingInfoData];
        
        if (unBundledTrackingInfo) {
            [[NITManager defaultManager] sendTrackingWithTrackingInfo:unBundledTrackingInfo event:status];
            if (successCallback) {
                [successCallback call:@[@{ @"success" : @"successfully sent tracking" }] thisObject:nil];
            }
        } else {
            if (errorCallback) {
                [errorCallback call:@[@{ @"error" : @"failed to send tracking" }] thisObject:nil];
            }
        }
    }
}

// MARK: Send Feedback

- (void)sendFeedback:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    KrollCallback* successCallback = [args objectForKey:@"success"];
    KrollCallback* errorCallback = [args objectForKey:@"error"];
    NSInteger rating = [TiUtils intValue:([args objectForKey:@"rating"])];
    NSString* comment = [args objectForKey:@"comment"];
    NSString* feedbackComment = comment ? comment : @"";
    NSString* feedbackId = [args objectForKey:@"feedbackId"];
    
    NSData* feedbackData = [[NSData alloc] initWithBase64EncodedString:feedbackId
                                                               options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    NITFeedback *feedback = [NSKeyedUnarchiver unarchiveObjectWithData:feedbackData];
    
    NITFeedbackEvent *feedbackEvent = [[NITFeedbackEvent alloc] initWithFeedback:feedback
                                                                          rating:rating
                                                                         comment:comment];
    
    [[NITManager defaultManager] sendEventWithEvent:feedbackEvent
                                  completionHandler:^(NSError * _Nullable error) {
                                      if (error) {
                                          if (errorCallback) {
                                              [errorCallback call:@[@{ @"error" : error.localizedDescription }] thisObject:nil];
                                          }
                                      } else {
                                          if(successCallback) {
                                              [successCallback call:@[@{ @"success" : @"successfully sent feedback" }] thisObject: nil];
                                          }
                                      }
    }];
}

// MARK: NearIT Profiling & Opt-out

- (void)getProfileId:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    KrollCallback* successCallback = [args objectForKey:@"success"];
    KrollCallback* errorCallback = [args objectForKey:@"error"];
    
    [[NITManager defaultManager] profileIdWithCompletionHandler:^(NSString * _Nullable profileId, NSError * _Nullable error) {
        if (!error) {
            if (successCallback) {
                [successCallback call:@[profileId] thisObject:nil];
            }
        } else {
            if (errorCallback) {
                [errorCallback call:@[@{ @"error" : error.localizedDescription }] thisObject:nil];
            }
        }
    }];
}

- (void)resetProfileId:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    KrollCallback* successCallback = [args objectForKey:@"success"];
    KrollCallback* errorCallback = [args objectForKey:@"error"];
    
    [[NITManager defaultManager] resetProfileWithCompletionHandler:^(NSString * _Nullable profileId, NSError * _Nullable error) {
        if (!error) {
            if (successCallback) {
                [successCallback call:@[profileId] thisObject:nil];
            }
        } else {
            if (errorCallback) {
                [errorCallback call:@[@{ @"error" : error.localizedDescription }] thisObject:nil];
            }
        }
    }];
}

- (void)setProfileId:(id)args
{
    ENSURE_SINGLE_ARG(args,NSString);
    if (args != nil) [[NITManager defaultManager] setProfileId:args];
}

- (void)optOut:(id)args
{
    KrollCallback* successCallback = [args objectForKey:@"success"];
    KrollCallback* errorCallback = [args objectForKey:@"error"];
    
    [[NITManager defaultManager] optOutWithCompletionHandler:^(BOOL success) {
        if (success) {
            if (successCallback) {
                [successCallback call:@[@"Successfully opted-out"] thisObject:nil];
            }
        } else {
            if (errorCallback) {
                [errorCallback call:@[@{ @"error" : @"Error while opting-out. You should retry." }] thisObject:nil];
            }
        }
    }];
}

- (void)setUserData:(id)args
{
    ENSURE_DICT(args)
    NSString* key = [args objectForKey:@"key"];
    NSString* value = [args objectForKey:@"value"];
    
    [[NITManager defaultManager] setUserDataWithKey:key value:value];
}

- (void)setMultiChoiceUserData:(id)args
{
    ENSURE_DICT(args)
    NSString* key = [args objectForKey:@"key"];
    NSDictionary* values = [args objectForKey:@"values"];
    
    [[NITManager defaultManager] setUserDataWithKey:key multiValue:values];
}


// MARK: NearIT in-app trigger

- (void)triggerInAppEvent:(id)args
{
    ENSURE_SINGLE_ARG(args,NSString);
    if (args != nil) [[NITManager defaultManager] triggerInAppEventWithKey:args];
}


// MARK: Configure Push Notifications

- (void)setDeviceToken:(NSString *) deviceToken
{
	[[NITManager defaultManager] setDeviceTokenWithData:deviceToken];
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSMutableDictionary* data = [[NSMutableDictionary alloc] initWithDictionary: userInfo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NEARIT_LOCAL_EVENTS_TOPIC
                                                        object:self
                                                      userInfo:@{@"data": [userInfo objectForKey:@"data"]}];
}


// MARK: NearIT Customization

+ (void)disableDefaultRangingNotifications:(id)unused
{
    NSLog(@"Disabling default ranging notifications")
    [NITManager defaultManager].showForegroundNotification = false;
}


// MARK: Show NearIT contents

- (void)showContent:(id)args
{
	NSDictionary *  arg = args[0];
	NSString * eventType = [arg objectForKey:EVENT_TYPE];
	NSDictionary * content = [arg objectForKey:EVENT_CONTENT];
	NSString * bundledTrackingInfo = [arg objectForKey:EVENT_TRACKING_INFO];
	NITTrackingInfo* trackingInfo = [ComNearitUtils unbundleTrackingInfo:bundledTrackingInfo];
	
	NSLog(eventType);
	
	if ([eventType isEqualToString:EVENT_TYPE_CONTENT]) {
		NITContent * nearContent = [ComNearitUtils unbundleNITContent:content];
		[[ComNearitUI sharedInstance] showContentDialogWithContent:nearContent trackingInfo:trackingInfo];
	} else if ([eventType isEqualToString:EVENT_TYPE_FEEDBACK]) {
		NITFeedback * feedback = [ComNearitUtils unbundleNITFeedback:content];
		[[ComNearitUI sharedInstance] showFeedbackDialogWithFeedback:feedback];
	} else if ([eventType isEqualToString:EVENT_TYPE_COUPON]) {
		NITCoupon * coupon = [ComNearitUtils unbundleNITCoupon:content];
		[[ComNearitUI sharedInstance] showCouponDialogWithCoupon:coupon];
	}
}


// MARK: Show NearIT NotificationHistory

- (void)showNotificationHistory:(id)unused
{
	ENSURE_UI_THREAD(showNotificationHistory, unused);
	
	[[ComNearitUI sharedInstance] showNotificationHistory];
}

// MARK: Show NearIT Coupon List

- (void)showCouponList:(id)unused
{
	ENSURE_UI_THREAD(showCouponList, unused);
	
	[[ComNearitUI sharedInstance] showCouponList];
}


#pragma NearIT Manager Delegate

- (void)manager:(NITManager * _Nonnull)manager eventFailureWithError:(NSError * _Nonnull)error {
    // handle errors (only for information purpose)
    NSLog(error.localizedDescription)
}

- (void)manager:(NITManager * _Nonnull)manager eventWithContent:(id _Nonnull)content trackingInfo:(NITTrackingInfo * _Nonnull)trackingInfo {
    NSLog(@"eventwithcontent")
    [self handleNearITContent:content trackingInfo:trackingInfo];
}

#pragma UNUserNotificationCenter Delegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    BOOL isNearNotification = [[NITManager defaultManager] processRecipeWithResponse:response completion:^(NITReactionBundle * _Nullable content, NITTrackingInfo * _Nullable trackingInfo, NSError * _Nullable error) {
        if (content) {
            [self handleNearITContent:content trackingInfo: trackingInfo];
        }
    }];
}

#pragma App Delegate

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [[NITManager defaultManager] application:app openURL:url options:options];
}

- (void)application:(UIApplication* _Nonnull)application performFetchWithCompletionHandler:(void (^_Nonnull)(UIBackgroundFetchResult))completionHandler {
    [[NITManager defaultManager] application:application performFetchWithCompletionHandler:^(UIBackgroundFetchResult result) {
        completionHandler(result);
    }];
}

#pragma NITPermissionsViewControllerDelegate

- (void)dialogClosedWithLocationGranted:(BOOL)locationGranted notificationsGranted:(BOOL)notificationsGranted {
    if (permissionDialogClosedCallback != nil) {
        [permissionDialogClosedCallback call:@[ @{ @"location": [NSNumber numberWithBool:locationGranted], @"notifications": [NSNumber numberWithBool:notificationsGranted] } ] thisObject:nil];
    }
}

- (void)locationGranted:(BOOL)granted {
    if (locationGrantedCallback != nil) {
        [locationGrantedCallback call:@[] thisObject:nil];
    }
}

- (void)notificationsGranted:(BOOL)granted {
    if (notificationGrantedCallback != nil) {
        [notificationGrantedCallback call:@[] thisObject:nil];
    }
}
@end
