/**
 * Titanium-SDK
 *
 * Created by Federico Boschini
 * Copyright (c) 2018 NearIT. All rights reserved.
 */
 
#import "ComNearitConsts.h"

@implementation ComNearitConsts

NSString* NEARIT_NATIVE_EVENTS_TOPIC = @"NearItEvent";
NSString* NEARIT_LOCAL_EVENTS_TOPIC = @"NearItTitaniumLocalEvents";

// Event types
NSString* EVENT_TYPE_SIMPLE = @"NearIt.Events.SimpleNotification";
NSString* EVENT_TYPE_CUSTOM_JSON = @"NearIt.Events.CustomJSON";
NSString* EVENT_TYPE_COUPON = @"NearIt.Events.Coupon";
NSString* EVENT_TYPE_CONTENT = @"NearIt.Events.Content";
NSString* EVENT_TYPE_FEEDBACK = @"NearIt.Events.Feedback";

// Events content
NSString* EVENT_TYPE = @"contentType";
NSString* EVENT_TRACKING_INFO = @"trackingInfo";
NSString* EVENT_CONTENT = @"content";
NSString* EVENT_CONTENT_MESSAGE = @"message";
NSString* EVENT_CONTENT_DATA = @"data";
NSString* EVENT_CONTENT_COUPON = @"coupon";
NSString* EVENT_CONTENT_TEXT = @"text";
NSString* EVENT_CONTENT_TITLE = @"title";
NSString* EVENT_CONTENT_IMAGE = @"image";
NSString* EVENT_CONTENT_CTA = @"cta";
NSString* EVENT_CONTENT_CTA_LABEL = @"label";
NSString* EVENT_CONTENT_CTA_LINK = @"url";
NSString* EVENT_CONTENT_FEEDBACK = @"feedbackId";
NSString* EVENT_CONTENT_QUESTION = @"feedbackQuestion";
NSString* EVENT_STATUS = @"status";

// Error codes
NSString* E_SEND_FEEDBACK_ERROR = @"E_SEND_FEEDBACK_ERROR";
NSString* E_USER_PROFILE_GET_ERROR = @"E_USER_PROFILE_GET_ERROR";
NSString* E_USER_PROFILE_SET_ERROR = @"E_USER_PROFILE_SET_ERROR";
NSString* E_USER_PROFILE_RESET_ERROR = @"E_USER_PROFILE_RESET_ERROR";
NSString* E_USER_PROFILE_CREATE_ERROR = @"E_USER_PROFILE_CREATE_ERROR";
NSString* E_USER_PROFILE_DATA_ERROR = @"E_USER_PROFILE_DATA_ERROR";
NSString* E_COUPONS_RETRIEVAL_ERROR = @"E_COUPONS_RETRIEVAL_ERROR";

@end