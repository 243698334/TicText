// Create pointers for fromUser and toUser in the cloud data store
Parse.Cloud.beforeSave("Activity", function(request, response) {
    Parse.Cloud.useMasterKey();
    if (request.user) {
        request.object.set('fromUser', request.user);
    } else {
        var fromUserId = request.object.get(fromUserId);
        var fromUserQuery = new Parse.Query(Parse.User);
        fromUserQuery.get(fromUserId, {
            success: function(object) {
                request.object.set('fromUser', object);
            },
            error: function(object, error) {
                response.error("Invalid fromUserId.");
            }
        });
    }
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