global class ManageOwnAgentBatch implements Database.Batchable<sObject>, Schedulable{
    
    private static List<Account> listAccount;

    public void execute(SchedulableContext sc) {
        Id batchJobId = Database.executeBatch(this, 200);
        System.debug('ManageOwnAgentBatch.execute sc batchJobId ' + batchJobId);
    }
    
	global Database.QueryLocator start(Database.BatchableContext bc) {

        System.debug('ManageOwnAgentBatch.start bc ' + bc);
        listAccount = new List<Account>();
        return Database.getQueryLocator([
            SELECT Id, Cliente_Propio__c, Fecha_Limite_Cliente_Propio__c, AceptadoComunicacionesWAH__c, 
            PersonContactId, isFichaUnica__c, PoliticaPrivacidadAceptada__c 
            FROM Account 
            WHERE Cliente_Propio__c = true AND 
                  Fecha_Limite_Cliente_Propio__c != null AND Fecha_Limite_Cliente_Propio__c <= TODAY
            LIMIT 2000
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        System.debug('ManageOwnAgentBatch.execute bc scope before ' + scope);

        List<string> IdcontactList = new List<string>();
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        
        for(Account a :scope){
            a.Cliente_Propio__c = false;
            a.Fecha_Limite_Cliente_Propio__c = null;
            a.AceptadoComunicacionesWAH__c = false;
            a.PoliticaPrivacidadAceptada__c = false;
            a.isFichaUnica__c = false;
            if (a.PersonContactId != null) {
                IdcontactList.add(a.PersonContactId);
            }
        }

        System.debug('ManageOwnAgentBatch.execute bc scope after ' + scope);
        update scope;
        
        if (!IdcontactList.isEmpty()) {
            String IdRTFichaUnica = Schema.SObjectType.Consentimientos__c.getRecordTypeInfosByDeveloperName().get('Ficha_unica').getRecordTypeId();
            listConsentimientos =  [SELECT Id
                                      FROM Consentimientos__c 
                                     WHERE Contact__c in :IdcontactList and recordTypeId = :IdRTFichaUnica];
            if (!listConsentimientos.isEmpty()) {
                delete listConsentimientos;
            }
        }     
    }

    global void finish(Database.BatchableContext bc) {
        listAccount = [
            SELECT Id, Cliente_Propio__c, Fecha_Limite_Cliente_Propio__c, AceptadoComunicacionesWAH__c, 
            PersonContactId, isFichaUnica__c, PoliticaPrivacidadAceptada__c  
            FROM Account 
            WHERE Cliente_Propio__c = true AND 
                  Fecha_Limite_Cliente_Propio__c != null AND Fecha_Limite_Cliente_Propio__c <= TODAY
            LIMIT 2000
        ];
        System.debug('ManageOwnAgentBatch.finish bc scope ' + listAccount.size());

        if(listAccount != null && !listAccount.isEmpty()){
            Database.executeBatch(this, 200);
            System.debug('ManageOwnAgentBatch.finish bc re run batch ' + this);
        }
    }
}