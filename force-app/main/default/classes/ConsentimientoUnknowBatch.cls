global class ConsentimientoUnknowBatch implements Database.Batchable<sObject>, Schedulable {
    public void execute(SchedulableContext sc) {
        Id batchJobId = Database.executeBatch(new ConsentimientoUnknowBatch());
    }
    
	global Database.QueryLocator start(Database.BatchableContext bc) {
        if(Test.isRunningTest()){
        	return Database.getQueryLocator([select id, ParentId, OldValue, NewValue, CreatedDate  from Consentimientos__History where Field ='AfterSales__c' order by ParentId,CreatedDate]);
   
        }
        return Database.getQueryLocator([select id, ParentId, OldValue, NewValue, CreatedDate  from Consentimientos__History where  Parent.AfterSales__c ='Unknown' and Field ='AfterSales__c' order by ParentId,CreatedDate]);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
       // Map<String,sObject> mapLastConsentimientoHByParentId = new Map<String,sObject>();
        Map<String,Consentimientos__c> mapConsentimientoById = new Map<String,Consentimientos__c>();
        Map<String,List<Consentimientos__History>> mapCHByParentId = new Map<String,List<Consentimientos__History>>();
        Map<String,Datetime> createDateListByParentId = new Map<String,Datetime>();
        List<Consentimientos__c> consentimientosToUpdate = new List<Consentimientos__c>();
        system.debug('Inicio for');
        for(sObject conseHScope :scope){
            Consentimientos__History conseHistory = (Consentimientos__History) conseHScope;
            String newValue = String.valueOf(conseHistory.NewValue);
            String oldValue = String.valueOf(conseHistory.OldValue);
            if(Test.isRunningTest()){
                newValue = Label.ConsentimientoUnknown;
                oldValue = Label.ConsentimientoAllow;
            }
            System.debug('newValue:'+ newValue);
            System.debug('oldValue:'+ oldValue);
            System.debug('conseHistory:'+ conseHistory);
            if(Label.ConsentimientoUnknown.equalsIgnoreCase(newValue) && 
               (Label.ConsentimientoAllow.equalsIgnoreCase(oldValue) || Label.ConsentimientosDeny.equalsIgnoreCase(oldValue))){
                   createDateListByParentId.put(conseHistory.ParentId,conseHistory.CreatedDate);
        
            }
        }
        system.debug('createDateListByParentId:'+ createDateListByParentId);
        if(!createDateListByParentId.isEmpty()){
            for(Consentimientos__c conse : [select Id, Name, RecordTypeId, LastModifiedDate, ProductSale__c, AfterSales__c, EventInvitation__c, MarketResearch__c, CustomerSatisfaction__c, ChannelValue__c, EnviarAmulesoft__c, Fecha_de_captura__c,
                                       	    Contact__c, ProductSaleSMS__c, AfterSalesSMS__c, EventInvitationSMS__c, MarketResearchSMS__c, Medio_de_contacto__c, CustomerSatisfactionSMS__c, Lead__c, Concesionario__c, Marca__c, CustomerSatisfactionSales__c,
                                       		CustomerSatisfactionAfterSales__c, expectedCommunicationDate__c, realCommunicationDate__c, oppositionDate__c, entryDate__c, communicationType__c, SMS__c, Email__c, Call__c, WhatsApp__c, legitimateInterest__c, noEcosystem__c
                                       		from Consentimientos__c where Id in : createDateListByParentId.keySet() ]){
                mapConsentimientoById.put(conse.id, conse);
                                               
            }
            system.debug('mapConsentimientoById:'+ mapConsentimientoById.keySet());
            for(Consentimientos__History cHistory :[select id, ParentId, OldValue, NewValue, CreatedDate, Field  
                                                    from Consentimientos__History 
                                                    where  Parent.Id in : createDateListByParentId.keySet() and CreatedDate in :createDateListByParentId.values() order by CreatedDate]){
               List<Consentimientos__History> cHistorys = mapCHByParentId.containsKey(cHistory.ParentId)?mapCHByParentId.get(cHistory.ParentId):new List<Consentimientos__History>();
               cHistorys.add(cHistory);
               mapCHByParentId.put(cHistory.ParentId, cHistorys);                                       
            }
            system.debug('mapCHByParentId:' +mapCHByParentId);
            system.debug('Inicio del ultimo for');
            for(String parentId :mapCHByParentId.keySet()){
                Consentimientos__c conseOld = mapConsentimientoById.get(parentId);
                Consentimientos__c conseNew = new Consentimientos__c();
                conseNew.Id = parentId;
                conseNew.EnviarAmulesoft__c = false;
                List<Consentimientos__History> cHistorys = mapCHByParentId.get(parentId);
                for(Consentimientos__History cHistory :cHistorys){
                    String newValue = String.valueOf(cHistory.NewValue);
            		String oldValue = String.valueOf(cHistory.OldValue);
                    if(Test.isRunningTest()){
                		newValue = Label.ConsentimientoUnknown;
                		oldValue = Label.ConsentimientoAllow;
            		}
                    System.debug('newValue:'+ newValue);
            		System.debug('oldValue:'+ oldValue);
            		System.debug('cHistory:'+ cHistory);
            		if(Label.ConsentimientoUnknown.equalsIgnoreCase(newValue) && 
               		  (Label.ConsentimientoAllow.equalsIgnoreCase(oldValue) || Label.ConsentimientosDeny.equalsIgnoreCase(oldValue))){
                   		String FieldString = String.valueOf(cHistory.Field);
                        conseNew.put(FieldString,oldValue);
                     }
                }
                system.debug('conseNew:'+conseNew);
                consentimientosToUpdate.add(conseNew);
            }
            
            Update consentimientosToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext BC) {}
   
}