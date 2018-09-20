// This is a test harness for your module
// You should do something interesting in this harness
// to test out the module and to provide instructions
// to users on how to use it by example.

// open a single window
var win = Ti.UI.createWindow({
	backgroundColor:'white'
});
var label = Ti.UI.createLabel();
win.add(label);
win.open();

// TODO: write your module tests here
var NearIT = require('com.nearit.sdk.titanium');
Ti.API.info("module is => " + NearIT);


/*
 * NearIT radar
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
		// ERROR: FAILED SENDING FEEDBACK
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