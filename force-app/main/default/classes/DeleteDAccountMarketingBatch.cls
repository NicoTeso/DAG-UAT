global class DeleteDAccountMarketingBatch implements Database.Batchable<sObject>, Schedulable{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date fechaLimit = Date.today().addDays(-10);
        if(Test.isRunningTest()){
            fechaLimit = Date.today();
        }
        return Database.getQueryLocator([SELECT Id, Fecha_eliminacion__c  FROM Delete_Account_Marketing__c  WHERE Fecha_eliminacion__c = :fechaLimit]);
    }
    
    global void execute(Database.BatchableContext bc, List<Delete_Account_Marketing__c> lstAuxAd) {
		Delete lstAuxAd;
       
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new DeleteDAccountMarketingBatch());
        
    }

}