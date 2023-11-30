public class ExternalCustomerService {
/*    
    @AuraEnabled
    public static void createAndSendJSON(Case ca) {
        // Case ID from Aura button
        List<Case> listCase = [SELECT Id, AccountId, Lead__c, Centro__c, Vehiculo__c, CreatedById, Es_LEAD__c,Campana__c,RecordTypeId, RecordType.DeveloperName,
                         Marca__c,Intencion_de_compra__c
                         FROM Case
                         WHERE Id = :ca.Id];
        Map<String, Gestion_Lead__c> mapGLeadById = CacheUtil.getGestionLeadMap();
        
        if (!mapGLeadById.isEmpty()) {
            Gestion_Lead__c gLead;
            Case caso = listCase[0];
            
            for (Gestion_Lead__c gestionLead :mapGLeadById.values()) {
                if (gLead.Centro__c == caso.Centro__c && caso.Marca__c.equalsIgnoreCase(gLead.Marca__c) && caso.Intencion_de_compra__c.contains(gLead.Intencion_de_compra__c)) {
                    gLead = gestionLead;
                	break;
                }
          	}
            
            if (gLead != null) {
                ExternalCustomerServiceController.createExternalLeadOrAccountMulesoftSec(JSON.serialize(listCase),JSON.serialize(gLead));
            }
      	}
	}*/
}