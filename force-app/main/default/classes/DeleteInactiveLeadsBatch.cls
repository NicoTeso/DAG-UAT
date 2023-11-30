global class DeleteInactiveLeadsBatch implements Database.Batchable<sObject>, Schedulable {
    public void execute(SchedulableContext sc) {
        Id batchJobId = Database.executeBatch(new DeleteInactiveLeadsBatch());
    }
    
	global Database.QueryLocator start(Database.BatchableContext bc) {
        Set<Id> leadId = new Set<Id>();
        
        for (Case caso : [SELECT Id, Lead__c FROM Case WHERE Lead__c != null]) {
            leadId.add(caso.Lead__c);
        }
        
        for (LiveChatTranscript chat : [SELECT Id, LeadId FROM LiveChatTranscript WHERE LeadId != null]) {
            leadId.add(chat.LeadId);
        }
        
        System.debug('búsqueda de lead: ' + [SELECT Id, Lastname, FirstName FROM Lead WHERE Id NOT IN :leadId]);
        return Database.getQueryLocator([SELECT Id FROM Lead WHERE Id NOT IN :leadId]);
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> lstLeads) {
        List<String> leadIds = new List<String>();
        
        for (Lead candidato : lstLeads) {
            leadIds.add(candidato.Id);
        }
        
        System.debug('lead a borrar:' + leadIds);
        Map<String, Map<String, Consentimientos__c>> mapConsentimientoByLead = ConsentimientosGateway.getConsentimientosByLeadId(leadIds);
        Set<Consentimientos__c> consentimientoToDelete = new Set<Consentimientos__c>();
        
        for (String leadId : mapConsentimientoByLead.keySet()) {
            Map<String, Consentimientos__c> mapConsentimientoByValue = mapConsentimientoByLead.get(leadId);
            consentimientoToDelete.addAll(mapConsentimientoByValue.values());
        }
        
        if (!consentimientoToDelete.isEmpty()) {
            System.debug('Elimina consentimientos: ' + consentimientoToDelete);
            List<Consentimientos__c> lstConsentimientoToDelete = new List<Consentimientos__c>();
            lstConsentimientoToDelete.addAll(consentimientoToDelete);
            delete lstConsentimientoToDelete;
        }
        
        List<DuplicateRecordItem> lstDupItems = [SELECT DuplicateRecordSetId FROM DuplicateRecordItem WHERE RecordId IN :leadIds];
        System.debug('lstDupItems: ' + lstDupItems);
        List<Id> DupSetIds = new List<Id>();
        
        for (DuplicateRecordItem dri : lstDupItems) {
            DupSetIds.add(dri.DuplicateRecordSetId);
        }
        
        //List<DuplicateRecordSet> lstDupSets = [SELECT Id FROM DuplicateRecordSet WHERE Id in :DupSetIds];
        //System.debug('lstDupSets: ' + lstDupSets);
        
        if (!DupSetIds.isEmpty()) {
            Database.delete(DupSetIds);
        }
        
        if (!lstLeads.isEmpty()) {
            delete lstLeads;
        }
    }
    
    global void finish(Database.BatchableContext BC) {}
}