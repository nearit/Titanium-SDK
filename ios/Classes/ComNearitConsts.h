/**
 * Titanium-SDK
 *
 * Created by Federico Boschini
 * Copyright (c) 2018 NearIT. All rights reserved.
 */
 
@interface ComNearitConsts : NSObject

extern NSString* NEARIT_NATIVE_EVENTS_TOPIC;
extern NSString* NEARIT_LOCAL_EVENTS_TOPIC;

// Event types
extern NSString* EVENT_TYPE_SIMPLE;
extern NSString* EVENT_TYPE_CUSTOM_JSON;
extern NSString* EVENT_TYPE_COUPON;
extern NSString* EVENT_TYPE_CONTENT;
extern NSString* EVENT_TYPE_FEEDBACK;

// Events content
extern NSString* EVENT_TYPE;
extern NSString* EVENT_TRACKING_INFO;
extern NSString* EVENT_CONTENT;
extern NSString* EVENT_CONTENT_MESSAGE;
extern NSString* EVENT_CONTENT_DATA;
extern NSString* EVENT_CONTENT_COUPON;
extern NSString* EVENT_CONTENT_TEXT;
extern NSString* EVENT_CONTENT_TITLE;
extern NSString* EVENT_CONTENT_IMAGE;
extern NSString* EVENT_CONTENT_CTA;
extern NSString* EVENT_CONTENT_CTA_LABEL;
extern NSString* EVENT_CONTENT_CTA_LINK;
extern NSString* EVENT_CONTENT_FEEDBACK;
extern NSString* EVENT_CONTENT_QUESTION;
extern NSString* EVENT_STATUS;

// Error codes
extern NSString* E_SEND_FEEDBACK_ERROR;
extern NSString* E_USER_PROFILE_GET_ERROR;
extern NSString* E_USER_PROFILE_SET_ERROR;
extern NSString* E_USER_PROFILE_RESET_ERROR;
extern NSString* E_USER_PROFILE_CREATE_ERROR;
extern NSString* E_USER_PROFILE_DATA_ERROR;
extern NSString* E_COUPONS_RETRIEVAL_ERROR;

@end