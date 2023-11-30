global class DeleteRegistrosRelacionadosBatch implements Database.Batchable<sObject>, Schedulable{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime fechaLimit = Datetime.now().addYears(-1);
        if(Test.isRunningTest()){
            fechaLimit = Datetime.now();
        }
        return Database.getQueryLocator([SELECT Id  FROM Registros_Relacionados__c WHERE CreatedDate <= :fechaLimit]);
    }
    
    global void execute(Database.BatchableContext bc, List<Registros_Relacionados__c> lstAuxAd) {
		Delete lstAuxAd;
       
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new DeleteDAccountMarketingBatch());
        
    }
}