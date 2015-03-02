// Activity constants
var ACTIVITY_CLASS_NAME = 'Activity';
var ACTIVITY_TYPE = 'type';
var ACTIVITY_TYPE_SEND = 'send';
var ACTIVITY_TYPE_FETCH = 'fetch';
var ACTIVITY_TYPE_NEW_USER_JOIN = 'join';
var ACTIVITY_TIC = 'tic';
// Tic constants
var TIC_SENDER = 'sender';
var TIC_RECIPIENT = 'recipient';
// User constants
var USER_DISPLAY_NAME = 'displayName';
var USER_FRIENDS = 'friends';
// Installation constants
var INSTALLATION_USER = 'user';

Parse.Cloud.beforeSave(ACTIVITY_CLASS_NAME, function(request, response) {
    Parse.Cloud.useMasterKey();
    var activityType = request.object.get(ACTIVITY_TYPE);
    switch(activityType) {
        case ACTIVITY_TYPE_SEND:
            response.success();
            break;
        case ACTIVITY_TYPE_FETCH:
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
    var activityType = request.object.get(ACTIVITY_TYPE);
    switch (activityType) {
        case ACTIVITY_TYPE_SEND:
            activity.get(ACTIVITY_TIC).fetch({
                success: function(object) {
                    var recipient = object.get(TIC_RECIPIENT);
                    installationQuery.equalTo(INSTALLATION_USER, recipient);
                    Parse.Push.send({
                        where: installationQuery,
                        data: payload
                    }).then(function() {
                        // Push succeed
                        console.log("Push Notification succeed. ");
                    }, function(error) {
                        // Push failed
                        console.log("Push Notification failed. ");
                        console.log(error);
                    });
                },
                error: function(error) {
                    console.log(error);
                    return;
                }
            });
            break;
        case ACTIVITY_TYPE_FETCH:
            activity.get(ACTIVITY_TIC).fetch({
                success: function(object) {
                    var sender = object.get(TIC_SENDER);
                    installationQuery.equalTo('user', sender);
                    Parse.Push.send({
                        where: installationQuery,
                        data: payload
                    }).then(function() {
                        // Push succeed
                        console.log("Push Notification succeed. ");
                    }, function(error) {
                        // Push failed
                        console.log("Push Notification failed. ");
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
            installationQuery.containedIn(INSTALLATION_USER, newUser.get(USER_FRIENDS));
            Parse.Push.send({
                where: installationQuery,
                data: payload
            }).then(function() {
                // Push succeed
                console.log("Push Notification succeed. ");
            }, function(error) {
                // Push failed
                console.log("Push Notification failed. ");
                console.log(error);
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
                t: "nt" 
            }; 
        case ACTIVITY_TYPE_FETCH:
            return {
                alert: currentUserDisplayName + "just read the your Tic. ",
                sound: "default", 
                t: "rt"
            };
        case ACTIVITY_TYPE_NEW_USER_JOIN:
            return {
                alert: "Your Facebook friend (" + currentUserDisplayName + ") just joined TicText. ", 
                sound: "default", 
                t: "nf"
            };
        default: 
            return null;
    }
}
