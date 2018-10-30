var tabGroup = Ti.UI.createTabGroup();

var NearIT = require('com.nearit.sdk.titanium');
Ti.API.info("module is => " + NearIT);


// REGISTER FOR PUSH NOTIFICATIONS and give us push token
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
 * (Just a utility)
 * WORKAROUND TO CHECK IF NOTIFICATION PERMISSION WAS GRANTED
 */ 
Ti.App.addEventListener('resumed', function(e) {
	if (Ti.Network.remoteNotificationsEnabled) {
		console.log('Notification permission granted!');
	} else {
	    console.log('Notification permission NOT granted!');
	}
});

// SET MINIMUM BACKGROUND FETCH INTERVAL
Ti.App.iOS.setMinimumBackgroundFetchInterval(7200);

// LISTEN FOR NEARIT CONTENT
NearIT.addEventListener(NearIT.NEARIT_EVENTS, function(event) {
	var message = event.content.message;
	var trackingInfo = event.trackingInfo;
	var content = event.content;
	
	// SEND CUSTOM TRACKING
	NearIT.sendTracking({
		trackingInfo: trackingInfo,
		status: "Titanium rocks",
		success: function(success) {
			console.log("successfully sent tracking");
		},
		error: function(error) {
			console.log("failed sent tracking");
		}
	});
	
	switch (event.contentType) {
		case NearIT.SIMPLE:
			console.log("simple, message:", message);
			break;
		case NearIT.CONTENT_NOTIFICATION:
			console.log("content, message:", message);
			console.log("content, title:", content.title);
			console.log("content, text:", content.text);
			console.log("content, cta:", content.cta);
			break;
		case NearIT.FEEDBACK:
			console.log("feedback, message:", message);
			console.log("feedback, question:", content.feedbackQuestion);
			console.log("feedback, id:", content.feedbackId);
			var rating = 5;
			var comment = "titanium comment";
			NearIT.sendFeedback({
				feedbackId: content.feedbackId,
				rating: rating,
	    			success: function(success) {
	    				// SUCCESS
	    				console.log("successfully sent feedback");
		    		},
		    		error: function(error) {
		    			// ERROR: FAILED SENDING FEEDBACK
		    			console.log(error);
		    		}
    			});
			break;
		case NearIT.COUPON:
			console.log("coupon, message", message);
			break;
		case NearIT.CUSTOM_JSON:
			console.log("customJSON, message", message);
			console.log("customJSON, data", content.data);
			break;
		default:
			// Content type unrecognized
	}
});

tabGroup.addTab(createTab1());
tabGroup.addTab(createTabProfiling());
tabGroup.tabsBackgroundColor = "#9f92ff";
tabGroup.barColor = "#9f92ff";
tabGroup.open();

function createTab1() {
    var win = Ti.UI.createWindow({
        backgroundColor: '#9f92ff',
        title: "Main"
    });
    
    var requestLocation = Ti.UI.createButton({
    		title: "Location permission and start radar",
    		color: '#fff',
    		top: 90
    });
    
    var requestNotif = Ti.UI.createButton({
    		title: "Notification permission",
    		color: '#fff',
    		top: 130
    });
    
    var triggerSimple = Ti.UI.createButton({
    		title: "Trigger simple",
    		color: '#fff',
    		top: 170
    });
     
    var triggerContent = Ti.UI.createButton({
    		title: "Trigger content",
    		color: '#fff',
    		top: 210
    });
     
    var triggerFeedback = Ti.UI.createButton({
    		title: "Trigger feedback",
    		color: '#fff',
    		top: 250
    });
    
    var triggerCustomJSON = Ti.UI.createButton({
    		title: "Trigger customJSON",
    		color: '#fff',
    		top: 290
    });
    
    var getCoupons = Ti.UI.createButton({
    		title: "Get coupons",
    		color: '#fff',
    		top: 330
    });
     
    var getNotificationHistory = Ti.UI.createButton({
    		title: "Get notification history",
    		color: '#fff',
    		top: 370
    });
    
    requestLocation.addEventListener('click', handleLocationPermission);
    
    requestNotif.addEventListener('click', function() {
    		// REQUEST NOTIFICATION PERMISSION
    		Ti.App.iOS.registerUserNotificationSettings({
    			types: [Ti.App.iOS.USER_NOTIFICATION_TYPE_ALERT, Ti.App.iOS.USER_NOTIFICATION_TYPE_BADGE , Ti.App.iOS.USER_NOTIFICATION_TYPE_SOUND]
    		});
    });
    
    triggerSimple.addEventListener('click', function() {
    		// TRIGGER NEARIT IN-APP EVENT
    		NearIT.triggerInAppEvent('in_app_event_test');
    });
    
    triggerContent.addEventListener('click', function() {
    		// TRIGGER NEARIT IN-APP EVENT
    		NearIT.triggerInAppEvent('content');
    });
    
    triggerFeedback.addEventListener('click', function() {
    		// TRIGGER NEARIT IN-APP EVENT
    		NearIT.triggerInAppEvent('feedback');
    });
    
    triggerCustomJSON.addEventListener('click', function() {
    		// TRIGGER NEARIT IN-APP EVENT
    		NearIT.triggerInAppEvent('json');
    });
    
    getCoupons.addEventListener('click', function() {
    		// GET NEARIT COUPONS
    		NearIT.getCoupons({
    			success: function(result) {
    				// SUCCESS: YOU GOT COUPON LIST
    				var coupons = result.coupons;
    				for (var i = 0; i < coupons.length; i++) {
    					console.log(coupons[i]);
    				}
	    		},
	    		error: function(error) {
	    			// ERROR: FAILED FETCHING COUPONS
	    			console.log(error);
	    		}
    		});
    });
    
    getNotificationHistory.addEventListener('click', function() {
    		// GET NEARIT NOTIFICATION HISTORY
    		NearIT.getNotificationHistory({
    			success: function(result) {
    				// SUCCESS: YOU GOT NOTIFICATION HISTORY
    				var notifications = result.items;
    				for (var i = 0; i < notifications.length; i++) {
    					console.log(notifications[i]);
    				}
    			},
    			error: function(error) {
    				// ERROR: FAILED FETCHING NOTIFICATION HISTORY
	    			console.log(error);
    			}
    		});
    });

    win.add(requestLocation);
    win.add(requestNotif);
    win.add(triggerSimple);
    win.add(triggerContent);
    win.add(triggerFeedback);
    win.add(triggerCustomJSON);
    win.add(getCoupons);
    win.add(getNotificationHistory);

    var tab = Ti.UI.createTab({
    		icon: "/assets/images/icon-nearit.png",
    		activeIconIsMask: true, 
    		iconIsMask: false,
    		titleColor: "#fff",
    		activeTitleColor: "#fff",
    		title: "Main",
        	window: win
    });

    return tab;
}

function createTabProfiling() {
    var win = Ti.UI.createWindow({
        backgroundColor: '#9f92ff',
        title: "User Profiling"
    });
    
    var getProfileIdButton = Ti.UI.createButton({
    		title: "Get ProfileId",
    		color: '#fff',
    		top: 90
    });
    
    var resetProfileIdButton = Ti.UI.createButton({
    		title: "Reset ProfileId",
    		color: '#fff',
    		top: 130
    });
    
    var setProfileIdButton = Ti.UI.createButton({
    		title: "Set ProfileId",
    		color: '#fff',
    		top: 170
    });
    
    var optOutButton = Ti.UI.createButton({
    		title: "OptOut",
    		color: '#fff',
    		top: 210
    });
    
    var singleDataButton = Ti.UI.createButton({
    		title: "Set single user data",
    		color: '#fff',
    		top: 250
    });
    
    var multiDataButton = Ti.UI.createButton({
    		title: "Set multichoice user data",
    		color: '#fff',
    		top: 290
    });
    
    getProfileIdButton.addEventListener('click', function() {
    		// GET NEARIT PROFILEID
    		NearIT.getProfileId({
			success: function(profileId) {
				// SUCCESS: YOU GOT THE PROFILEID
				console.log(profileId);
			},
			error: function(e) {
				// ERROR: FAILED FETCHING PROFILEID
				console.log(e);
			}
		});
    });
    
    resetProfileIdButton.addEventListener('click', function() {
    		NearIT.resetProfileId({
    			success: function(newProfileId) {
    				console.log(newProfileId);
    			},
    			error: function(e) {
    				console.log(e);
    			}
    		});
    });
    
    setProfileIdButton.addEventListener('click', function() {
    		// SET A NEW PROFILEID (it must be a UUID 8-4-4-4-12)
    		NearIT.setProfileId('6e661aee-816d-46b9-866e-14f666fbc546');
    });
    
    optOutButton.addEventListener('click', function() {
    		// OPT-OUT FROM NEARIT (WARNING: NearIT won't work anymore on this device)
    		NearIT.optOut({
    			success: function(message) {
    				console.log(message);
    			},
    			error: function(e) {
    				console.log(e);
    			}
    		});
    });
    
    singleDataButton.addEventListener('click', function() {
    		// SET A NEW PAIR <key, value> FOR THE USER
    		NearIT.setUserData({
			key: "key",
			value: "value"
    		});
    });
    
    multiDataButton.addEventListener('click', function() {
    		// SET A NEW MULTICHOICE USER DATA
		NearIT.setMultiChoiceUserData({
			key: "interests",
			values: { "food": true, "drink": true, "exercise": false }
		});
    });

    win.add(getProfileIdButton);
    win.add(resetProfileIdButton);
    win.add(setProfileIdButton);
    win.add(optOutButton);
    win.add(singleDataButton);
    win.add(multiDataButton);

    var tab = Ti.UI.createTab({
        icon: "/assets/images/who_icon.png",
        activeIconIsMask: true, 
    		iconIsMask: false,
    		titleColor: "#fff",
    		activeTitleColor: "#fff",
    		title: "User Profiling",
        window: win
    });

    return tab;
}

function handleLocationPermission() {
	var hasAlwaysPermission = Ti.Geolocation.hasLocationPermissions(Ti.Geolocation.AUTHORIZATION_ALWAYS);
	var hasWhenInUsePermission = Ti.Geolocation.hasLocationPermissions(Ti.Geolocation.AUTHORIZATION_WHEN_IN_USE);
	var hasDeniedPermission = Ti.Geolocation.hasLocationPermissions(Ti.Geolocation.AUTHORIZATION_DENIED);
	
	if (hasAlwaysPermission) {
		// Optimal place to call NearIT.startRadar()
		NearIT.startRadar();
	} else if (hasWhenInUsePermission) {
		// Still a good place to call NearIT.startRadar()
		NearIT.startRadar();
	} else {
		// Should ask for permission
		Ti.Geolocation.requestLocationPermissions(Ti.Geolocation.AUTHORIZATION_ALWAYS, function(e) {
			if (e.success) {
				// OPTIMAL PLACE TO CALL NearIT.startRadar()
				NearIT.startRadar();
			} else {
				// DO NOT start NearIT radar
				console.log(e);
			}
		});
	}
}

// added during app creation. this will automatically login to
// ACS for your application and then fire an event (see below)
// when connected or errored. if you do not use ACS in your
// application as a client, you should remove this block
(function(){
var ACS = require('ti.cloud'),
    env = Ti.App.deployType.toLowerCase() === 'production' ? 'production' : 'development',
    username = Ti.App.Properties.getString('acs-username-'+env),
    password = Ti.App.Properties.getString('acs-password-'+env);

// if not configured, just return
if (!env || !username || !password) { return; }
/**
 * Appcelerator Cloud (ACS) Admin User Login Logic
 *
 * fires login.success with the user as argument on success
 * fires login.failed with the result as argument on error
 */
ACS.Users.login({
	login:username,
	password:password,
}, function(result){
	if (env==='development') {
		// Ti.API.info('ACS Login Results for environment `'+env+'`:');
		// Ti.API.info(result);
	}
	if (result && result.success && result.users && result.users.length){
		// Ti.App.fireEvent('login.success',result.users[0],env);
	} else {
		// Ti.App.fireEvent('login.failed',result,env);
	}
});

})();

