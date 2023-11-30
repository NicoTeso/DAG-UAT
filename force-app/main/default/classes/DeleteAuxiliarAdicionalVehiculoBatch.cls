global class DeleteAuxiliarAdicionalVehiculoBatch implements Database.Batchable<sObject>, Schedulable {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date fechaLimit = Date.today().addMonths(-1);
        if(Test.isRunningTest()){
            fechaLimit = Date.today().addDays(1);
        }
        system.debug('fl:'+ fechaLimit);
        return Database.getQueryLocator([SELECT Id FROM AuxiliarAdicionalVehiculo__c WHERE Procesado__c = true AND CreatedDate <= :fechaLimit]);
    }
    
    global void execute(Database.BatchableContext bc, List<AuxiliarAdicionalVehiculo__c> lstAuxAd) {
        
        delete lstAuxAd;
        
    }
    
    global void finish(Database.BatchableContext bc) {
    }
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new DeleteAuxiliarAdicionalVehiculoBatch());
        
    }

}