USER_FACEBOOK_ID = 'facebookID';
USER_FRIENDS = 'friends';
USER_FACEBOOK_FRIENDS = 'facebookFriends';

Parse.Cloud.beforeSave(Parse.User, function(request, response) {
    Parse.Cloud.useMasterKey();
    var user = request.object;
    var facebookFriends = user.get(USER_FACEBOOK_FRIENDS);
    var friendsQuery = new Parse.Query(Parse.User);
    friendsQuery.containedIn(USER_FACEBOOK_ID, facebookFriends);
    friendsQuery.find({
        success: function(results) {
            var friends = results;
            user.set(USER_FRIENDS, friends);
            response.success();
        },
        error: function(error) {
            response.error(error);
        }
    });
});
