var TIC_CLASS_NAME = 'Tic';
var TIC_SENDER = 'sender';
var TIC_RECIPIENT = 'recipient';
var TIC_SEND_TIMESTAMP = 'sendTimestamp';
var TIC_RECEIVE_TIMESTAMP = 'receiveTimestamp';
var TIC_TIME_LIMIT = 'timeLimit';
var TIC_STATUS = 'status';
var TIC_STATUS_READ = 'read';
var TIC_STATUS_UNREAD = 'unread';
var TIC_STATUS_EXPIRED = 'expired';
var TIC_STATUS_DRAFTING = 'drafting';

var NEW_TIC_CLASS_NAME = 'NewTic';
var NEW_TIC_TIC_ID = 'ticId';
var NEW_TIC_SENDER_USER_ID = 'senderUserId';
var NEW_TIC_RECIPIENT_USER_ID = 'recipientUserId';
var NEW_TIC_SEND_TIMESTAMP = 'sendTimestamp';
var NEW_TIC_TIME_LIMIT = 'timeLimit';
var NEW_TIC_STATUS = 'status';
var NEW_TIC_STATUS_UNREAD = 'unread';
var NEW_TIC_STATUS_EXPIRED = 'expired';
 
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

Parse.Cloud.define("retrieveNewTics", function(request, response) {
    Parse.Cloud.useMasterKey();
    var recipient = request.user;
    var unreadTicsQuery = new Parse.Query(TIC_CLASS_NAME);
    unreadTicsQuery.equalTo(TIC_STATUS, TIC_STATUS_UNREAD);
    var expiredTicsQuery = new Parse.Query(TIC_CLASS_NAME);
    expiredTicsQuery.equalTo(TIC_STATUS, TIC_STATUS_EXPIRED);
    var newTicsQuery = new Parse.Query.or(unreadTicsQuery, expiredTicsQuery);
    newTicsQuery.equalTo(TIC_RECIPIENT, recipient);
    newTicsQuery.find({
        success: function(tics) {
            var results = new Array();
            for (var i = 0; i < tics.length; i++) {
                var currentTic = tics[i];
                // var currentNewTic = new Parse.Object(NEW_TIC_CLASS_NAME);
                // currentNewTic.set(NEW_TIC_TIC_ID, currentTic.id);
                // currentNewTic.set(NEW_TIC_SENDER_USER_ID, currentTic.get(TIC_SENDER).id);
                // currentNewTic.set(NEW_TIC_RECIPIENT_USER_ID, currentTic.get(TIC_RECIPIENT).id);
                // currentNewTic.set(NEW_TIC_SEND_TIMESTAMP, currentTic.get(TIC_SEND_TIMESTAMP));
                // currentNewTic.set(NEW_TIC_TIME_LIMIT, currentTic.get(TIC_TIME_LIMIT));
                // currentNewTic.set(NEW_TIC_STATUS, NEW_TIC_STATUS_UNREAD);
                // var currentNewTicACL = new Parse.ACL();
                // currentNewTicACL.setReadAccess(currentNewTic.get(NEW_TIC_RECIPIENT_USER_ID), true);
                // currentNewTic.setACL(currentNewTicACL);
                // currentNewTic.save();
                // results.push(currentNewTic);

                var currentTicEssentialInformation = new Object();
                currentTicEssentialInformation.ticId = currentTic.id;
                currentTicEssentialInformation.status = NEW_TIC_STATUS_UNREAD;
                currentTicEssentialInformation.senderUserId = currentTic.get(TIC_SENDER).id;
                currentTicEssentialInformation.recipientUserId = currentTic.get(TIC_RECIPIENT).id;
                currentTicEssentialInformation.sendTimestamp = currentTic.get(TIC_SEND_TIMESTAMP);
                currentTicEssentialInformation.timeLimit = currentTic.get(TIC_TIME_LIMIT);
                results.push(currentTicEssentialInformation);
            }
            response.success(results);
        }, 
        error: function(error) {
            response.error(error);
        }
    });
});
