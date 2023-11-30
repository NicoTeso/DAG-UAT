global class MergeLeadBatch implements Database.Batchable<sObject>, Schedulable {
    
    public void execute(SchedulableContext sc) {
        Id batchJobId = Database.executeBatch(new MergeLeadBatch(), 10);
    }
    
	global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([select id from DuplicateRecordSet where DuplicateRule.SobjectType ='Lead']);
    }
    
    global void execute(Database.BatchableContext BC, List<DuplicateRecordSet> lstDuplicateSet) {
        Map<String, List<DuplicateRecordItem>> mapDuplicateSetToItems = new Map<String, List<DuplicateRecordItem>>();
        Map<String,Map<String,Consentimientos__c>> mapConsentimientoByLead = new Map<String,Map<String,Consentimientos__c>>();
        Map<String,Lead> mapLeadById = new Map<String,Lead>();
        
        List<String> duplicateIdSet = new List<String>();
        List<String> leadIds = new List<String>();
        system.debug('setDuplicados:' + lstDuplicateSet);
        
        for (DuplicateRecordSet duplicateSet: lstDuplicateSet) {
            duplicateIdSet.add(duplicateSet.Id);
        }
        
        for (DuplicateRecordItem item : [SELECT Id, RecordId, DuplicateRecordSetId FROM DuplicateRecordItem WHERE DuplicateRecordSetId in :duplicateIdSet]) {
            List<DuplicateRecordItem> duplicateItemAux = mapDuplicateSetToItems.containsKey(item.DuplicateRecordSetId)
                ? mapDuplicateSetToItems.get(item.DuplicateRecordSetId) : new List<DuplicateRecordItem>();
            
            if (Lead.sObjectType == item.RecordId.getSObjectType()) {
                leadIds.add(item.RecordId);
            }
            
            duplicateItemAux.add(item);
            mapDuplicateSetToItems.put(item.DuplicateRecordSetId, duplicateItemAux);
        }
        
        if (!leadIds.isEmpty()) {
            mapLeadById = LeadGateway.getLeadIdByIds(leadIds);
            mapConsentimientoByLead = ConsentimientosGateway.getConsentimientosByLeadId(leadIds);
        }
        
        List<Id> listDRecordSetDelete = new List<Id>();
        List<Id> listDRecordItemDelete = new List<Id>();
        
        for (String duplicateId : mapDuplicateSetToItems.keySet()) {
            List<DuplicateRecordItem> duplicateItemAux = mapDuplicateSetToItems.get(duplicateId);
            system.debug('duplicateItemAux:' + duplicateItemAux);
            
            if (duplicateItemAux.size() ==  2) {
                DuplicateRecordItem item1 = duplicateItemAux[0];
                DuplicateRecordItem item2 = duplicateItemAux[1];
                Lead ld1, ld2;
                if(mapLeadById.containsKey(item1.RecordId)){
                    ld1 = mapLeadById.get(item1.RecordId);
                }
                if(mapLeadById.containsKey(item2.RecordId)){
                    ld2 = mapLeadById.get(item2.RecordId);
                }
                if (ld1 != null && ld2 != null) {
                    if(String.isNotBlank(ld1.Documento__c) &&  String.isNotBlank(ld2.Documento__c)){
                       // No tratarlo
                       system.debug('Los dos person account tiene documento');
                    }
                    else if(String.isNotBlank(ld1.Documento__c)) {
                        //acc1 es master
                        MergeLeadBatch.mergeconsentimiento(ld1.Id, ld2.Id, mapConsentimientoByLead);
                        MergeLeadBatch.mergeLeads(ld1, ld2);
                        listDRecordItemDelete.add(item1.Id);
	                    listDRecordSetDelete.add(duplicateId);
                        
                    }
                    else if(String.isNotBlank(ld2.Documento__c)){
                        //acc2 es master
                        MergeLeadBatch.mergeconsentimiento(ld2.Id, ld1.Id, mapConsentimientoByLead);
                        MergeLeadBatch.mergeLeads(ld2, ld1);
                        listDRecordItemDelete.add(item2.Id);
	                    listDRecordSetDelete.add(duplicateId);
                    }
                    else {
                        if(ld1.LastModifiedDate > ld2.LastModifiedDate){
                            MergeLeadBatch.mergeconsentimiento(ld1.Id, ld2.Id, mapConsentimientoByLead);
                            MergeLeadBatch.mergeLeads(ld1, ld2);
                            listDRecordItemDelete.add(item1.Id);
		                    listDRecordSetDelete.add(duplicateId);
                        }
                        else {
                            MergeLeadBatch.mergeconsentimiento(ld2.Id, ld1.Id, mapConsentimientoByLead);
                            MergeLeadBatch.mergeLeads(ld2, ld1);
                            listDRecordItemDelete.add(item2.Id);
		                    listDRecordSetDelete.add(duplicateId);
                        }
                    }
       			}
			} 
        }
        
        system.debug('listDRecordSetDelete:'+ listDRecordSetDelete);
        system.debug('listDRecordItemDelete:'+ listDRecordItemDelete);
        if (!listDRecordSetDelete.isEmpty()) {
            if(!listDRecordItemDelete.isEmpty()){
                Database.delete(listDRecordItemDelete);
            }

            Database.delete(listDRecordSetDelete);
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {}
    
    global static void mergeLeads(Lead master, Lead duplicate){
        
        Lead masterUpdate = new Lead();
        masterUpdate.Id = master.Id;
        
        if (!masterUpdate.ConCasosMKTImp__c && duplicate.ConCasosMKTImp__c){
            masterUpdate.ConCasosMKTImp__c = true;
        }

        if (!masterUpdate.ConCasosMKTNoImp__c && duplicate.ConCasosMKTNoImp__c){
            masterUpdate.ConCasosMKTNoImp__c = true;
        }

        if (!masterUpdate.ConEcosistema__c && duplicate.ConEcosistema__c){
            masterUpdate.ConEcosistema__c = true;
        }
         
        update masterUpdate;

        Database.MergeResult results = Database.merge(masterUpdate, duplicate.Id);
    }
        
    global static void mergeconsentimiento(String masterId, String duplicateId, Map<String,Map<String,Consentimientos__c>> mapConsentimientoByLead){
		Map<String,Consentimientos__c> mapConsentimientoByVaueMaster =  mapConsentimientoByLead.containsKey(masterId)? mapConsentimientoByLead.get(masterId): new Map<String,Consentimientos__c>();
        Map<String,Consentimientos__c> mapConsentimientoByValueDuplicate = mapConsentimientoByLead.containsKey(duplicateId)? mapConsentimientoByLead.get(duplicateId): new Map<String,Consentimientos__c>();
        List<Consentimientos__c> listConsentimientoToUpdate = new List<Consentimientos__c>();
        List<Consentimientos__c> listConsentimientoDelete = new List<Consentimientos__c>();
        
        for(Consentimientos__c conse : mapConsentimientoByValueDuplicate.values()){
        	if(mapConsentimientoByVaueMaster.containsKey(conse.ChannelValue__c)){
            	Consentimientos__c conseLead = mapConsentimientoByVaueMaster.get(conse.ChannelValue__c);
                if((conseLead.Fecha_de_captura__c!= null && conse.Fecha_de_captura__c != null && conseLead.Fecha_de_captura__c < conse.Fecha_de_captura__c)
                  ||(conseLead.Fecha_de_captura__c == null && conse.Fecha_de_captura__c != null) ){
                	listConsentimientoDelete.add(conse);
                   	conseLead.AfterSales__c = conse.AfterSales__c;
                    conseLead.AfterSalesSMS__c = conse.AfterSalesSMS__c;
                    conseLead.CustomerSatisfaction__c = conse.CustomerSatisfaction__c;
                    conseLead.CustomerSatisfactionSMS__c = conse.CustomerSatisfactionSMS__c;
                    conseLead.EventInvitation__c= conse.EventInvitation__c;
                    conseLead.EventInvitationSMS__c = conse.EventInvitationSMS__c;
                    conseLead.Fecha_de_captura__c = conse.Fecha_de_captura__c;
                    conseLead.MarketResearch__c= conse.MarketResearch__c;
                    conseLead.MarketResearchSMS__c= conse.MarketResearchSMS__c;
                    conseLead.ProductSale__c= conse.ProductSale__c;
                    conseLead.ProductSaleSMS__c= conse.ProductSaleSMS__c;
                    conseLead.EnviarAmulesoft__c = false;
                    listConsentimientoToUpdate.add(conseLead);
         		}
                else {
                	listConsentimientoDelete.add(conse);
                 }
           	}
            else {
            	conse.Lead__c = masterId;
                conse.EnviarAmulesoft__c = false;
                conse.Medio_de_contacto__c = Label.channelOther;
                listConsentimientoToUpdate.add(conse);
             }
        }
        
        system.debug('listConsentimientoToUpdate:'+ listConsentimientoToUpdate);
        if (!listConsentimientoToUpdate.isEmpty()) {
            update listConsentimientoToUpdate;
        }
        
        system.debug('listConsentimientoDelete:'+ listConsentimientoDelete);
        if (!listConsentimientoDelete.isEmpty()) {
            Database.delete(listConsentimientoDelete);
        }
	}
}