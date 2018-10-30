/**
 * This is intended as APIs showcase only. For a sample app, have a look at the Titanium-SDK-Sample included in this repo.
 */

/*
 * Import
 */
var NearIT = require('com.nearit.sdk.titanium');


/*
 * Register for push notifications AFTER requesting Notification Permission
 * - give NearIT plugin the push token
 * - let NearIT plugin know when a push notification has been received
 */
Ti.Network.registerForPushNotifications({
	success: function(token) {
		// give us the token
		NearIT.setDeviceToken(token.deviceToken);
	},
	error: function(e) {
		console.log("registerForPushNotifications", e);
	},
	callback: function(pushNotification) {
		// push received
		console.log("push callback", pushNotification);
		NearIT.didReceiveRemoteNotification(pushNotification);
	}
});

/*
 * NearIT radar start/stop
 * WARNING: you should start radar only when the user already granted location permission
 */
NearIT.startRadar();
NearIT.stopRadar();


/*
 * In-app-events
 */
NearIT.triggerInAppEvent("in_app_event_test");


/*
 * Listen for content
 */
NearIT.addEventListener(NearIT.NEARIT_EVENTS, function(event) {
	var message = event.content.message;
	var trackingInfo = event.trackingInfo;
	var content = event.content;
	switch (event.contentType) {
		case NearIT.SIMPLE:
			// it's a simple notification with no content
			break;
		case NearIT.CONTENT_NOTIFICATION:
			// handle content
			break;
		case NearIT.FEEDBACK:
			// handle feedback (see Send Feedback section)
			break;
		case NearIT.COUPON:
			// handle coupon
			break;
		case NearIT.CUSTOM_JSON:
			// handle json
			break;
		default:
			// Content type unrecognized
	}
});

/*
 * Coupon history
 */
NearIT.getCoupons({
	success: function(result) {
		// SUCCESS: you got coupon list (as json array)
		var coupons = result.items;
		for (var i = 0; i < coupons.length; i++) {
			console.log(coupons[i]);
		}
	},
	error: function(error) {
		// ERROR: failed fetching coupons
		console.log(error);
	}
});

/*
 * Notification history
 */
NearIT.getNotificationHistory({
	success: function(result) {
		// SUCCESS: you got notification history (as json array)
		var notifications = result.items;
		for (var i = 0; i < notifications.length; i++) {
			console.log(notifications[i]);
		}
	},
	error: function(error) {
		// ERROR: failed fetching notification history
		console.log(error);
	}
});


/*
 * Send Feedback
 */
var rating = 5;
var comment = "titanium comment"; // Optional
NearIT.sendFeedback({
	feedbackId: content.feedbackId,
	rating: rating,
	comment: comment,
	success: function(success) {
		// SUCCESS
		console.log("successfully sent feedback");
	},
	error: function(error) {
		// ERROR: Failed sending feedback
		console.log(error);
	}
});


/*
 * User profiling and opt-out
 */
NearIT.getProfileId({
	success: function(profileId) {
		// SUCCESS: you got the profileId
		console.log(profileId);
	},
	error: function(e) {
		// ERROR: failed fetching profileId
		console.log(e);
	}
});
    
NearIT.resetProfileId({
	success: function(newProfileId) {
		// SUCCESS: you got the NEW profileId
		console.log(newProfileId);
	},
	error: function(e) {
		// ERROR: failed fetching profileId
		console.log(e);
	}
});
    
// Set a new profileId (it must be a UUID 8-4-4-4-12)
NearIT.setProfileId('6e661aee-816d-46b9-866e-14f666fbc546');
    
// Opt-out from NearIT (WARNING: NearIT won't work anymore on this device)
NearIT.optOut({
	success: function(message) {
		console.log(message);
	},
	error: function(e) {
		console.log(e);
	}
});
    
// Set a new pair of <key, value> for the user
NearIT.setUserData({
	key: "key",
	value: "value"
});
    
// Set a new multichoice user data
NearIT.setMultiChoiceUserData({
	key: "interests",
	values: { "food": true, "drink": true, "exercise": false }
});


/*
 * Send trackings
 * Available trackings: 
 * 	NearIT.RECIPE_RECEIVED
 * 	NearIT.RECIPE_OPENED
 * 	NearIT.RECIPE_CTA_TAPPED
 * 	or any string you want to use as custom tracking
 */
NearIT.sendTracking({
	trackingInfo: trackingInfo,
	status: NearIT.RECIPE_RECEIVED,
	success: function(success) {
		console.log("successfully sent tracking");
	},
	error: function(error) {
		console.log("failed sent tracking");
	}
});