// Create pointers for sender and recipient in the cloud data store
Parse.Cloud.beforeSave("Tic", function(request, response) {
    Parse.Cloud.useMasterKey();
    if (request.user) {
    	console.log("Sender uid = [" + request.object.get("senderUserId") + "]");
    	request.object.set("sender", request.user);
    } else {
    	var senderUserId = request.object.get("senderUserId");
    	var senderQuery = new Parse.Query(Parse.User);
    	senderQuery.get(senderUserId, {
    		success: function(object) {
            	request.object.set("sender", object);
        	},
        	error: function(object, error) {
            	response.error("Invalid senderUserId.");
        	}
    	});
    }
    var recipientUserId = request.object.get("recipientUserId");
    console.log("Recipient uid = [" + recipientUserId + "]");
    var recipientQuery = new Parse.Query(Parse.User);
    recipientQuery.get(recipientUserId, {
        success: function(object) {
            request.object.set("recipient", object);
            response.success();
        },
        error: function(object, error) {
        	console.error(error);
            response.error("Invalid recipientUserId.");
        }
    });
});