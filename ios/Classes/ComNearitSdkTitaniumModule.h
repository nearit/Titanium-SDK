/**
 * Titanium-SDK
 *
 * Created by Federico Boschini
 * Copyright (c) 2018 NearIT. All rights reserved.
 */

#import "TiModule.h"

#import "NearITSDK.h"

#import <WebKit/WebKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import <NearUIBinding/NearUIBinding-Swift.h>
#import <UserNotifications/UserNotifications.h>


@interface ComNearitSdkTitaniumModule : TiModule<NITManagerDelegate, UNUserNotificationCenterDelegate>
{
    
}

@end
