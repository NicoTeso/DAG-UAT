public class ChatTranscriptHandler implements ITriggerHandler {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    
    public Map<String, configurationChat__mdt> mapconfChatsToButtonId = new Map<String, configurationChat__mdt>();
    
    public ChatTranscriptHandler (Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {

        mapconfChatsToButtonId.clear();
        List<String> listButtonId = new List<String>();
        
        if (Trigger.new != null) {
            for (SObject objeto:Trigger.new) {
            	LiveChatTranscript chat = (LiveChatTranscript) objeto;
                
                if (!String.isBlank(chat.LiveChatButtonId)) {
                    listButtonId.add(chat.LiveChatButtonId);
                }
            }
            
            if (!listButtonId.isEmpty()) {
                for(configurationChat__mdt confChats : [select id, chatId__c, Marca__c, ownerReg__c  
                                                        from configurationChat__mdt 
                                                        where chatId__c in :listButtonId LIMIT 2000]){
                    mapconfChatsToButtonId.put(confChats.chatId__c, confChats);                                        
            	}
            }
		}

    }
    
    public void bulkAfter() {}
    
    public void beforeInsert(sObject so) {
        
        LiveChatTranscript chat = (LiveChatTranscript) so;
        
        if (mapconfChatsToButtonId.containsKey(chat.LiveChatButtonId)){
	        chat.Marca__c = mapconfChatsToButtonId.get(chat.LiveChatButtonId).Marca__c;
	        chat.Unidad_de_negocio__c = mapconfChatsToButtonId.get(chat.LiveChatButtonId).ownerReg__c;
        }
       
    }
    
    public void beforeUpdate(sObject old, sObject so) {}
 
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {}
    
    public void afterUpdate(sObject old, sObject so) {}
    
    public void afterDelete(sObject so) {}
    
    public void andFinally() {}
}