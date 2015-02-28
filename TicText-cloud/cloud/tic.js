// Create pointers for sender and recipient in the cloud data store
Parse.Cloud.beforeSave("Tic", function(request, response) {
    Parse.Cloud.useMasterKey();
    request.object.set('sender', request.user);
    var recipientUserId = request.object.get(recipientUserId);
    var recipientQuery = new Parse.Query(Parse.User);
    recipientQuery.get(recipientUserId, {
        success: function(object) {
            request.object.set('recipient', object);
            response.success();
        },
        error: function(object, error) {
            response.error("Invalid recipientUserId.");
        }
    });
});