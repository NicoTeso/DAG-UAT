global class UpdateConCasosMKTBatch implements Database.Batchable<sObject>, Schedulable,Database.AllowsCallouts{

    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
	    Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName();
		List<String> ListRecordTypeDeveloperName = Label.RTCaseSyncMKTCloud.split(';');
	    List<String> recordTypeIds = new List<String>();

        for (String recordTypeDeveloperName:ListRecordTypeDeveloperName) {
	        recordTypeIds.add(rtMapByDName.get(recordTypeDeveloperName).getRecordTypeId());
        }
        
        return  Database.getQueryLocator([SELECT id, Lead__c, AccountId, RecordTypeId, EndAdvertisingImpact__c
                                            FROM CASE
                                          WHERE RecordTypeId IN :recordTypeIds AND
                                                 EndAdvertisingImpact__c = TODAY]);
       
    }
    
    global void execute(Database.BatchableContext BC, List<Case> lstCases) {

	    Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName();
		List<String> ListRecordTypeDeveloperName = Label.RTCaseSyncMKTCloud.split(';');
	    List<String> recordTypeIds = new List<String>();

        for (String recordTypeDeveloperName:ListRecordTypeDeveloperName) {
	        recordTypeIds.add(rtMapByDName.get(recordTypeDeveloperName).getRecordTypeId());
        }
        
        Map<String,Account> mapAccountToUpdate =  new Map<String, Account>();
        Map<String,Lead> mapLeadToUpdate =  new Map<String, Lead>();
        Map<String,String> mapLead =  new Map<String, String>();
        Map<String,String> mapAccount =  new Map<String, String>();

        List<String> listClientes  = new List<String>();
        List<String> listLead  = new List<String>();

        try{

            if(!lstCases.isEmpty()){
                for(Case caso:lstCases){
                    if (caso.Lead__c != null) {
                        listLead.add(caso.Lead__c);
                        mapLead.put(caso.Lead__c,caso.Lead__c);
                    }
                    if (caso.AccountId != null) {
                        listClientes.add(caso.AccountId);
                        mapAccount.put(caso.AccountId,caso.AccountId);
                    }
                }    
            }    
    
            List<Case> lstConCasoLead = new List<Case>();
            
            if(!listLead.isEmpty()){
                
                lstConCasoLead = [SELECT id, Lead__c
                                    FROM Case 
                                   WHERE Lead__c in :listLead
                                     AND RecordTypeId IN :recordTypeIds
                                     AND endAdvertisingImpact__c > TODAY];
            }   
    
            if(!lstConCasoLead.isEmpty()){
                for(Case caso:lstConCasoLead){
                    if (caso.Lead__c != null) {
                        mapLead.remove(caso.Lead__c);
                    }
                }    
            }

            List<Case> lstConCasoAccount = new List<Case>();
            
            if(!listClientes.isEmpty()){
                lstConCasoAccount = [SELECT id, AccountId
                                    FROM Case 
                                   WHERE AccountId in :listClientes
                                     AND RecordTypeId IN :recordTypeIds
                                     AND endAdvertisingImpact__c > TODAY];
            }   
    
            if(!lstConCasoAccount.isEmpty()){
                for(Case caso:lstConCasoAccount){
                    if (caso.AccountId != null) {
                        mapAccount.remove(caso.AccountId);
                    }
                }    
            }

            for(String IdLead:mapLead.values()){
                Lead Candidato = new Lead();
                Candidato.id = IdLead;
                Candidato.ConCasosMKTImp__c = false;
                Candidato.ConCasosMKTNoImp__c = true;
                mapLeadToUpdate.put(Candidato.Id, Candidato);
            }
            
            for(String IdCliente:mapAccount.values()){
                Account Cuenta = new Account();
                Cuenta.id = IdCliente;
                Cuenta.ConCasosMKTImp__c = false;
                Cuenta.ConCasosMKTNoImp__c = true;
                mapAccountToUpdate.put(Cuenta.Id, Cuenta);
            }

            if(!mapLeadToUpdate.isEmpty()){
                update mapLeadToUpdate.values();
            }
            
            if(!mapAccountToUpdate.isEmpty()){
                update mapAccountToUpdate.values();
            }
            
        }catch(Exception e) {
            System.debug('UpdateConCasosMKTBatch.execute exception ' + e.getStackTraceString());
            Exception__c exc = new Exception__c ();
            exc.Exception__c = e.getStackTraceString() + ' ' + e.getCause() ;
            exc.Linea__c = e.getLineNumber();
            exc.Clase_Metodo__c = 'UpdateConCasosMKTBatch.execute';
            insert exc;
        }
       
    }   
    
    global void finish(Database.BatchableContext BC) {}
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new UpdateConCasosMKTBatch(),30);
    }

}