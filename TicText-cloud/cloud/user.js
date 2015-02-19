Parse.Cloud.afterSave(Parse.User, function(request) {
	Parse.Cloud.useMasterKey();
	var user = request.object;
	console.log("Current user: ");
	console.log(user);

	if (!user.has("newUserPushNotificationSent")) {
		// Create the "newUserPushNotificationSent" attribute after the initial setup of current user.  
		console.log("Initial setup for the current user. Create newUserPushNotificationSent attribute with default value = false. ");
		user.save("newUserPushNotificationSent", false);
	} else if (user.has("newUserPushNotificationSent") && user.get("newUserPushNotificationSent")) {
		// Do nothing if the user already joined TicText and sent push notifications to his/her friends.
		console.log("Existing user. Do nothing. ");
	} else if (user.has("ticTextFriends")) {
		// Proceed with sending out push notifications, then set newUserPushNotificationSent to true.
		var userTicTextFriendsFacebookIDs = user.get("ticTextFriends");
		console.log("Facebook IDs pending push notifications: ");
		console.log(userTicTextFriendsFacebookIDs);
		for (var i = 0; i < userTicTextFriendsFacebookIDs.length; i++) {
			var currentFriendFacebookID = userTicTextFriendsFacebookIDs[i];
			console.log("Processing friend [" + currentFriendFacebookID + "]... ");
			var currentFriendQuery = new Parse.Query(Parse.User);
			currentFriendQuery.equalTo("facebookID", currentFriendFacebookID);
			currentFriendQuery.find({
				success: function(currentFriendQueryResult) {
					if (currentFriendQueryResult.length == 1) {
						var currentFriendUser = currentFriendQueryResult[0];
						console.log("Found user with Facebook ID [" + currentFriendFacebookID +"]. ");
						console.log(currentFriendUser);
						// send a push notification to let the user know
						var currentPushQuery = new Parse.Query(Parse.Installation);
						currentPushQuery.equalTo('user', currentFriendUser);
						var pushNotification = {
							alert: "One of your Facebook friends just joined TicText! ",
							t: "nf"
						};
						console.log("Push notification content: " + pushNotification);
						Parse.Push.send({
							where: currentPushQuery, 
							data: pushNotification
						}).then(function() {
							// push sent successfully
							console.log("Successfully sent a push notification for [" + currentFriendFacebookID + "]. ");
						}, function(error) {
							console.error("Push notification failed for [" + currentFriendFacebookID + "]. ");
							console.error(error);
						})
					} else {
						console.log("This friend [" + currentFriendFacebookID + "] has no TicText profile. The User table might not synced up with Facebook auth. Do nothing. ");
					}
				},
				error: function(error) {
					console.error("Error finding TicText user [" + currentFriendFacebookID + "]. ");
					console.error(error);
				}
			});
		}
		user.save("newUserPushNotificationSent", true);
	}
});