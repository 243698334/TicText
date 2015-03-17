var USER_FACEBOOK_ID = 'facebookId';

var USER_PRIVATE_DATA_CLASS_NAME = 'UserPrivateData';
var USER_PRIVATE_DATA_FRIENDS = 'friends';
var USER_PRIVATE_DATA_FACEBOOK_FRIENDS = 'facebookFriends';

Parse.Cloud.beforeSave(USER_PRIVATE_DATA_CLASS_NAME, function(request, response) {
    Parse.Cloud.useMasterKey();
    var userPrivateData = request.object;
    if (userPrivateData.isNew() || userPrivateData.dirty(USER_PRIVATE_DATA_FACEBOOK_FRIENDS)) {
        console.log("Update friend list.");
        var facebookFriends = userPrivateData.get(USER_PRIVATE_DATA_FACEBOOK_FRIENDS);
        var friendsQuery = new Parse.Query(Parse.User);
        friendsQuery.containedIn(USER_FACEBOOK_ID, facebookFriends);
        friendsQuery.find({
            success: function(results) {
                var friends = results;
                userPrivateData.set(USER_PRIVATE_DATA_FRIENDS, friends);
                response.success();
            },
            error: function(error) {
                response.error(error);
            }
        });
    } else {
        response.success();
    }
});
