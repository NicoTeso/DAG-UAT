global class DeleteCLVBatch implements Database.Batchable<sObject>, Schedulable,Database.AllowsCallouts{

    private static datetime FechaHasta = datetime.now().addDays(-1);

    global Database.QueryLocator start(Database.BatchableContext bc) {
		    if (Test.isRunningTest()){
       			FechaHasta = datetime.now().addDays(+2);
    		}
            return  Database.getQueryLocator([SELECT Id, LastModifiedDate 
                                                FROM Customer_Lifetime_Value__c 
                                               WHERE LastModifiedDate < :FechaHasta]);
       
    }
    
    global void execute(Database.BatchableContext BC, List<Customer_Lifetime_Value__c> lstCLV) {

        if(!lstCLV.isEmpty()){
            delete lstCLV;
        }
       
    }   
    
    global void finish(Database.BatchableContext BC) {}
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new DeleteCLVBatch());
    }

}