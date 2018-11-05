/**
 * Titanium-SDK
 *
 * Created by Federico Boschini
 * Copyright (c) 2018 NearIT. All rights reserved.
 */

#import "ComNearitUtils.h"

#define TAG @"NearItTitaniumUtils"

@implementation ComNearitUtils

- (NITCoupon*)unbundleNITCoupon:(NSDictionary* _Nonnull)bundledCoupon
{
	NITCoupon* coupon = [[NITCoupon alloc] init];
	coupon.couponDescription = [bundledCoupon objectForKey:@"description"];
	coupon.value = [bundledCoupon objectForKey:@"value"];
	coupon.expiresAt = [bundledCoupon objectForKey:@"expiresAt"];
	coupon.redeemableFrom = [bundledCoupon objectForKey:@"redeemableFrom"];
	coupon.icon = [self unbundleNITImage:[bundledCoupon objectForKey:@"image"]];
    NSMutableArray* claimsArray = [NSMutableArray array];
    NITClaim* claim = [[NITClaim alloc] init];
    claim.serialNumber = [bundledCoupon objectForKey:@"serial"];
    claim.claimedAt = [bundledCoupon objectForKey:@"claimedAt"];
    claim.redeemedAt = [bundledCoupon objectForKey:@"redeemedAt"];
    claim.recipeId = [bundledCoupon objectForKey:@"recipeId"];
    claim.coupon = coupon;
    [claimsArray addObject:claim];
    NSArray* claims = [NSArray arrayWithArray:claimsArray];
    coupon.claims = claims;
	return coupon;
}

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
        [couponDictionary setObject:(coupon.claims[0].serialNumber ? coupon.claims[0].serialNumber : [NSNull null]) forKey:@"serial"];
        [couponDictionary setObject:(coupon.claims[0].claimedAt ? coupon.claims[0].claimedAt : [NSNull null]) forKey:@"claimedAt"];
        [couponDictionary setObject:(coupon.claims[0].redeemedAt ? coupon.claims[0].redeemedAt : [NSNull null]) forKey:@"redeemedAt"];
        [couponDictionary setObject:(coupon.claims[0].recipeId ? coupon.claims[0].recipeId : [NSNull null]) forKey:@"recipeId"];
    }
    
    if (coupon.icon) {
        if (coupon.icon.url || coupon.icon.smallSizeURL) {
            [couponDictionary setObject:[self bundleNITImage:coupon.icon] forKey:@"image"];
        }
    }
    
    NSData* couponData = [NSKeyedArchiver archivedDataWithRootObject:coupon];
    NSString* couponB64 = [couponData base64EncodedStringWithOptions:0];
    [couponDictionary setObject:couponB64 forKey:@"couponData"];
    
    return couponDictionary;
}

- (NSDictionary*)bundleNITHistoryItem:(NITHistoryItem* _Nonnull) item
{
	NSMutableDictionary* historyDictionary = [[NSMutableDictionary alloc] init];
	
	NSNumber *read = [NSNumber numberWithBool:item.read];
	NSNumber *timestamp = [NSNumber numberWithDouble:item.timestamp];
	NSString *bundledTrackingInfo = [self bundleTrackingInfo:item.trackingInfo];
	
	[historyDictionary setObject:read forKey:@"read"];
	[historyDictionary setObject:timestamp forKey:@"timestamp"];
	[historyDictionary setObject:(bundledTrackingInfo ? bundledTrackingInfo : [NSNull null]) forKey:@"trackingInfo"];
	
	if ([item.reactionBundle isKindOfClass:[NITSimpleNotification class]]) {
	
		[historyDictionary setObject:EVENT_TYPE_SIMPLE forKey:@"type"];
		
		NITSimpleNotification *nearSimple = (NITSimpleNotification*)item.reactionBundle;
		NSDictionary* content = [self bundleNITSimple:nearSimple];
		[historyDictionary setObject:content forKey:@"notificationContent"];
		
	} else if ([item.reactionBundle isKindOfClass:[NITContent class]]) {
		
		[historyDictionary setObject:EVENT_TYPE_CONTENT forKey:@"type"];
		
		NITContent *nearContent = (NITContent*)item.reactionBundle;
		NSDictionary* content = [self bundleNITContent:nearContent];
		[historyDictionary setObject:content forKey:@"notificationContent"];
		
	} else if ([item.reactionBundle isKindOfClass:[NITFeedback class]]) {
	
		[historyDictionary setObject:EVENT_TYPE_FEEDBACK forKey:@"type"];
		
		NITFeedback* nearFeedback = (NITFeedback*)item.reactionBundle;
		NSDictionary* feedback = [self bundleNITFeedback:nearFeedback];
		[historyDictionary setObject:feedback forKey:@"notificationContent"];
		
	} else if ([item.reactionBundle isKindOfClass:[NITCoupon class]]) {
	
		[historyDictionary setObject:EVENT_TYPE_COUPON forKey:@"type"];
		
		
	} else if ([item.reactionBundle isKindOfClass:[NITCustomJSON class]]) {
	
		[historyDictionary setObject:EVENT_TYPE_CUSTOM_JSON forKey:@"type"];
		
		NITCustomJSON *nearCustom = (NITCustomJSON*)item.reactionBundle;
		NSDictionary* custom = [self bundleNITCustomJSON:nearCustom];
		[historyDictionary setObject:custom forKey:@"notificationContent"];
	}
	
	return historyDictionary;
}

- (NSDictionary*)bundleNITSimple:(NITSimpleNotification * _Nonnull) simple
{
	NSString* message = [simple notificationMessage];
    if (!message) {
        message = @"";
    }
    
    NSDictionary* bundledSimple = @{
					EVENT_CONTENT_MESSAGE: message};
	
	return bundledSimple;
}

- (NITContent*)unbundleNITContent:(NSDictionary * _Nonnull)bundledContent
{
	NITContent* content = [[NITContent alloc] init];
	content.title = [bundledContent objectForKey:EVENT_CONTENT_TITLE];
	content.content = [bundledContent objectForKey:EVENT_CONTENT_TEXT];
	content.images = @[[self unbundleNITImage: [bundledContent objectForKey:EVENT_CONTENT_IMAGE]]];
	content.internalLink = [bundledContent objectForKey:EVENT_CONTENT_CTA];
	return content;
}

- (NSDictionary*)bundleNITContent:(NITContent * _Nonnull) content
{
	NSString* message = [content notificationMessage];
    if (!message) {
        message = @"";
    }
	
	NSString* title = [content title];
    if (!title) {
        title = @"";
    }
    
    NSString* text = [content content];
    if (!text) {
        text = @"";
    }
    
    id image;
    if (content.image) {
        image = [self bundleNITImage:content.image];
    } else {
        image = [NSNull null];
    }
    
    id cta;
    if (content.link) {
        cta = [self bundleNITContentLink:content.link];
    } else {
        cta = [NSNull null];
    }
    
    NSDictionary* bundledContent = @{
					EVENT_CONTENT_MESSAGE:message,
					EVENT_CONTENT_TITLE:title,
					EVENT_CONTENT_TEXT:text,
					EVENT_CONTENT_IMAGE:image,
					EVENT_CONTENT_CTA:cta};
                                   
  	return bundledContent;
}

- (NITFeedback*)unbundleNITFeedback:(NSDictionary * _Nonnull) bundledFeedback
{
	NSString* feedbackId = [bundledFeedback objectForKey:EVENT_CONTENT_FEEDBACK];
    NSData* feedbackData = [[NSData alloc] initWithBase64EncodedString:feedbackId
                                                               options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    NITFeedback *feedback = [NSKeyedUnarchiver unarchiveObjectWithData:feedbackData];
    feedback.question = [bundledFeedback objectForKey:EVENT_CONTENT_QUESTION];
    return feedback;
}

- (NSDictionary*)bundleNITFeedback:(NITFeedback * _Nonnull) feedback
{
	NSString* message = [feedback notificationMessage];
    if (!message) {
        message = @"";
    }
    
    NSData* feedbackData = [NSKeyedArchiver archivedDataWithRootObject:feedback];
    NSString* feedbackB64 = [feedbackData base64EncodedStringWithOptions:0];
    
    NSDictionary* bundledFeedback = @{
    					EVENT_CONTENT_MESSAGE: message,
                    	EVENT_CONTENT_FEEDBACK: feedbackB64,
                    	EVENT_CONTENT_QUESTION: [feedback question]};
                    
   	return bundledFeedback;
}

- (NSDictionary*)bundleNITCustomJSON:(NITCustomJSON* _Nonnull) custom
{
	NSString* message = [custom notificationMessage];
    if (!message) {
        message = @"";
    }
    
    NSDictionary* customJson = @{
                       EVENT_CONTENT_MESSAGE: message,
                       EVENT_CONTENT_DATA: [custom content]};

	return customJson;
}

- (NITImage*)unbundleNITImage:(NSDictionary* _Nonnull)bundledImage
{
    NITImage* image = [[NITImage alloc] init];
    if ([bundledImage objectForKey:@"imageData"]) {
        NSData* imageData = [[NSData alloc] initWithBase64EncodedString:[bundledImage objectForKey:@"imageData"]
                                                                options:NSDataBase64DecodingIgnoreUnknownCharacters];
        image = [NSKeyedUnarchiver unarchiveObjectWithData:imageData];
    }
	return image;
}

- (NSDictionary*)bundleNITImage:(NITImage* _Nonnull)image
{
    NSData* imageData = [NSKeyedArchiver archivedDataWithRootObject:image];
    NSString* imageB64 = [imageData base64EncodedStringWithOptions:0];
    return @{
             @"imageData": imageB64,
             @"fullSize": (image.url ? [image.url absoluteString] : [NSNull null]),
             @"squareSize": (image.smallSizeURL ? [image.smallSizeURL absoluteString] : [NSNull null])
             };
}

- (NSDictionary*)bundleNITContentLink:(NITContentLink* _Nonnull)cta
{
    return @{
             @"label": cta.label,
             @"url": [cta.url absoluteString]
             };
}

- (NITTrackingInfo*)unbundleTrackingInfo:(NSString * _Nullable)bundledTrackingInfo
{
	NSData* trackingInfoData = [[NSData alloc] initWithBase64EncodedString:bundledTrackingInfo
                                                                       options:NSDataBase64DecodingIgnoreUnknownCharacters];
        
    NITTrackingInfo *trackingInfo = [NSKeyedUnarchiver unarchiveObjectWithData:trackingInfoData];
    return trackingInfo;
}

- (NSString*)bundleTrackingInfo:(NITTrackingInfo* _Nullable) trackingInfo
{
	NSString* trackingInfoB64;
    if (trackingInfo) {
        NSData* trackingInfoData = [NSKeyedArchiver archivedDataWithRootObject:trackingInfo];
        trackingInfoB64 = [trackingInfoData base64EncodedStringWithOptions:0];
    }
    
    return trackingInfoB64;
}

@end
