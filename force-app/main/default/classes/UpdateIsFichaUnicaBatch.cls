global class UpdateIsFichaUnicaBatch implements Database.Batchable<sObject>, Schedulable,Database.AllowsCallouts{

    private static datetime FechaHasta = datetime.now().addDays(1);

	private static Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.Consentimientos__c.getRecordTypeInfosByDeveloperName();
    private static String FichaUnicaRT = rtMapByDName.get('Ficha_unica').getRecordTypeId();  

    global Database.QueryLocator start(Database.BatchableContext bc) {
            return  Database.getQueryLocator([SELECT Id, Contact__r.Account.isFichaUnica__c, Contact__r.AccountId 
            									FROM Consentimientos__c 
            								   WHERE RecordTypeId = :FichaUnicaRT AND 
                  									 entryDate__c < :FechaHasta AND
                                                     entryDate__c != null AND 
                                                     oppositionDate__c = null AND
                                                     Contact__r.Account.isFichaUnica__c = false AND
                                                     Contact__c != null
            								ORDER BY Contact__r.AccountId]);
       
    }
    
    global void execute(Database.BatchableContext BC, List<Consentimientos__c> lstConsentimientos) {
        Map<String,Account> mapAccountToUpdate =  new Map<String, Account>();

        List<String> listAccountId  = new List<String>();

        for(Consentimientos__c consentimiento:lstConsentimientos){
            listAccountId.add(consentimiento.Contact__r.AccountId);
        }    
        
        if(!listAccountId.isEmpty()){
            mapAccountToUpdate = AccountGateway.getAccountById(listAccountId);
        }
        
        for(Consentimientos__c consentimiento:lstConsentimientos){

            Account Cuenta = new Account();
            Cuenta = mapAccountToUpdate.get(consentimiento.Contact__r.AccountId);
            Cuenta.isFichaUnica__c = true;
            mapAccountToUpdate.put(Cuenta.Id, Cuenta);
        }

        if(!mapAccountToUpdate.isEmpty()){
            update mapAccountToUpdate.values();
        }
       
    }   
    
    global void finish(Database.BatchableContext BC) {}
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new UpdateIsFichaUnicaBatch());
    }

}