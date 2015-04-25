// Activity constants
var ACTIVITY_CLASS_NAME = 'Activity';
var ACTIVITY_TYPE = 'type';
var ACTIVITY_TYPE_SEND = 'send';
var ACTIVITY_TYPE_READ = 'read';
var ACTIVITY_TYPE_NEW_USER_JOIN = 'join';
var ACTIVITY_TIC = 'tic';
// Tic constants
var TIC_SENDER = 'sender';
var TIC_RECIPIENT = 'recipient';
var TIC_TIME_LIMIT = 'timeLimit';
var TIC_SEND_TIMESTAMP = 'sendTimestamp';
// User constants
var USER_DISPLAY_NAME = 'displayName';
var USER_PRIVATE_DATA = 'privateData';
var USER_PRIVATE_DATA_FRIENDS = 'friends';
// Installation constants
var INSTALLATION_USER = 'user';
 
Parse.Cloud.beforeSave(ACTIVITY_CLASS_NAME, function(request, response) {
    Parse.Cloud.useMasterKey();
    var activity = request.object;
    activity.setACL(new Parse.ACL());
    var activityType = activity.get(ACTIVITY_TYPE);
    switch(activityType) {
        case ACTIVITY_TYPE_SEND:
            response.success();
            break;
        case ACTIVITY_TYPE_READ:
            response.success();
            break;
        case ACTIVITY_TYPE_NEW_USER_JOIN:
            response.success();
            break;
        default: 
            response.error("Invalid activity type [" + activityType + "]");
    }
});
 
Parse.Cloud.afterSave(ACTIVITY_CLASS_NAME, function(request) {
    Parse.Cloud.useMasterKey();
    var activity = request.object;
    var installationQuery = new Parse.Query(Parse.Installation);
    var payload = pushNotificationPayload(request);
    var activityType = activity.get(ACTIVITY_TYPE);
    switch (activityType) {
        case ACTIVITY_TYPE_SEND:
            activity.get(ACTIVITY_TIC).fetch({
                success: function(tic) {
                    var recipient = tic.get(TIC_RECIPIENT);
                    installationQuery.equalTo(INSTALLATION_USER, recipient);
                    payload.ticId = tic.id;
                    payload.senderId = request.user.id;
                    payload.timeLimit = tic.get(TIC_TIME_LIMIT);
                    payload.sendTimestamp = tic.get(TIC_SEND_TIMESTAMP);
                    console.log("Current push notification payload: ");
                    console.log(payload);
                    Parse.Push.send({
                        where: installationQuery,
                        data: payload
                    }).then(function() {
                        // Push succeed
                        console.log("Push Notification for new Tic successfully sent.");
                    }, function(error) {
                        // Push failed
                        console.log("Push Notification for new Tic failed to sent.");
                        console.log(error);
                    });
                },
                error: function(error) {
                    console.log(error);
                    return;
                }
            });
            break;
        case ACTIVITY_TYPE_READ:
            activity.get(ACTIVITY_TIC).fetch({
                success: function(tic) {
                    var sender = tic.get(TIC_SENDER);
                    installationQuery.equalTo(INSTALLATION_USER, sender);
                    Parse.Push.send({
                        where: installationQuery,
                        data: payload
                    }).then(function() {
                        // Push succeed
                        console.log("Push Notification for read Tic successfully sent.");
                    }, function(error) {
                        // Push failed
                        console.log("Push Notification for read Tic failed to sent.");
                        console.log(error);
                    });
                },
                error: function(error) {
                    console.log(error);
                    return;
                }
            });
            break;
        case ACTIVITY_TYPE_NEW_USER_JOIN:
            var newUser = request.user;
            newUser.get(USER_PRIVATE_DATA).fetch({
                success: function(privateData) {
                    installationQuery.containedIn(INSTALLATION_USER, privateData.get(USER_PRIVATE_DATA_FRIENDS));
                    Parse.Push.send({
                        where: installationQuery,
                        data: payload
                    }).then(function() {
                        // Push succeed
                        console.log("Push Notification for new user join successfully sent.");
                    }, function(error) {
                        // Push failed
                        console.log("Push Notification for new user join failed to sent.");
                        console.log(error);
                    });
                },
                error: function(error) {
                    console.log(error);
                    return;
                }
            });
            break;
    }
});
 
var pushNotificationPayload = function(request) {
    var currentUserDisplayName = request.user.get(USER_DISPLAY_NAME);
    var activityType = request.object.get(ACTIVITY_TYPE);
    switch (activityType) {
        case ACTIVITY_TYPE_SEND:
            return {
                alert: "Someone just sent you a Tic. ", 
                badge: "Increment", 
                sound: "default", 
                type: "nt"
            }; 
        case ACTIVITY_TYPE_READ:
            return {
                alert: currentUserDisplayName + " just read the your Tic. ",
                sound: "default", 
                type: "rt"
            };
        case ACTIVITY_TYPE_NEW_USER_JOIN:
            return {
                alert: "Your Facebook friend (" + currentUserDisplayName + ") just joined TicText. ", 
                sound: "default", 
                type: "nf"
            };
        default: 
            return null;
    }
};