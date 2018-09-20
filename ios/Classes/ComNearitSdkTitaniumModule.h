/**
 * Titanium-SDK
 *
 * Created by Federico Boschini
 * Copyright (c) 2018 NearIT. All rights reserved.
 */

#import "TiModule.h"

#import "NearITSDK.h"
#import <UserNotifications/UserNotifications.h>


@interface ComNearitSdkTitaniumModule : TiModule<NITManagerDelegate, UNUserNotificationCenterDelegate>
{
    
}

@end
