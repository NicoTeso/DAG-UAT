/**
 * Created by davidmartinez on 24/03/2021.
 */

({
    invoke: function(component, event, helper) {
        // Get the record ID attribute
        var recordId = component.get("v.recordId");
        var status = component.get("v.state");
        var notCompletedReason = component.get("v.notCompletedReason");
        var dateTimeInfo = component.get("v.dateTimeInfo");
        var numberOfTries = component.get("v.numberOfTries");
        var wrongPhone = component.get("v.wrongPhone");
        var discardReason = component.get("v.discardReason");

        console.log('recordId: ' + recordId);
        console.log('status: ' + status);
        console.log('notCompletedReason: ' + notCompletedReason);
        console.log('numberOfTries: ' + numberOfTries);
        console.log('dateTimeInfo: ' + dateTimeInfo);
        console.log('wrongPhone: ' + wrongPhone);
        console.log('discardReason: ' + discardReason);

        var timeInfo = null;
        if(notCompletedReason == 'AUTOMATIC_CALL') timeInfo = numberOfTries.toString();
        else if(notCompletedReason == 'SPECIFIC_TIME') timeInfo = dateTimeInfo;

        var action = component.get("c.scheduleCall");
        action.setParams({
            'recordId': recordId,
            'mode': notCompletedReason,
            'timeInfo': timeInfo
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Call successfully scheduled")
            }
            else if (state === "ERROR") {
                console.log("Cannot schedule the call");
            }
        });
        $A.enqueueAction(action);

    }
})