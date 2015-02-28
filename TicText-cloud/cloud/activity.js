Parse.Cloud.beforeSave("Activity", function(request, response) {
    Parse.Cloud.useMasterKey();
    request.object.set('fromUser', request.user);
    var toUserId = request.object.get(toUserId);
    var toUserQuery = new Parse.Query(Parse.User);
    toUserQuery.get(toUserId, {
        success: function(object) {
            request.object.set('toUser', object);
            response.success();
        },
        error: function(object, error) {
            response.error("Invalid toUserId.");
        }
    });
});