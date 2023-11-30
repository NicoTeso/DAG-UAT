/*-----------------------------------------------------------------------------------------
     Apex Class:        NBK_ScheduleCall
     Created Date:      30/03/2021
     Author:            davidmartinez
------------------------------------------------------------------------------------------*/

global class NBK_ScheduleCall implements Schedulable{

    private String recordId;
    private List<Call_Task__c> lCallTasks;

    public NBK_ScheduleCall(String recordId){
        this.recordId = recordId;
    }

    public NBK_ScheduleCall(List<Call_Task__c> lCallTasks){
        this.lCallTasks = lCallTasks;
    }

    global void execute(SchedulableContext sc) {
        System.debug('### NBK_ScheduleCall - execute() - start');
        System.debug('### NBK_ScheduleCall - execute() - recordId: ' + this.recordId);
        System.debug('### NBK_ScheduleCall - execute() - lCallTasks: ' + this.lCallTasks);

        if(recordId != null){
            //Update the record
            Call_Task__c callTask = [SELECT Id, OwnerId, Name, Assigned_Queue__c, Status__c FROM Call_Task__c WHERE Id = :recordId LIMIT 1];
            callTask.OwnerId = callTask.Assigned_Queue__c;
            if(hasValidStatus(callTask))
                update callTask;
        }
        else if(lCallTasks != null && lCallTasks.size() > 0){
            insert lCallTasks;
        }

        System.debug('### NBK_ScheduleCall - execute() - end');
    }

    private Boolean hasValidStatus(Call_Task__c callTask){
        if(callTask.Status__c != 'Completada' && callTask.Status__c != 'Descartada') return true;
        return false;
    }
}