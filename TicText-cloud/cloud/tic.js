// Create pointers for sender and recipient in the cloud data store
Parse.Cloud.beforeSave("Tic", function(request, response) {
    Parse.Cloud.useMasterKey();
    var newTic = request.object;
 
    // Set sender's User pointer
    if (request.user) {
        console.log("Sender uid = [" + newTic.get("senderUserId") + "]");
        newTic.set("sender", request.user);
    } else {
        var senderUserId = newTic.get("senderUserId");
        var senderQuery = new Parse.Query(Parse.User);
        senderQuery.get(senderUserId, {
            success: function(object) {
                newTic.set("sender", object);
            },
            error: function(object, error) {
                response.error("Invalid senderUserId.");
            }
        });
    }
 
    // Set recipient's User pointer
    var recipientUserId = newTic.get("recipientUserId");
    console.log("Recipient uid = [" + recipientUserId + "]");
    var recipientQuery = new Parse.Query(Parse.User);
    recipientQuery.get(recipientUserId, {
        success: function(object) {
            newTic.set("recipient", object);
            response.success();
        },
        error: function(object, error) {
            console.error(error);
            response.error("Invalid recipientUserId.");
        }
    });
 
});
 
Parse.Cloud.afterSave("Tic", function(request) {
    Parse.Cloud.useMasterKey();
    var tic = request.object;
 
    if (!tic.has("updatedACL")) {
        // Create the "updatedACL" attribute after the initial setup of current Tic
        console.log("Setup ACL for current Tic. ");
        var senderUserId = tic.get("senderUserId")
        var recipientUserId = tic.get("recipientUserId");
        var newACL = new Parse.ACL();
        newACL.setPublicReadAccess(false);
        newACL.setPublicWriteAccess(false);
        newACL.setReadAccess(senderUserId, true);
        newACL.setReadAccess(recipientUserId, true);
        newACL.setWriteAccess(senderUserId, true);
        newACL.setWriteAccess(recipientUserId, true);
        tic.setACL(newACL);
        tic.save("updatedACL", true);
    } else {
        console.log("Existing Tic. Do nothing. ");
    }
});