global class UpdateLimiteEnvioFUMobilityBatch implements Database.Batchable<sObject>, Schedulable {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return  Database.getQueryLocator([SELECT Id, LimiteEnvioFUMobility__c, ConEnvioFUMobility__c 
                                            FROM Account 
                                           WHERE LimiteEnvioFUMobility__c <= TODAY
                                           LIMIT 2000]);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> lstAccount) {
        Map<String,Account> mapAccountToUpdate =  new Map<String, Account>();

        try{

            for(Account cuenta:lstAccount){
                cuenta.ConEnvioFUMobility__c = false;
                cuenta.LimiteEnvioFUMobility__c = null;
                mapAccountToUpdate.put(Cuenta.Id, Cuenta);
            }
            
            if(!mapAccountToUpdate.isEmpty()){
                update mapAccountToUpdate.values();
            }
             
        }catch(Exception e) {
            System.debug('UpdateLimiteEnvioFUMobilityBatch.execute exception ' + e.getStackTraceString());
            Exception__c exc = new Exception__c ();
            exc.Exception__c = e.getStackTraceString() + ' ' + e.getCause() ;
            exc.Linea__c = e.getLineNumber();
            exc.Clase_Metodo__c = 'UpdateLimiteEnvioFUMobilityBatch.execute';
            insert exc;
        }
       
    }   
    
    global void finish(Database.BatchableContext BC) {}
 
    // Scheduler
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new UpdateLimiteEnvioFUMobilityBatch(), 20);
    }
}