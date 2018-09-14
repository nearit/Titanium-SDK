/**
 * Titanium-SDK
 *
 * Created by Federico Boschini
 * Copyright (c) 2018 NearIT. All rights reserved.
 */

#import "TiModule.h"

#import "NearITSDK.h"

@interface ComNearitSdkTitaniumModule : TiModule<NITManagerDelegate>
{
    @private
    KrollCallback *successCallback;
    KrollCallback *errorCallback;
    KrollCallback *requestDataCallback;
    
}

#if !TARGET_OS_TV
+ (void)application:(UIApplication* _Nonnull)application performFetchWithCompletionHandler:(void (^_Nonnull)(UIBackgroundFetchResult))completionHandler;
+ (void)disableDefaultRangingNotifications;
+ (BOOL)application:(UIApplication *_Nonnull)app openURL:(NSURL *_Nullable)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *_Nullable)options;
#endif

@end
