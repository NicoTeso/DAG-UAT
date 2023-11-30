public class MessagingSessionHandler implements ITriggerHandler {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    
    public Map<String, configurationWhatsApp__mdt> mapconfWhatsToChannelId = new Map<String, configurationWhatsApp__mdt>();
    
    public MessagingSessionHandler (Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {

        mapconfWhatsToChannelId.clear();
        List<String> listChannelId = new List<String>();
        
        if (Trigger.new != null) {
            for (SObject objeto:Trigger.new) {
            	MessagingSession mSession = (MessagingSession) objeto;
                
                if (!String.isBlank(mSession.MessagingChannelId)) {
                    listChannelId.add(mSession.MessagingChannelId);
                }
            }
  
            if (!listChannelId.isEmpty()) {
                for(configurationWhatsApp__mdt confWhats : [select id, channelId__c, Marca__c, ownerReg__c  
                                                        from configurationWhatsApp__mdt 
                                                        where channelId__c in :listChannelId LIMIT 2000]){
                    mapconfWhatsToChannelId.put(confWhats.channelId__c, confWhats);                                        
            	}
            }
		}

    }
    
    public void bulkAfter() {}
    
    public void beforeInsert(sObject so) {
        
        MessagingSession mSession = (MessagingSession) so;
        
        if (mapconfWhatsToChannelId.containsKey(mSession.MessagingChannelId)){
	        mSession.Marca__c = mapconfWhatsToChannelId.get(mSession.MessagingChannelId).Marca__c;
	        mSession.Unidad_de_negocio__c = mapconfWhatsToChannelId.get(mSession.MessagingChannelId).ownerReg__c;
        }
       
    }
    
    public void beforeUpdate(sObject old, sObject so) {}
 
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {}
    
    public void afterUpdate(sObject old, sObject so) {}
    
    public void afterDelete(sObject so) {}
    
    public void andFinally() {}
}