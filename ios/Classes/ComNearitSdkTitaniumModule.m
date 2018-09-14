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
        NSLog(@"API_KEY: %@", NITApiKey);
        // Pass API Key to NITManager
        if (NITApiKey) {
            [NITManager setupWithApiKey:NITApiKey];
        } else {
            NSLog(@"Could not find 'NearIT API Key' field inside of tiapp.xml. NearIT won't work!");
        }
        
        [NITManager defaultManager].delegate = self;
        [NITManager setFrameworkName:@"titanium"];
    }
    
    DebugLog(@"[DEBUG] %@ loaded", self);
}


// MARK: NearIT test devices

+ (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [[NITManager defaultManager] application:app openURL:url options:options];
}

+ (void)application:(UIApplication* _Nonnull)application performFetchWithCompletionHandler:(void (^_Nonnull)(UIBackgroundFetchResult))completionHandler {
    [[NITManager defaultManager] application:application performFetchWithCompletionHandler:^(UIBackgroundFetchResult result) {
        completionHandler(result);
    }];
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

+ (void)disableDefaultRangingNotifications:(id)unused
{
    [NITManager defaultManager].showForegroundNotification = false;
}


#pragma NearIT Manager Delegate

- (void)manager:(NITManager * _Nonnull)manager eventFailureWithError:(NSError * _Nonnull)error {
    // handle errors (only for information purpose)
}

- (void)manager:(NITManager * _Nonnull)manager eventWithContent:(id _Nonnull)content trackingInfo:(NITTrackingInfo * _Nonnull)trackingInfo {
    // handle content
}

@end
