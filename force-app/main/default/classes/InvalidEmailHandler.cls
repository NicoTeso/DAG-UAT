public with sharing class InvalidEmailHandler implements ITriggerHandler {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();

    public Map<String,Invalid_Emails__c> mapInvalidEmailByEmail = new Map<String,Invalid_Emails__c>();
    public List<Invalid_Emails__c> listInvalidEmailToDelete = new List<Invalid_Emails__c>();
    
    public InvalidEmailHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {
        mapInvalidEmailByEmail.clear();
        if (Trigger.new != null) {
	        List<String> listEmails = new List<String>();
            for(SObject objeto :Trigger.new){
                Invalid_Emails__c InvalidEmail = (Invalid_Emails__c) objeto;
                if(InvalidEmail.Email__c != null){
                    listEmails.add(InvalidEmail.Email__c);
                }
            }
            
            if(!listEmails.isEmpty()){
                mapInvalidEmailByEmail = InvalidEmailGateway.getInvalidEmailByEmail(listEmails);
            }   
        }
    }

    public void bulkAfter() {
    }

    public void beforeInsert(sObject so) {
        Invalid_Emails__c InvalidEmail = (Invalid_Emails__c) so;

        if (mapInvalidEmailByEmail.containsKey(InvalidEmail.Email__c)){
            Invalid_Emails__c InvalidEmailDel = mapInvalidEmailByEmail.get(InvalidEmail.Email__c); 
            listInvalidEmailToDelete.add(InvalidEmailDel);
        }
    }
    
    public void beforeUpdate(sObject old, sObject so) {
    }
    
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {
    }
    
    public void afterUpdate(sObject old, sObject so) {
    }
    
    public void afterDelete(sObject so) {}
    
    public void andFinally() {
        if(!listInvalidEmailToDelete.isEmpty()){
            delete listInvalidEmailToDelete;
        }
        
    }
}