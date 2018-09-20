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

// Local Events topic (used by NotificationCenter to handle incoming notifications)
NSString* const NEARIT_LOCAL_EVENTS_TOPIC = @"NearItTitaniumLocalEvents";

// Event types
NSString* const EVENT_TYPE_SIMPLE = @"NearIt.Events.SimpleNotification";
NSString* const EVENT_TYPE_CUSTOM_JSON = @"NearIt.Events.CustomJSON";
NSString* const EVENT_TYPE_COUPON = @"NearIt.Events.Coupon";
NSString* const EVENT_TYPE_CONTENT = @"NearIt.Events.Content";
NSString* const EVENT_TYPE_FEEDBACK = @"NearIt.Events.Feedback";

// Events content
NSString* const EVENT_TYPE = @"type";
NSString* const EVENT_TRACKING_INFO = @"trackingInfo";
NSString* const EVENT_CONTENT = @"content";
NSString* const EVENT_CONTENT_MESSAGE = @"message";
NSString* const EVENT_CONTENT_DATA = @"data";
NSString* const EVENT_CONTENT_COUPON = @"coupon";
NSString* const EVENT_CONTENT_TEXT = @"text";
NSString* const EVENT_CONTENT_TITLE = @"title";
NSString* const EVENT_CONTENT_IMAGE = @"image";
NSString* const EVENT_CONTENT_CTA = @"cta";
NSString* const EVENT_CONTENT_FEEDBACK = @"feedbackId";
NSString* const EVENT_CONTENT_QUESTION = @"feedbackQuestion";
NSString* const EVENT_FROM_USER_ACTION = @"fromUserAction";
NSString* const EVENT_STATUS = @"status";

// Error codes
NSString* const E_START_RADAR_ERROR = @"E_START_RADAR_ERROR";
NSString* const E_STOP_RADAR_ERROR = @"E_STOP_RADAR_ERROR";
NSString* const E_SEND_TRACKING_ERROR = @"E_SEND_TRACKING_ERROR";
NSString* const E_SEND_FEEDBACK_ERROR = @"E_SEND_FEEDBACK_ERROR";
NSString* const E_USER_PROFILE_GET_ERROR = @"E_USER_PROFILE_GET_ERROR";
NSString* const E_USER_PROFILE_SET_ERROR = @"E_USER_PROFILE_SET_ERROR";
NSString* const E_USER_PROFILE_RESET_ERROR = @"E_USER_PROFILE_RESET_ERROR";
NSString* const E_USER_PROFILE_CREATE_ERROR = @"E_USER_PROFILE_CREATE_ERROR";
NSString* const E_USER_PROFILE_DATA_ERROR = @"E_USER_PROFILE_DATA_ERROR";
NSString* const E_COUPONS_RETRIEVAL_ERROR = @"E_COUPONS_RETRIEVAL_ERROR";
NSString* const E_OPT_OUT_ERROR = @"E_OPT_OUT_ERROR";

@implementation ComNearitSdkTitaniumModule

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
    [[TiApp app] registerApplicationDelegate:self];
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


// MARK: NearIT test devices

- (BOOL)handleNearITContent: (id _Nonnull) content trackingInfo: (NITTrackingInfo* _Nullable) trackingInfo
    return [[NITManager defaultManager] application:app openURL:url options:options];
}

+ (void)application:(UIApplication* _Nonnull)application performFetchWithCompletionHandler:(void (^_Nonnull)(UIBackgroundFetchResult))completionHandler {
    [[NITManager defaultManager] application:application performFetchWithCompletionHandler:^(UIBackgroundFetchResult result) {
        completionHandler(result);
    }];
}


// MARK: NearIT Recipes handling

{
    if ([content isKindOfClass:[NITSimpleNotification class]]) {
        // Simple notification
        NITSimpleNotification *simple = (NITSimpleNotification*)content;
        
        NSString* message = [simple notificationMessage];
        if (!message) {
            message = @"";
        }
        
        NSDictionary* eventContent = @{
                                       EVENT_CONTENT_MESSAGE: message
                                       };
        
        [self sendEventWithContent:eventContent
                      NITEventType:EVENT_TYPE_SIMPLE
                      trackingInfo:trackingInfo];
        
        return YES;
    } else if ([content isKindOfClass:[NITContent class]]) {
        // Notification with Content
        NITContent *nearContent = (NITContent*)content;
        
        NSString* message = [nearContent notificationMessage];
        if (!message) {
            message = @"";
        }
        
        NSString* title = [nearContent title];
        if (!title) {
            title = @"";
        }
        
        NSString* text = [nearContent content];
        if (!text) {
            text = @"";
        }
        
        id image;
        if (nearContent.image) {
            image = [self bundleNITImage:nearContent.image];
        } else {
            image = [NSNull null];
        }
        
        id cta;
        if (nearContent.link) {
            cta = [self bundleNITContentLink:nearContent.link];
        } else {
            cta = [NSNull null];
        }
        
        NSDictionary* eventContent = @{
                                       EVENT_CONTENT_MESSAGE:message,
                                       EVENT_CONTENT_TITLE:title,
                                       EVENT_CONTENT_TEXT:text,
                                       EVENT_CONTENT_IMAGE:image,
                                       EVENT_CONTENT_CTA:cta
                                       };
        
        [self sendEventWithContent:eventContent
                      NITEventType:EVENT_TYPE_CONTENT
                      trackingInfo:trackingInfo];
        
        return YES;
        
    } else if ([content isKindOfClass:[NITFeedback class]]) {
        // Feedback
        NITFeedback* feedback = (NITFeedback*)content;
        
        NSString* message = [feedback notificationMessage];
        if (!message) {
            message = @"";
        }
        
        NSData* feedbackData = [NSKeyedArchiver archivedDataWithRootObject:feedback];
        NSString* feedbackB64 = [feedbackData base64EncodedStringWithOptions:0];
        
        NSDictionary* eventContent = @{
                                       EVENT_CONTENT_MESSAGE: message,
                                       EVENT_CONTENT_FEEDBACK: feedbackB64,
                                       EVENT_CONTENT_QUESTION: [feedback question]
                                       };
        
        [self sendEventWithContent:eventContent
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
                                       EVENT_CONTENT_COUPON: [self bundleNITCoupon:coupon]
                                       };
        
        [self sendEventWithContent:eventContent
                      NITEventType:EVENT_TYPE_COUPON
                      trackingInfo:trackingInfo];
        
        return YES;
        
    } else if ([content isKindOfClass:[NITCustomJSON class]]) {
        // Custom JSON notification
        NITCustomJSON *custom = (NITCustomJSON*)content;
        
        NSString* message = [custom notificationMessage];
        if (!message) {
            message = @"";
        }
        
        NSDictionary* eventContent = @{
                                       EVENT_CONTENT_MESSAGE: message,
                                       EVENT_CONTENT_DATA: [custom content]
                                       };
        
        [self sendEventWithContent:eventContent
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

// MARK: INTERNAL contents handling

- (NSDictionary*)bundleNITCoupon:(NITCoupon* _Nonnull) coupon
{
    NSMutableDictionary* couponDictionary = [[NSMutableDictionary alloc] init];
    [couponDictionary setObject:(coupon.title ? coupon.title : [NSNull null])
                         forKey:@"name"];
    [couponDictionary setObject:(coupon.couponDescription ? coupon.couponDescription : [NSNull null])
                         forKey:@"description"];
    [couponDictionary setObject:(coupon.value ? coupon.value : [NSNull null])
                         forKey:@"value"];
    [couponDictionary setObject:(coupon.expiresAt ? coupon.expiresAt : [NSNull null])
                         forKey:@"expiresAt"];
    [couponDictionary setObject:(coupon.redeemableFrom ? coupon.redeemableFrom : [NSNull null])
                         forKey:@"redeemableFrom"];
    
    if (coupon.claims.count > 0) {
        [couponDictionary setObject:coupon.claims[0].serialNumber forKey:@"serial"];
        [couponDictionary setObject:coupon.claims[0].claimedAt forKey:@"claimedAt"];
        [couponDictionary setObject:(coupon.claims[0].redeemedAt ? coupon.claims[0].redeemedAt : [NSNull null]) forKey:@"redeemedAt"];
    }
    
    if (coupon.icon) {
        if (coupon.icon.url || coupon.icon.smallSizeURL) {
            [couponDictionary setObject:[self bundleNITImage:coupon.icon] forKey:@"image"];
        }
    }
    
    return couponDictionary;
}

- (NSDictionary*)bundleNITImage:(NITImage* _Nonnull) image
{
    return @{
             @"fullSize": (image.url ? [image.url absoluteString] : [NSNull null]),
             @"squareSize": (image.smallSizeURL ? [image.smallSizeURL absoluteString] : [NSNull null])
             };
}

- (NSDictionary*)bundleNITContentLink:(NITContentLink* _Nonnull) cta {
    return @{
             @"label": cta.label,
             @"url": [cta.url absoluteString]
             };
}

// MARK: INTERNAL NearIT content delivered through events

- (void) sendEventWithContent:(NSDictionary* _Nonnull) content NITEventType:(NSString* _Nonnull) eventType trackingInfo:(NITTrackingInfo* _Nullable) trackingInfo
{
    NSString* trackingInfoB64;
    if (trackingInfo) {
        NSData* trackingInfoData = [NSKeyedArchiver archivedDataWithRootObject:trackingInfo];
        trackingInfoB64 = [trackingInfoData base64EncodedStringWithOptions:0];
    }
    
    NSDictionary* event = @{
                            EVENT_TYPE: eventType,
                            EVENT_CONTENT: content,
                            EVENT_TRACKING_INFO: (trackingInfoB64 ? trackingInfoB64 : [NSNull null])
                            };
    
    if ([self _hasListeners:NEARIT_NATIVE_EVENTS_TOPIC]) {
        NSLog(@"firing event from native..");
        [self fireEvent:NEARIT_NATIVE_EVENTS_TOPIC withObject:event];
    }
}


#pragma Public APIs

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
                    [bundledCoupons addObject:[self bundleNITCoupon:c]];
                }
                [successCallback call:bundledCoupons thisObject:nil];
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
        [errorCallback call:@[@{ @"error" : @"missing trackingInfo" }] thisObject:nil];
    } else {
        NSData* trackingInfoData = [[NSData alloc] initWithBase64EncodedString:trackingInfo
                                                                       options:NSDataBase64DecodingIgnoreUnknownCharacters];
        
        NITTrackingInfo *unBundledTrackingInfo = [NSKeyedUnarchiver unarchiveObjectWithData:trackingInfoData];
        
        if (unBundledTrackingInfo) {
            [[NITManager defaultManager] sendTrackingWithTrackingInfo:unBundledTrackingInfo event:status];
            [successCallback call:@[@{ @"success" : @"successfully sent tracking" }] thisObject:nil];
        } else {
            [errorCallback call:@[@{ @"error" : @"failed to send tracking" }] thisObject:nil];
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
                                          [errorCallback call:@[@{ @"error" : error.localizedDescription }] thisObject:nil];
                                      } else {
                                          [successCallback call:@[@{ @"success" : @"successfully sent feedback" }] thisObject: nil];
                                      }
    }];
}

// MARK: NearIT Profiling & Opt-out

- (void)getProfileId:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    KrollCallback* callback = [args objectForKey:@"callback"];
    
    [[NITManager defaultManager] profileIdWithCompletionHandler:^(NSString * _Nullable profileId, NSError * _Nullable error) {
        if (callback) {
            if (!error) {
                [callback call:@[profileId] thisObject:nil];
            } else {
                [callback call:@[@{ @"error" : error.localizedDescription }] thisObject:nil];
                
            }
        }
    }];
}

- (void)resetProfileId:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    KrollCallback* callback = [args objectForKey:@"callback"];
    
    [[NITManager defaultManager] resetProfileWithCompletionHandler:^(NSString * _Nullable profileId, NSError * _Nullable error) {
        if (callback) {
            if (!error) {
                [callback call:@[profileId] thisObject:nil];
            } else {
                [callback call:@[@{ @"error" : error.localizedDescription }] thisObject:nil];
                
            }
        }
    }];
}

- (void)setProfileId:(NSString *_Nonnull)value
{
    ENSURE_TYPE(value, NSString)
    if (value != nil) [[NITManager defaultManager] setProfileId:[TiUtils stringValue:(value)]];
}

- (void)optOut:(id)args
{
    KrollCallback* successCallback = [args objectForKey:@"success"];
    KrollCallback* errorCallback = [args objectForKey:@"error"];
    
    [[NITManager defaultManager] optOutWithCompletionHandler:^(BOOL success) {
        if (success) {
            [successCallback call:@[@"Successfully opted-out"] thisObject:nil];
        } else {
            [errorCallback call:@[@{ @"error" : @"Error while opting-out. You should retry." }] thisObject:nil];
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

// MARK: NearIT Customization

- (void)disableDefaultRangingNotifications:(id)unused
{
    [NITManager defaultManager].showForegroundNotification = false;
}



#pragma NearIT Manager Delegate

- (void)manager:(NITManager * _Nonnull)manager eventFailureWithError:(NSError * _Nonnull)error {
    // handle errors (only for information purpose)
    NSLog(error.localizedDescription)
}

- (void)manager:(NITManager * _Nonnull)manager eventWithContent:(id _Nonnull)content trackingInfo:(NITTrackingInfo * _Nonnull)trackingInfo {
    NSLog(@"eventwithcontent")
    //[self handleNearITContent:content trackingInfo:trackingInfo];
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

@end
