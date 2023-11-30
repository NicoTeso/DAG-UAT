public with sharing class EmailMessageHandler implements ITriggerHandler {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    public Map<Id, Schema.RecordTypeInfo> rtMapById = new Map<Id, Schema.RecordTypeInfo>(); 

    public Map<String, Case> mapCaseById = new Map<String, Case>();
    public List<Case> listCaseToUpdate = new List<Case>();
    
    public EmailMessageHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {
    }

    public void bulkAfter() {
        system.debug('Inicia el After');
        mapCaseById.clear();
        listCaseToUpdate.clear();
        List<String> listCaseId = new List<String>();
        rtMapById = Schema.SObjectType.Case.getRecordTypeInfosById();
        if(Trigger.new != null){
            for (SObject so : Trigger.new){
		        EmailMessage message = (EmailMessage) so;
		        if (message.ParentId != null && case.sObjectType == message.ParentId.getSObjectType()){
        		    listcaseId.add(message.ParentId);
        		}    
                
            }
            if(!listCaseId.isEmpty()){
                mapCaseById = CaseGateway.getCaseById(listCaseId);
            }

        }
    }

    public void beforeInsert(sObject so) {}
    
    public void beforeUpdate(sObject old, sObject so) {}
    
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {

        EmailMessage message = (EmailMessage) so;
        
        if (message.ParentId != null && mapCaseById.containsKey(message.ParentId)){
            Case caso = mapCaseById.get(message.ParentId);
	        String RTDeveloperName = rtMapById.get(caso.RecordTypeId).getDeveloperName();
            if (caso.Buzon__c == null && 
               (Label.RtCaseGestionEmail.equalsIgnoreCase(RTDeveloperName) ||
                Label.RtCaseGestionEmailMobility.equalsIgnoreCase(RTDeveloperName) ||
                Label.RtCaseGestionEmailInciMobility.equalsIgnoreCase(RTDeveloperName) ||
                Label.RtCaseGestionAtencionCliente.equalsIgnoreCase(RTDeveloperName))) {
                    
                if (message.ToAddress != null && message.ToAddress.length() > 255){
                	caso.Buzon__c = message.ToAddress.substring(0,254);
            	} else {
                	caso.Buzon__c = message.ToAddress;
           	 	}
                if (message.ToAddress != null && 
                   (message.ToAddress.contains('cochesnet@domingoalonsogroup.com') ||
                    message.ToAddress.contains('cochesDAGC@domingoalonsogroup.com') ||
                    message.ToAddress.contains('cochesdatf@domingoalonsogroup.com') ||
                    message.ToAddress.contains('cochesHALLYU@domingoalonsogroup.com') ||
                    message.ToAddress.contains('cochesSUCO@domingoalonsogroup.com'))) {
                    caso.Medio__c = 'ECOM';
                    caso.Soporte__c = 'coches.net';    
                }

                if (message.ToAddress != null && 
                   (message.ToAddress.contains('da.heycar@domingoalonsogroup.com') ||
                    message.ToAddress.contains('dafv.heycar@domingoalonsogroup.com') ||
                    message.ToAddress.contains('dagc.heycar@domingoalonsogroup.com') ||
                    message.ToAddress.contains('dalp.heycar@domingoalonsogroup.com') ||
                    message.ToAddress.contains('dalz.heycar@domingoalonsogroup.com') ||
                    message.ToAddress.contains('dat.heycar@domingoalonsogroup.com') ||
                    message.ToAddress.contains('del.heycar@domingoalonsogroup.com') ||
                    message.ToAddress.contains('gen.heycar@domingoalonsogroup.com') ||
                    message.ToAddress.contains('hal.heycar@domingoalonsogroup.com') ||
                    message.ToAddress.contains('hat.heycar@domingoalonsogroup.com') ||
                    message.ToAddress.contains('hy.heycar@domingoalonsogroup.com') ||
                    message.ToAddress.contains('suc.heycar@domingoalonsogroup.com'))) {
                    caso.Medio__c = 'ECOM';
                    caso.Soporte__c = 'heycar.com';    
                }
                    
                if (message.ToAddress != null && 
                    message.ToAddress.contains('domingoalonsoinfo@gmail.com')) {
                    caso.Marca__c = 'AUDI';    
                }
                if (message.ToAddress != null && 
                    message.ToAddress.contains('servicio.al.cliente@audicanarias.com')) {
                    caso.Marca__c = 'AUDI';    
                }
                if (message.ToAddress != null && 
                    message.ToAddress.contains('servicio.al.cliente@ducaticanarias.com')) {
                    caso.Marca__c = 'DUCATI';    
                }
                if (message.ToAddress != null && 
                    message.ToAddress.contains('atencionclientes@hyundaicanarias.com')) {
                    caso.Marca__c = 'HYUNDAI';    
                }
                if (message.ToAddress != null && 
                    message.ToAddress.contains('servicio.al.cliente@skodacanarias.com')) {
                    caso.Marca__c = 'SKODA';    
                }
                if (message.ToAddress != null && 
                   (message.ToAddress.contains('servicio.al.cliente@vwcanarias.com') || 
                    message.ToAddress.contains('reclamacionac@vwcanarias.com'))) {
                    caso.Marca__c = 'VOLKSWAGEN';    
                }
                if (message.ToAddress != null && 
                    message.ToAddress.contains('fidelizacion@hondacanarias.com')) {
                    caso.Marca__c = 'HONDA';    
                }

                    
                if (Label.RtCaseGestionEmailInciMobility.equalsIgnoreCase(RTDeveloperName)){
                    caso.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get(Label.RtCaseIncidenciaMobility).getRecordTypeId();
                }    
                    
                listCaseToUpdate.add(caso);
            } else if (message.Incoming){
                caso.Status = 'Respuesta email recibida';          
                listCaseToUpdate.add(caso);
            }
        }    
    }
    
    public void afterUpdate(sObject old, sObject so) {}
    
    public void afterDelete(sObject so) {}
    
    public void andFinally() {

        if(!listCaseToUpdate.isEmpty()){
            system.debug('listCaseToUpdate'+listCaseToUpdate);
            update listCaseToUpdate;
        }
        
    }
}