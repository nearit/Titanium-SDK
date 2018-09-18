/**
 * Create a new `Ti.UI.TabGroup`.
 */
var tabGroup = Ti.UI.createTabGroup();

var NearIT = require('com.nearit.sdk.titanium');
Ti.API.info("module is => " + NearIT);

// 	NOT WORKING WHEN SDK < 7.0.0
var TiApp = require('Titanium/TiApp');
var UIApplicationDelegate = require('UIKit').UIApplicationDelegate;


var TiAppApplicationDelegate = Hyperloop.defineClass('TiAppApplicationDelegate', 'NSObject', 'UIApplicationDelegate');

TiAppApplicationDelegate.addMethod({
	selector: 'application:didFinishLaunchingWithOptions:',
	instance: true,
	returnType: 'BOOL',
	arguments: [
		'UIApplication',
		'NSDictionary'
	],
	callback: function(application, options) {
		if (this.didFinishLaunchingWithOptions) {
			return this.didFinishLaunchingWithOptions(application, options);
		}
		return true;
	}
});

var applicationDelegate = new TiAppApplicationDelegate();
 
// Called when the application finished launching. Initialize SDK's here for example
applicationDelegate.didFinishLaunchingWithOptions = function(application, options) {
	Ti.API.info('Hey there!');
	return true;
};
 
TiApp.app().registerApplicationDelegate(applicationDelegate);

// Monitor notifications received while app is in the background
Ti.App.iOS.addEventListener('localnotificationaction', function(e) {
  if (e.category === 'DOWNLOAD_CONTENT' && e.identifier === 'ACCEPT_IDENTIFIER') {
    Ti.API.warn('(Use case: Start a background download');
  } else if (e.category === 'DOWNLOAD_CONTENT' && e.identifier === 'RESPOND_IDENTIFIER') {
    Ti.API.warn('Response: ' + e.typedText); // Note: Test this by adding a label, because it logs in the background
  }

  // Reset the badge value
  if (e.badge > 0) {
    Ti.UI.iOS.appBadge = 0;
  }
  Ti.API.warn('event: localnotificationaction');
  // If the notification was dismissed, "e.identifier" will return "com.apple.UNNotifcationDismissActionIdentifier" for iOS 10+
  //statusLabel.setText('Action (identifier):' + e.identifier)
});

// Monitor notifications received while app is in the foreground
Ti.App.iOS.addEventListener('notification', function(e) {
  Ti.API.warn('event: notification');
});

Ti.App.iOS.addEventListener('remotenotificationaction', function(e) {
  Ti.API.warn('event: push notification');
});

// REGISTER FOR PUSH NOTIFICATIONS and give us push token
Ti.Network.registerForPushNotifications({
	success: function(token) {
		NearIT.registerForPushNotifications(token.deviceToken);
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

// SET MINIMUM BACKGROUND FETCH INTERVAL
Ti.App.iOS.setMinimumBackgroundFetchInterval(7200);

tabGroup.addTab(createTab1());
tabGroup.addTab(createTabProfiling());
tabGroup.open();

function createTab1() {
    var win = Ti.UI.createWindow({
        title: "Tab 1",
        backgroundColor: '#fff'
    });
    
    var button = Ti.UI.createButton({
    		title: "Start Radar",
    		top: 10
    });
    
    var requestLocation = Ti.UI.createButton({
    		title: "Request location permission",
    		top: 50
    });
    
    var requestNotif = Ti.UI.createButton({
    		title: "Request notification permission",
    		top: 90
    });
    
    button.addEventListener("click", function() {
    		NearIT.startRadar();
    });
    
    requestLocation.addEventListener('click', function() {
    		Ti.Geolocation.requestLocationPermissions(Ti.Geolocation.AUTHORIZATION_ALWAYS, function(e) {
    			console.log(e);
    		});
    });
    
    requestNotif.addEventListener('click', function() {
    		Ti.App.iOS.registerUserNotificationSettings({
    			types: [Ti.App.iOS.USER_NOTIFICATION_TYPE_ALERT, Ti.App.iOS.USER_NOTIFICATION_TYPE_BADGE , Ti.App.iOS.USER_NOTIFICATION_TYPE_SOUND]
    		});
    });

    win.add(button);
    win.add(requestLocation);
    win.add(requestNotif);

    var tab = Ti.UI.createTab({
        title: "Tab 1",
        window: win
    });

    return tab;
}

function createTabProfiling() {
    var win = Ti.UI.createWindow({
        title: "User Profiling",
        backgroundColor: '#fff'
    });
    
    var getProfileIdButton = Ti.UI.createButton({
    		title: "Get ProfileId",
    		top: 10
    });
    
    var resetProfileIdButton = Ti.UI.createButton({
    		title: "Reset ProfileId",
    		top: 50
    });
    
    var setProfileIdButton = Ti.UI.createButton({
    		title: "Set ProfileId",
    		top: 90
    });
    
    var optOutButton = Ti.UI.createButton({
    		title: "OptOut",
    		top: 130
    });
    
    var singleDataButton = Ti.UI.createButton({
    		title: "Set single user data",
    		top: 170
    });
    
    var multiDataButton = Ti.UI.createButton({
    		title: "Set multichoice user data",
    		top: 210
    });
    
    getProfileIdButton.addEventListener('click', function(e) {
    		NearIT.getProfileId({
			callback: profileIdCallback
		});
    });
    
    resetProfileIdButton.addEventListener('click', function(e) {
    		NearIT.resetProfileId({
    			callback: profileIdCallback
    		});
    });
    
    setProfileIdButton.addEventListener('click', function(e) {
    		NearIT.setProfileId("6e661aee-816d-46b9-866e-14f666fbc546");
    });
    
    optOutButton.addEventListener('click', function(e) {
    		NearIT.optOut({
    			success: function(message) {
    				console.log(message);
    			},
    			error: function(e) {
    				console.log(e);
    			}
    		});
    });
    
    singleDataButton.addEventListener('click', function(e) {
    		NearIT.setUserData({
			key: "chiave",
			value: "valore"
    		});
    });
    
    multiDataButton.addEventListener('click', function(e) {
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
        title: "User Profiling",
        window: win
    });

    return tab;
}

function profileIdCallback(profileId) {
	console.log(profileId);
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
		Ti.API.info('ACS Login Results for environment `'+env+'`:');
		Ti.API.info(result);
	}
	if (result && result.success && result.users && result.users.length){
		Ti.App.fireEvent('login.success',result.users[0],env);
	} else {
		Ti.App.fireEvent('login.failed',result,env);
	}
});

})();

