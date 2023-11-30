global class NBK_TotalCallAttempts_Batch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc){

        System.debug('### NBK_TotalCallAttempts_Batch - start()');

        String query = 
                'SELECT Id, Total_Call_Attempts__c, Call_Attempts__c ' +
                'FROM Call_Task__c ' +
                'WHERE Call_Attempts__c != NULL';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Call_Task__c> lCallTasks){

        for (Call_Task__c callTask : lCallTasks){
            System.debug('### NBK_TotalCallAttempts_Batch - execute() - callTask: ' + callTask);
            callTask.Total_Call_Attempts__c = String.valueof((callTask.Call_Attempts__c).setscale(0));
        }
        try {
            update lCallTasks; 
        
        } catch (Exception e) {
            System.debug('### NBK_TotalCallAttempts_Batch - execute() - error: ' + e);
        }
    
    }

    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }

}