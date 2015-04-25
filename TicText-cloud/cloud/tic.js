var TIC_CLASS_NAME = 'Tic';
var TIC_SENDER = 'sender';
var TIC_RECIPIENT = 'recipient';
var TIC_SEND_TIMESTAMP = 'sendTimestamp';
var TIC_RECEIVE_TIMESTAMP = 'receiveTimestamp';
var TIC_TIME_LIMIT = "timeLimit";
var TIC_STATUS = 'status';
var TIC_STATUS_READ = 'read';
var TIC_STATUS_EXPIRED = 'expired';
 
Parse.Cloud.beforeSave(TIC_CLASS_NAME, function(request, response) {
    Parse.Cloud.useMasterKey();
    var tic = request.object;
    if (tic.isNew()) {
        console.log("Setup ACL for new Tic, read access for sender. ");
        var senderUserId = tic.get(TIC_SENDER).id;
        var newACL = new Parse.ACL();
        newACL.setReadAccess(senderUserId, true);
        tic.setACL(newACL);
    } else {
        console.log("Existing Tic. Do nothing. ");
    }
    response.success();
});
 
Parse.Cloud.define("fetchTic", function(request, response) {
    Parse.Cloud.useMasterKey();
    var recipient = request.user;
    var fetchTimestamp = request.params.fetchTimestamp;
    var ticId = request.params.ticId;
    var ticQuery = new Parse.Query(TIC_CLASS_NAME);
    ticQuery.get(ticId, {
        success: function(tic) {
            var sendTimestamp = tic.get(TIC_SEND_TIMESTAMP);
            var timeLimit = tic.get(TIC_TIME_LIMIT);
            var expireTimestamp = new Date();
            expireTimestamp.setSeconds(sendTimestamp.getSeconds() + timeLimit);
            if (fetchTimestamp <= expireTimestamp) {
                var senderUserId = tic.get(TIC_SENDER).id;
                var recipientUserId = tic.get(TIC_RECIPIENT).id;
                var newACL = new Parse.ACL();
                newACL.setReadAccess(senderUserId, true);
                newACL.setReadAccess(recipientUserId, true);
                tic.setACL(newACL);
                tic.save({
                    receiveTimestamp: fetchTimestamp, 
                    status: TIC_STATUS_READ
                });
                response.success(tic);
            } else {
                tic.save(TIC_STATUS, TIC_STATUS_EXPIRED);
                response.error("Tic expired");
            }
        }, 
        error: function(error) {
            response.error(error);
        }
    });
});
