/*-----------------------------------------------------------------------------------------
     Apex Class:        NBK_CallTaskHandler_Batch
     Created Date:      23/06/2021
     Author:            davidmartinez
------------------------------------------------------------------------------------------*/
global class NBK_CallTaskHandler_Batch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {

        System.debug('### NBK_CallTaskHandler_Batch - start()');

        DateTime now = System.now();
        DateTime last5minutes = now.addMinutes(-5);
        last5minutes = last5minutes.addSeconds(-20);

        System.debug('### NBK_CallTaskHandler_Batch - start() - now: ' + now);
        System.debug('### NBK_CallTaskHandler_Batch - start() - last5minutes: ' + last5minutes);

        String query =
                'SELECT Id, Name, OwnerId, Assigned_Queue__c, Reschedule__c, Reschedule_Date__c, Case__c ' +
                'FROM Call_Task__c ' +
                'WHERE Reschedule__c = true ' +
                'AND Reschedule_Date__c >= :last5minutes AND Reschedule_Date__c <= :now';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Call_Task__c> lCallTasks) {
        List<Id> lRelatedCases = new List<Id>();
        Map<Id, Case> mRelatedCasesById = new Map<Id, Case>();

        for(Call_Task__c callTask : lCallTasks) {
            if(callTask.Case__c != NULL){
                lRelatedCases.add(callTask.Case__c);
            }            
        }

        mRelatedCasesById = new Map<Id,Case>([SELECT Id, RecordTypeId, Marca__c, Origin, PurchasePriority__c, CreatedDate, Numero_de_llamadas__c, RecordType.DeveloperName 
                                              FROM Case
                                              WHERE Id IN : lRelatedCases]);

        for(Call_Task__c callTask : lCallTasks) {
            System.debug('### NBK_CallTaskHandler_Batch - execute() - callTask: ' + callTask);
            callTask.Reschedule__c = false;
            if(callTask.Case__c != NULL){
                //callTask.OwnerId = callTask.Assigned_Queue__c;
                Case relatedCase = mRelatedCasesById.get(callTask.Case__c);
                callTask.OwnerId = NBK_CaseTriggerHandler.getQueue(relatedCase).Id;
            }
        }
        try {
            update lCallTasks;

        } catch(Exception e) {
            System.debug('### NBK_CallTaskHandler_Batch - execute() - error: ' + e);
        }

    }

    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}